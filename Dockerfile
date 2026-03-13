FROM ubuntu:22.04

# Thiết lập môi trường để tránh các câu hỏi tương tác khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cần thiết
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    gcc \
    make \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy toàn bộ source code vào container
COPY . .

# Cài đặt dependencies cho Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Tạo thư mục bin để chứa các file thực thi/module
RUN mkdir -p bin

# BIÊN DỊCH COBOL:
# 1. Các Engine (rating, policy, claim) dùng LINKAGE SECTION nên phải build thành MODULE (-m)
RUN cobc -m src/rating_engine.cbl -o bin/rating_engine.so
RUN cobc -m src/policy_engine.cbl -o bin/policy_engine.so
RUN cobc -m src/claim_engine.cbl -o bin/claim_engine.so

# 2. Billing Batch nếu là chương trình chạy độc lập thì dùng (-x) 
# Nhưng nếu nó cũng có "USING", bạn phải đổi sang -m luôn.
RUN cobc -x batch/billing_batch.cbl -o bin/billing_batch

# Thiết lập biến môi trường để COBOL tìm thấy các module .so trong thư mục bin
ENV COB_LIBRARY_PATH=/app/bin

EXPOSE 5000

CMD ["python3", "api/app.py"]