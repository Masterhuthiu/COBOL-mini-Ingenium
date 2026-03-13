FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cơ bản và thư viện cần thiết
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    gcc \
    make \
    curl \
    libsqlite3-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt GnuCOBOL-SQL (Sử dụng curl thay cho git clone để tránh lỗi 128)
WORKDIR /opt
RUN curl -L https://github.com/mhardisty/GnuCOBOL-SQL/archive/refs/heads/master.tar.gz | tar xz && \
    cd GnuCOBOL-SQL-master && \
    make && \
    make install

WORKDIR /app
COPY . .

# Tạo thư mục cho database và binaries
RUN mkdir -p db bin

# Quy trình biên dịch Production: Pre-process -> Compile
# Chuyển đổi SQL thành COBOL thuần và biên dịch
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl && \
    cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl && \
    cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl && \
    cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl && \
    cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

ENV COB_LIBRARY_PATH=/app/bin
CMD ["python3", "api/app.py"]