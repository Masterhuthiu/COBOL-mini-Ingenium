# Sử dụng Ubuntu 22.04 làm nền tảng
FROM ubuntu:22.04

# Thiết lập chế độ không tương tác
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt các thư viện hệ thống cần thiết
# libsqlite3-dev: Thư viện phát triển để liên kết COBOL với SQLite
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    gcc \
    make \
    git \
    libsqlite3-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt GnuCOBOL-SQL Preprocessor (esqloc)
# Đây là bước quan trọng nhất để hiểu được lệnh EXEC SQL
WORKDIR /opt
RUN git clone https://github.com/mhardisty/GnuCOBOL-SQL.git && \
    cd GnuCOBOL-SQL && \
    # Compile công cụ preprocessor
    make && \
    # Cài đặt lệnh 'esql' vào hệ thống
    make install

# 3. Thiết lập thư mục làm việc cho ứng dụng
WORKDIR /app
COPY . .

# 4. Cài đặt các phụ thuộc Python (nếu có)
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# 5. Tạo thư mục bin để chứa file thực thi sau khi biên dịch
RUN mkdir -p bin

# 6. QUY TRÌNH BIÊN DỊCH PRODUCTION (Pre-process -> Compile)
# Bước A: Xử lý file Batch (Cron Job)
# esql sẽ chuyển đổi các lệnh EXEC SQL thành code COBOL thuần/C call
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl
# Biên dịch file đã xử lý với flag -lsqlite3 để liên kết DB
RUN cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

# Bước B: Xử lý các Engine Module (.so)
RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl
RUN cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl
RUN cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl
RUN cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

# 7. Thiết lập môi trường thực thi
ENV COB_LIBRARY_PATH=/app/bin
EXPOSE 5000

# Chạy API chính (nơi khởi tạo database và cung cấp dịch vụ)
CMD ["python3", "api/app.py"]