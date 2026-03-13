IDENTIFICATION DIVISION.
PROGRAM-ID. RATINGENGINE.

PROCEDURE DIVISION.
    DISPLAY "BUILD SUCCESSFUL".
    GOBACK.

    ////


FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron ca-certificates \
    m4 gettext \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git

WORKDIR /opt/Open-COBOL-ESQL

RUN autoreconf -fiv

RUN ./configure --with-sqlite3 --without-postgresql

RUN make -j$(nproc)

RUN make install && ldconfig