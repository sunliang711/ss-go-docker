## shadowsocks golang版本的docker版本(服务器端)
* manager.sh 用于管理开启、停止、重启、查看日志等
* shadowsocks.json 为配置文件 它会映射到container里的/etc/shadowsocks.json
* ss-server 为golang版本编译的可执行文件 env GOOS=linux GOARCH=amd64
