FROM ubuntu:22.04

# Tránh các câu hỏi tương tác khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt đầy đủ các gói phụ thuộc hệ thống
RUN apt-get update && apt-get install -y \
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
    coreutils

# Clone repo
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git /opt/esql
WORKDIR /opt/esql

# Cấp quyền thực thi và chạy build
RUN chmod +x autogen.sh configure
RUN ./autogen.sh

# Quan trọng: Nếu vẫn lỗi, ta ép đường dẫn thư viện
RUN ./configure --prefix=/usr/local

RUN make
RUN make install

# Kiểm tra xem cài đặt thành công chưa
RUN esqloc -V

WORKDIR /app