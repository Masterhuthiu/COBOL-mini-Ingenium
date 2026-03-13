# Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài dependencies
RUN apt-get update && apt-get install -y \
    gnucobol \
    libpq-dev \
    postgresql-client \
    build-essential \
    autoconf \
    automake \
    libtool \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone và build ocesql
WORKDIR /opt
RUN git clone --branch develop https://github.com/opensourcecobol/Open-COBOL-ESQL.git ocesql

WORKDIR /opt/ocesql
RUN export CPPFLAGS="-I/usr/include/postgresql" && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# 3. Copy COBOL copybooks
ENV COBCPY=/usr/local/share/opencobalesql/copy
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

WORKDIR /app
CMD ["/bin/bash"]