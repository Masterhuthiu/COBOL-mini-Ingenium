FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài đặt các gói phụ trợ
RUN apt-get update && apt-get install -y \
    gnucobol libcob4-dev libsqlite3-dev libpq-dev \
    pkg-config build-essential gcc make git autoconf automake libtool \
    flex bison dos2unix python3 python3-pip cron \
    ca-certificates m4 gettext \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL
WORKDIR /opt
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git

WORKDIR /opt/Open-COBOL-ESQL
RUN autoreconf -fiv
RUN ./configure --with-sqlite3 --without-postgresql
RUN make -j$(nproc)
RUN make install && ldconfig

# 3. Chuẩn bị thư mục ứng dụng
WORKDIR /app
COPY . .
RUN mkdir -p db bin

# 4. Tiền xử lý mã nguồn - chỉ convert line endings, KHÔNG thêm spaces
RUN find . -name "*.cbl" -exec dos2unix {} +

# 5. Biên dịch các Module
# Billing batch
RUN ocesql batch/billing_batch.cbl batch/billing_batch.cob || \
    (echo "=== OCESQL FAILED ===" && cat batch/billing_batch.cbl && exit 1)
RUN cobc -x -free batch/billing_batch.cob -o bin/billing_batch \
         -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# Rating engine
RUN ocesql src/test.cbl src/test.cob || \
    (echo "=== OCESQL FAILED ===" && cat src/test.cbl && exit 1)
# RUN ocesql src/rating_engine.cbl src/rating_engine.cob || \
#     (echo "=== OCESQL FAILED ===" && cat src/rating_engine.cbl && exit 1)
# RUN cobc -m -free src/rating_engine.cob -o bin/rating_engine.so \
#          -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# # Policy engine
# RUN ocesql src/policy_engine.cbl src/policy_engine.cob || \
#     (echo "=== OCESQL FAILED ===" && cat src/policy_engine.cbl && exit 1)
# RUN cobc -m -free src/policy_engine.cob -o bin/policy_engine.so \
#          -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# # Claim engine
# RUN ocesql src/claim_engine.cbl src/claim_engine.cob || \
#     (echo "=== OCESQL FAILED ===" && cat src/claim_engine.cbl && exit 1)
# RUN cobc -m -free src/claim_engine.cob -o bin/claim_engine.so \
#          -I/usr/local/include -L/usr/local/lib -locesql -lsqlite3

# 6. Thiết lập Cron job
RUN echo "0 0 * * * root /app/bin/billing_batch >> /var/log/cron.log 2>&1" > /etc/cron.d/billing-cron && \
    chmod 0644 /etc/cron.d/billing-cron && \
    crontab /etc/cron.d/billing-cron

# 7. Cấu hình môi trường Runtime
ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV COB_LIBRARY_PATH="/app/bin"

EXPOSE 5000

CMD ["bash", "-c", "service cron start && exec python3 api/app.py"]