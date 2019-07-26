# Shadowsocks

Shadowsocks on alpine linux with simple http obfuscating , built from source.

Tags:

- `3.3.0`, `latest`: shadowsocks-libev with simple-obfs plugin on alpine

> Note: OTA is not available on 3.x, use gcm encryption methods instead. 

## Usage

By default, image starts in server mode.

Start server with docker-compose:

    docker-compose up

Change default config in `docker-compose.yml`