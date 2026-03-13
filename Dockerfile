FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cai dat dependencies
RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron ca-certificates \
    m4 gettext \
    && rm -rf /var/lib/apt/lists/*

# 2. Cai dat Open-COBOL-ESQL (Phan ban da xac nhan chay tot)
WORKDIR /opt
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git
WORKDIR /opt/Open-COBOL-ESQL
RUN autoreconf -fiv && \
    ./configure --with-sqlite3 --without-postgresql && \
    make -j$(nproc) && \
    make install && ldconfig

# 3. Build file test
WORKDIR /app
COPY test.cbl .

# Bước sửa lỗi Exit 1:
# 1. Chuyển định dạng file về Unix
# 2. Chạy ocesql với cờ -I để nạp thư viện hệ thống
# Sửa lỗi 255 bằng cách dọn dẹp file và ép kiểu biên dịch
RUN dos2unix test.cbl && \
    sed -i 's/\r//' test.cbl && \
    ocesql test.cbl test.cob && \
    cobc -x -free test.cob -o test_app -L/usr/local/lib -locesql -lsqlite3
    
ENV LD_LIBRARY_PATH="/usr/local/lib"
CMD ["./test_app"]