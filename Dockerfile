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

WORKDIR /app
COPY test.cbl .

RUN ocesql test.cbl test.cob

# Dump generated .cob so we can see it
RUN cat test.cob

ENV LD_LIBRARY_PATH="/usr/local/lib"

# Capture ALL output (stdout+stderr) then print before failing
RUN cobc -x -free test.cob -o test_bin \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3 \
         > /tmp/cobc.log 2>&1 \
    || (cat /tmp/cobc.log && exit 1)

CMD ["./test_bin"]