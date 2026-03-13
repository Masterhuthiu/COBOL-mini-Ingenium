FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt COBOL và ESQL từ apt
RUN apt-get clean && apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    open-cobol-esql \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Thiết lập ứng dụng
WORKDIR /app
COPY . .
RUN mkdir -p db bin

# 3. Tiền xử lý mã nguồn COBOL
RUN find . -name "*.cbl" -exec dos2unix {} + && \
    find . -name "*.cbl" -exec sed -i 's/^/       /' {} +

# 4. Biên dịch COBOL với ocesql
RUN ocesql batch/billing_batch.cbl batch/billing_batch.cob && \
    cobc -x -free batch/billing_batch.cob -o bin/billing_batch -locesql -lsqlite3

RUN ocesql src/rating_engine.cbl src/rating_engine.cob && \
    cobc -m -free src/rating_engine.cob -o bin/rating_engine.so -locesql -lsqlite3

RUN ocesql src/policy_engine.cbl src/policy_engine.cob && \
    cobc -m -free src/policy_engine.cob -o bin/policy_engine.so -locesql -lsqlite3

RUN ocesql src/claim_engine.cbl src/claim_engine.cob && \
    cobc -m -free src/claim_engine.cob -o bin/claim_engine.so -locesql -lsqlite3

# 5. Cron job
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV COB_LIBRARY_PATH="/app/bin"
EXPOSE 5000

CMD ["bash", "-c", "service cron start && exec python3 api/app.py"]
