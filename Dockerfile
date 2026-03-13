FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y gnucobol gcc python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

RUN mkdir -p bin

# BIÊN DỊCH COBOL (Đảm bảo không copy các ký tự cite)
RUN cobc -m -free src/rating_engine.cbl -o bin/rating_engine.so
RUN cobc -m -free src/policy_engine.cbl -o bin/policy_engine.so
RUN cobc -m -free src/claim_engine.cbl -o bin/claim_engine.so
RUN cobc -x -free batch/billing_batch.cbl -o bin/billing_batch

ENV COB_LIBRARY_PATH=/app/bin

CMD ["python3", "api/app.py"]