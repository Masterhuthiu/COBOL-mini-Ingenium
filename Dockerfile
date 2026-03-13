FROM ubuntu:22.04

# Tránh các câu hỏi tương tác
ENV DEBIAN_FRONTEND=noninteractive

# Update và cài đặt với cơ chế tự thử lại nếu lỗi mạng
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    make \
    gcc \
    libtool \
    autoconf \
    automake \
    pkg-config \
    gnucobol \
    libcob2-dev \
    libncurses-dev \
    unixodbc-dev \
    odbcinst \
    coreutils \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Clone repo
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git /opt/esql
WORKDIR /opt/esql

# Chạy build
RUN chmod +x autogen.sh configure && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make && \
    make install

# Kiểm tra xem esqloc đã chạy được chưa
RUN esqloc -V

WORKDIR /app