# Sử dụng Ubuntu 22.04 làm base image
FROM ubuntu:22.04

# Thiết lập chế độ không tương tác để tránh treo khi cài đặt package
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt môi trường: GnuCOBOL, GCC và Python
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    gcc \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Thiết lập thư mục làm việc
WORKDIR /app

# 3. Copy toàn bộ mã nguồn vào container
COPY . .

# 4. Cài đặt các thư viện Python (nếu có)
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# 5. Tạo thư mục bin để chứa sản phẩm biên dịch
RUN mkdir -p bin

# 6. BIÊN DỊCH COBOL
# -m: Tạo module (.so) để Python có thể gọi [cite: 7, 8, 9]
# -free: Cho phép viết code không theo chuẩn cột 7-8
RUN cobc -m -free src/rating_engine.cbl -o bin/rating_engine.so [cite: 7, 8, 9]
RUN cobc -m -free src/policy_engine.cbl -o bin/policy_engine.so [cite: 4, 5, 6]
RUN cobc -m -free src/claim_engine.cbl -o bin/claim_engine.so [cite: 1, 2, 3]

# -x: Tạo file thực thi độc lập cho Batch Job (Cron job) 
RUN cobc -x -free batch/billing_batch.cbl -o bin/billing_batch 

# 7. Thiết lập biến môi trường để hệ thống tìm thấy các thư viện .so
ENV COB_LIBRARY_PATH=/app/bin

# 8. Khởi chạy ứng dụng API chính
# Port mặc định thường là 5000 cho Flask hoặc 8000 cho FastAPI
EXPOSE 5000

CMD ["python3", "api/app.py"]