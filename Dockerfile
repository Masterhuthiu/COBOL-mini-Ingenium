FROM ubuntu:22.04

# Cài đặt đầy đủ bộ công cụ Build và Dependencies
RUN apt-get update && apt-get install -y \
    gnucobol \
    unixodbc-dev \
    libodbc1 \
    libtool \
    autoconf \
    automake \
    pkg-config \
    gcc \
    make \
    git \
    coreutils

# Clone và build Open-COBOL-ESQL
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git /opt/esql
WORKDIR /opt/esql

# Chạy từng bước để dễ debug nếu có lỗi
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

WORKDIR /app