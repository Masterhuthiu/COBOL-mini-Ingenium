FROM ubuntu:22.04

# Cài đặt GnuCOBOL và các thư viện cần thiết
RUN apt-get update && apt-get install -y \
    gnucobol \
    unixodbc-dev \
    gcc \
    make \
    autoconf \
    git

# Clone và build Open-COBOL-ESQL
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git /opt/esql
WORKDIR /opt/esql
RUN ./autogen.sh && ./configure && make && make install

WORKDIR /app