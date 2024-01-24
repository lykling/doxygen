FROM ubuntu:focal AS builder

RUN apt-get update && apt-get install -y \
    g++ \
    python \
    cmake \
    flex \
    bison \
    libxapian-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /doxygen
COPY . .

RUN mkdir build \
    && cd build \
    && cmake -G "Unix Makefiles" .. -Dbuild_search=on \
    && make \
    && make install


FROM ubuntu:focal
RUN apt-get update && apt-get install --no-install-recommends -y \
    graphviz \
    libxapian-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /doxygen/build/bin/doxygen /usr/local/bin/
COPY --from=builder /doxygen/build/bin/doxyindexer /usr/local/bin/
COPY --from=builder /doxygen/build/bin/doxysearch.cgi /usr/local/bin/
WORKDIR /doxygen
ENTRYPOINT ["doxygen"]
