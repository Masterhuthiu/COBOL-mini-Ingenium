FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt toàn bộ công cụ biên dịch và thư viện SQLite
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    build-essential \
    gcc \
    make \
    curl \
    tar \
    libsqlite3-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt GnuCOBOL-SQL Preprocessor
WORKDIR /opt
# Sử dụng curl để tải bản master, giải nén và biên dịch
RUN curl -L https://github.com/mhardisty/GnuCOBOL-SQL/archive/refs/heads/master.tar.gz | tar xz && \
    cd GnuCOBOL-SQL-master && \
    make && \
    make install

# 3. Thiết lập thư mục làm việc cho ứng dụng
WORKDIR /app
COPY . .

# 4. Tạo thư mục chứa database và file thực thi
RUN mkdir -p db bin

# 5. Biên dịch hệ thống (Pre-process -> Compile)
# Chuyển đổi và biên dịch Batch Job
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl && \
    cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

# Biên dịch các module Engine (Rating, Policy, Claim)
RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl && \
    cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl && \
    cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl && \
    cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

# 6. Cấu hình môi trường chạy
ENV COB_LIBRARY_PATH=/app/bin
EXPOSE 5000

# Chạy API chính
CMD ["python3", "api/app.py"]