FROM ubuntu:24.04 AS buildbase
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    zlib1g-dev \
    libssl-dev \
    gperf \
    cmake \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git .
RUN mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
RUN cd build && cmake --build . --target install -- -j$(nproc)

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    libssl3 \
    zlib1g \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=buildbase /usr/src/app/build/telegram-bot-api /usr/local/bin/telegram-bot-api
RUN mkdir /data
VOLUME /data
ENTRYPOINT ["telegram-bot-api", "--local", "--dir=/data"]
