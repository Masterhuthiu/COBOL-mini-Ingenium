FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    gnucobol \
    gcc \
    make \
    python3 \
    python3-pip

WORKDIR /app

COPY . .

RUN pip3 install -r requirements.txt

RUN mkdir -p bin

RUN cobc -x src/rating_engine.cbl -o bin/rating_engine
RUN cobc -x src/policy_engine.cbl -o bin/policy_engine
RUN cobc -x src/claim_engine.cbl -o bin/claim_engine
RUN cobc -x batch/billing_batch.cbl -o bin/billing_batch

CMD ["python3", "api/app.py"]