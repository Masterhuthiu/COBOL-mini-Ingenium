FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt công cụ build và thư viện phụ thuộc
RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    libcob4-dev \
    libsqlite3-dev \
    libpq-dev \        # chỉ để vượt qua check configure
    pkg-config \       # đây là gói, phải nằm trong apt-get install
    build-essential \
    gcc \
    make \
    git \
    autoconf \
    automake \
    libtool \
    python3 \
    python3-pip \
    cron \
    && rm -rf /var/lib/apt/lists/*


# 2. Cài đặt Open-COBOL-ESQL (SQLite-only)
WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git && \
    cd Open-COBOL-ESQL && \
    ./configure --with-sqlite3 --without-postgresql && \
    make && \
    make install && \
    ldconfig

# 3. Thiết lập ứng dụng
WORKDIR /app
COPY . .

# 4. Tạo cấu trúc thư mục
RUN mkdir -p db bin

# 5. Biên dịch hệ thống COBOL với ocesql
RUN ocesql batch/billing_batch.cbl batch/billing_batch.cob && \
    cobc -x -free batch/billing_batch.cob -o bin/billing_batch -locesql -lsqlite3

RUN ocesql src/rating_engine.cbl src/rating_engine.cob && \
    cobc -m -free src/rating_engine.cob -o bin/rating_engine.so -locesql -lsqlite3

RUN ocesql src/policy_engine.cbl src/policy_engine.cob && \
    cobc -m -free src/policy_engine.cob -o bin/policy_engine.so -locesql -lsqlite3

RUN ocesql src/claim_engine.cbl src/claim_engine.cob && \
    cobc -m -free src/claim_engine.cob -o bin/claim_engine.so -locesql -lsqlite3

# 6. Thiết lập cron job
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

# 7. Thiết lập môi trường runtime
ENV COB_LIBRARY_PATH=/app/bin
EXPOSE 5000

# 8. Chạy cron song song với ứng dụng chính
CMD service cron start && python3 api/app.py
