FROM alpine
COPY ss-server /usr/local/bin/
#map shadowsocks.json to /etc/shadowsocks.json

CMD ["ss-server","-c","/etc/shadowsocks.json"]
