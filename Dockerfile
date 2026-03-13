FROM ubuntu:20.04

# Ngăn các câu hỏi tương tác trong quá trình cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt công cụ Build, GnuCOBOL và các thư viện cần thiết
RUN apt-get update && apt-get install -y \
    gnucobol \
    libcob4-dev \
    libsqlite3-dev \
    libpq-dev \
    pkg-config \
    build-essential \
    gcc \
    make \
    git \
    autoconf \
    automake \
    libtool \
    flex \
    bison \
    dos2unix \
    python3 \
    python3-pip \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL từ mã nguồn
# Sử dụng bản master để đảm bảo tương thích tốt nhất với môi trường hiện tại
WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git && \
    cd Open-COBOL-ESQL && \
    chmod +x autogen.sh && \
    ./autogen.sh && \
    ./configure --with-sqlite3 --without-postgresql && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# 3. Thiết lập thư mục ứng dụng
WORKDIR /app
COPY . .
RUN mkdir -p db bin

# 4. Tiền xử lý và Biên dịch COBOL
# BƯỚC QUAN TRỌNG: 
# - dos2unix: Fix lỗi xuống dòng của Windows (Nguyên nhân lỗi 255)
# - ocesql: Chuyển SQL thành code COBOL (Yêu cầu file .cbl lùi lề 7 khoảng trắng)
# - cobc: Biên dịch file .cob thành thực thi hoặc thư viện liên kết động (.so)
RUN find . -name "*.cbl" -exec dos2unix {} + && \
    # Biên dịch Batch (Tạo file thực thi -x)
    ocesql batch/billing_batch.cbl batch/billing_batch.cob && \
    cobc -x -free batch/billing_batch.cob -o bin/billing_batch \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3 && \
    # Biên dịch Rating Engine (Tạo module động -m)
    ocesql src/rating_engine.cbl src/rating_engine.cob && \
    cobc -m -free src/rating_engine.cob -o bin/rating_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3 && \
    # Biên dịch Policy Engine
    ocesql src/policy_engine.cbl src/policy_engine.cob && \
    cobc -m -free src/policy_engine.cob -o bin/policy_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3 && \
    # Biên dịch Claim Engine
    ocesql src/claim_engine.cbl src/claim_engine.cob && \
    cobc -m -free src/claim_engine.cob -o bin/claim_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# 5. Thiết lập Cron job cho tác vụ Batch chạy hàng ngày
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

# 6. Biến môi trường runtime
# LD_LIBRARY_PATH: Giúp hệ thống tìm thấy thư viện ocesql tại /usr/local/lib
ENV LD_LIBRARY_PATH="/usr/local/lib"
# COB_LIBRARY_PATH: Giúp GnuCOBOL nạp các file .so trong bin
ENV COB_LIBRARY_PATH="/app/bin"

EXPOSE 5000

# 7. Khởi động Cron service và chạy ứng dụng Python API
CMD ["bash", "-c", "service cron start && exec python3 api/app.py"]