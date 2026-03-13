FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt công cụ
RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \        
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL
WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git && \
    cd Open-COBOL-ESQL && \
    chmod +x autogen.sh && ./autogen.sh && \
    ./configure --with-sqlite3 --without-postgresql && \
    make -j$(nproc) && make install && ldconfig

# 3. Thiết lập ứng dụng
WORKDIR /app
COPY . .
RUN mkdir -p db bin && find . -name "*.cbl" -exec dos2unix {} +

# 4. Biên dịch từng file (Tách riêng để cô lập lỗi)
# Bước 4.1: Biên dịch Batch
RUN ocesql batch/billing_batch.cbl batch/billing_batch.cob && \
    cobc -x batch/billing_batch.cob -o bin/billing_batch -L/usr/local/lib -locesql -lsqlite3

# Bước 4.2: Biên dịch Rating Engine
RUN ocesql src/rating_engine.cbl src/rating_engine.cob && \
    cobc -m src/rating_engine.cob -o bin/rating_engine.so -L/usr/local/lib -locesql -lsqlite3

# Bước 4.3: Biên dịch Policy Engine
RUN ocesql src/policy_engine.cbl src/policy_engine.cob && \
    cobc -m src/policy_engine.cob -o bin/policy_engine.so -L/usr/local/lib -locesql -lsqlite3

# Bước 4.4: Biên dịch Claim Engine
RUN ocesql src/claim_engine.cbl src/claim_engine.cob && \
    cobc -m src/claim_engine.cob -o bin/claim_engine.so -L/usr/local/lib -locesql -lsqlite3

# 5. Cấu hình Cron và Môi trường
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV COB_LIBRARY_PATH="/app/bin"
EXPOSE 5000

CMD ["bash", "-c", "service cron start && exec python3 api/app.py"]