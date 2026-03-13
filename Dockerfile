FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cơ bản
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

# Cài đặt GnuCOBOL-SQL (Sửa lỗi git clone)
WORKDIR /opt
# Thêm --depth 1 để clone nhanh hơn và tránh lỗi timeout
RUN git clone --depth 1 https://github.com/mhardisty/GnuCOBOL-SQL.git && \
    cd GnuCOBOL-SQL && \
    make && \
    make install

WORKDIR /app
COPY . .

# Tạo thư mục cho database và binaries
RUN mkdir -p db bin

# Quy trình biên dịch: Dùng 'esql' đã cài đặt
# Lưu ý: Các file .cbl phải có cấu trúc EXEC SQL mới chạy được lệnh này
RUN esql batch/billing_batch.cbl -o batch/billing_batch_sqled.cbl && \
    cobc -x -free batch/billing_batch_sqled.cbl -o bin/billing_batch -lsqlite3

# Biên dịch các module engine
RUN esql src/rating_engine.cbl -o src/rating_engine_sqled.cbl && \
    cobc -m -free src/rating_engine_sqled.cbl -o bin/rating_engine.so -lsqlite3

RUN esql src/policy_engine.cbl -o src/policy_engine_sqled.cbl && \
    cobc -m -free src/policy_engine_sqled.cbl -o bin/policy_engine.so -lsqlite3

RUN esql src/claim_engine.cbl -o src/claim_engine_sqled.cbl && \
    cobc -m -free src/claim_engine_sqled.cbl -o bin/claim_engine.so -lsqlite3

ENV COB_LIBRARY_PATH=/app/bin
CMD ["python3", "api/app.py"]