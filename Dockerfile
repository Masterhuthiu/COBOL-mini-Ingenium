FROM ubuntu:22.04

# Cài đặt toàn bộ "vũ khí" cần thiết
RUN apt-get update && apt-get install -y \
    gnucobol \
    libcob2-dev \
    unixodbc-dev \
    odbcinst \
    libtool \
    autoconf \
    automake \
    pkg-config \
    gcc \
    make \
    git \
    coreutils

# Clone repo
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git /opt/esql
WORKDIR /opt/esql

# Chạy build
RUN ./autogen.sh
# Thêm các cờ hỗ trợ nếu cần, nhưng cơ bản chỉ cần ./configure
RUN ./configure
RUN make
RUN make install

WORKDIR /app