FROM        alpine
MAINTAINER  KOTAIMEN <kotaimen.c@gmail.com>

ARG         SS_VER=3.3.0
ARG         SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VER}/shadowsocks-libev-${SS_VER}.tar.gz
ARG         OBFS_URL=https://github.com/shadowsocks/simple-obfs.git

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD=
ENV METHOD      aes-256-gcm
ENV TIMEOUT     300
ENV DNS_ADDRS    8.8.8.8,8.8.4.4
ENV SIMPLE_OBFS_METHOD    http
ENV ARGS=

RUN         set -ex \
            # Build environment setup
            && apk add --no-cache \
                --virtual .build-deps \
                autoconf \
                automake \
                build-base \
                curl \
                libev-dev \
                libtool \
                linux-headers \
                c-ares-dev \
                libsodium-dev \
                mbedtls-dev \
                pcre-dev \
                tar \
                git \
            \
            # Build & install
            && mkdir -p /tmp/ss \
            && cd /tmp/ss \
            && curl -sSL $SS_URL | tar xz --strip 1 \
            && ./configure --prefix=/usr --disable-documentation \
            && make install \
            \
            # obfs install
            && cd /tmp/ \
            && git clone $OBFS_URL simple-obfs \
            && cd simple-obfs \
            && git submodule update --init --recursive \
            && ./autogen.sh \
            && ./configure --prefix=/usr --disable-documentation \
            && make install \
            \
            # Runtime dependencies setup
            && runDeps="$( \
                scanelf --needed --nobanner /usr/bin/ss-* /usr/bin/obfs-* \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | xargs -r apk info --installed \
                    | sort -u \
            )" \
            && apk add --no-cache --virtual .run-deps $runDeps \
            \
            && apk del .build-deps \
            && cd / && rm -rf /tmp/*

USER        nobody

# Start in server mode by default
CMD exec ss-server \
      -s $SERVER_ADDR \
      -p $SERVER_PORT \
      -k ${PASSWORD:-$(hostname)} \
      -m $METHOD \
      -t $TIMEOUT \
      -d $DNS_ADDRS \
      --fast-open -u \
      --plugin obfs-server --plugin-opts obfs=${SIMPLE_OBFS_METHOD:http}
