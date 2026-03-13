FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cài TẤT CẢ dependencies cần thiết
RUN apt-get update && apt-get install -y \
    # COBOL compiler
    gnucobol \
    # PostgreSQL client library
    libpq-dev \
    postgresql-client \
    # Build tools
    build-essential \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libtool \
    # Parser/lexer tools (quan trọng! thiếu là lỗi)
    bison \
    flex \
    # Utilities
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone repo
WORKDIR /opt
RUN git clone --depth 1 --branch develop \
    https://github.com/opensourcecobol/Open-COBOL-ESQL.git ocesql

WORKDIR /opt/ocesql

# 3. Fix: set YACC=bison -y, chạy autogen.sh trước configure
RUN export YACC="bison -y" && \
    export CPPFLAGS="-I/usr/include/postgresql" && \
    export LDFLAGS="-L/usr/lib/x86_64-linux-gnu" && \
    chmod +x autogen.sh && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# 4. Set environment
ENV COBCPY=/usr/local/share/ocesql/copy
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/bin:$PATH

WORKDIR /app
CMD ["/bin/bash"]