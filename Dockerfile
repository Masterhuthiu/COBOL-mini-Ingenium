
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git && \
    cd Open-COBOL-ESQL && \
    autoreconf -i && \
    ./configure --with-sqlite3 --without-postgresql && \
    make -j$(nproc) && make install && ldconfig
