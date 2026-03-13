FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt đầy đủ công cụ build
RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL (SQLite-only)
WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL.git && \
    cd Open-COBOL-ESQL && \
    git checkout 1.1 && \
    chmod +x autogen.sh && ./autogen.sh && \
    ./configure --with-sqlite3 --without-postgresql && \
    make -j$(nproc) && make install && ldconfig

# 3. Thiết lập ứng dụng
WORKDIR /app
COPY . .
RUN mkdir -p db bin

# 4. Tiền xử lý mã nguồn COBOL
RUN find . -name "*.cbl" -exec dos2unix {} + && \
    find . -name "*.cbl" -exec sed -i 's/^/       /' {} +

# 5. Biên dịch từng file COBOL (chia nhỏ để dễ debug)
# Batch
RUN ls -l batch && \
    ocesql batch/billing_batch.cbl batch/billing_batch.cob && \
    cobc -x -free batch/billing_batch.cob -o bin/billing_batch \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# Rating Engine
RUN ls -l src && \
    ocesql src/rating_engine.cbl src/rating_engine.cob && \
    cobc -m -free src/rating_engine.cob -o bin/rating_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# Policy Engine
RUN ocesql src/policy_engine.cbl src/policy_engine.cob && \
    cobc -m -free src/policy_engine.cob -o bin/policy_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# Claim Engine
RUN ocesql src/claim_engine.cbl src/claim_engine.cob && \
    cobc -m -free src/claim_engine.cob -o bin/claim_engine.so \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# 6. Cấu hình Cron & Môi trường
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV COB_LIBRARY_PATH="/app/bin"
EXPOSE 5000

# 7. Chạy cron song song với ứng dụng chính
CMD ["bash", "-c", "service cron start && exec python3 api/app.py"]
