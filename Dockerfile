FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    make \
    gcc \
    g++ \
    git \
    ca-certificates \
    libpq-dev \
    postgresql-client \
    gnucobol \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN export CPPFLAGS="-I/usr/include/postgresql" && \
    ./configure && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

CMD ["bash"]