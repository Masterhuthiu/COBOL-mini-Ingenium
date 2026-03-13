FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnucobol \
    libpq-dev \
    postgresql-client \
    build-essential \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libtool \
    bison \
    flex \
    git \
    wget \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 --branch develop \
    https://github.com/opensourcecobol/Open-COBOL-ESQL.git ocesql

WORKDIR /opt/ocesql

RUN chmod +x autogen.sh && ./autogen.sh

RUN export YACC="bison -y" && \
    export CPPFLAGS="-I/usr/include/postgresql" && \
    ./configure

RUN make

RUN make install && ldconfig

ENV COBCPY=/usr/local/share/ocesql/copy
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PATH=/usr/local/bin:$PATH

WORKDIR /app
CMD ["/bin/bash"]