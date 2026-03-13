# Sử dụng image đã cấu hình sẵn GnuCOBOL để tránh lỗi apt-get
FROM mbcrawfo/gnucobol:3.1-dev

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các thư viện bổ trợ cho ESQL và ODBC
RUN apt-get update && apt-get install -y \
    git \
    libtool \
    autoconf \
    automake \
    pkg-config \
    unixodbc-dev \
    odbcinst \
    && rm -rf /var/lib/apt/lists/*

# Build Open-COBOL-ESQL từ nguồn
WORKDIR /opt/esql
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git . \
    && chmod +x autogen.sh \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && ldconfig

# Quay lại thư mục app để làm việc
WORKDIR /app