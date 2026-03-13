FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt công cụ và thư viện
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    libcob4-dev \
    libsqlite3-dev \
    build-essential \
    gcc \
    make \
    wget \
    tar \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt GnuCOBOL-SQL (Sửa link từ master sang main)
WORKDIR /opt
RUN wget https://github.com/mhardisty/GnuCOBOL-SQL/archive/refs/heads/main.tar.gz -O gnu-sql.tar.gz && \
    tar -xzf gnu-sql.tar.gz && \
    cd GnuCOBOL-SQL-main && \
    make && \
    make install

# 3. Thiết lập ứng dụng
WORKDIR /app
COPY . .

# 4. Tạo thư mục
RUN mkdir -p db bin

# 5. BIÊN DỊCH HỆ THỐNG (Sử dụng lệnh esql)
# Lưu ý quan trọng: Các file .cbl dưới đây PHẢI chứa nội dung EXEC SQL mới build được
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl && \
    cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl && \
    cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl && \
    cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl && \      
    cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

ENV COB_LIBRARY_PATH=/app/bin
EXPOSE 5000

CMD ["python3", "api/app.py"]