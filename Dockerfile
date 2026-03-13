FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt các công cụ biên dịch và thư viện phát triển
# Sửa libcob-dev thành libcob4-dev cho Ubuntu 22.04
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    libcob4-dev \
    libsqlite3-dev \
    build-essential \
    gcc \
    make \
    curl \
    tar \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt GnuCOBOL-SQL Preprocessor
WORKDIR /opt
RUN curl -L https://github.com/mhardisty/GnuCOBOL-SQL/archive/refs/heads/master.tar.gz | tar xz && \
    cd GnuCOBOL-SQL-master && \
    make && \
    make install

# 3. Thiết lập thư mục ứng dụng
WORKDIR /app
COPY . .

# 4. Tạo cấu trúc thư mục
RUN mkdir -p db bin

# 5. BIÊN DỊCH HỆ THỐNG (Pre-process -> Compile)
# Biên dịch Batch Job (Cron Job)
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl && \
    cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

# Biên dịch các module Engine (.so)
RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl && \
    cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl && \
    cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl && \
    cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

# 6. Cấu hình môi trường chạy
ENV COB_LIBRARY_PATH=/app/bin
EXPOSE 5000

# Khởi chạy Python API
CMD ["python3", "api/app.py"]