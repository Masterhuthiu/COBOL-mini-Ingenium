FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    make \
    gcc \
    g++ \
    git \
    m4 \
    ca-certificates \
    libpq-dev \
    postgresql-client \
    gnucobol \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN set -eux; \
    ROOT=""; \
    if [ -f "./configure.ac" ] || [ -f "./configure.in" ]; then \
      ROOT="."; \
    else \
      ROOT=$(find . -type f \( -name "configure.ac" -o -name "configure.in" \) -printf '%h\n' | head -n 1); \
    fi; \
    if [ -z "$ROOT" ]; then \
      echo "ERROR: configure.ac/configure.in not found"; \
      exit 1; \
    fi; \
    echo "Using project root: $ROOT"; \
    cd "$ROOT"; \
    if [ -f "./autogen.sh" ]; then chmod +x ./autogen.sh && ./autogen.sh; else autoreconf -fi; fi; \
    export CPPFLAGS="-I/usr/include/postgresql"; \
    ./configure; \
    make -j"$(nproc)"; \
    make install; \
    ldconfig

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

CMD ["bash"]