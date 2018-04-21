#!/bin/bash
#rp=$(cd $(dirname $(readlink "${BASH_SOURCE}")) && pwd)
rp=$(cd $(dirname $(realpath "${BASH_SOURCE}")) && pwd)
cd "$rp"

if ! command -v docker >/dev/null 2>&1;then
    echo "ERROR: No docker,exit!"
    exit 1
fi

image=ssserver
container=ssserver
cfg=shadowsocks.json
editor=vi
if command -v vim >/dev/null 2>&1;then
    editor=vim
fi
#build if possible

usage(){
    cat<<EOF
Usage: $(basename $0) CMD

CMD:
    start
    stop
    restart
    rm
    log
    config
EOF
exit 1
}

start(){
    #解析config.json文件中的port，之后用在-p参数中
    #-v参数映射到/etc/config.json
    ports=$(sed -n '/port_password/,/},/p' $cfg | ggrep -oP '(?<=")[0-9]+(?=":)')
    pflag=
    for port in $ports;do
        pflag="$pflag -p $port:$port"
        #TODO iptables port
    done
    vflag="-v $PWD/$cfg:/etc/$cfg"

    if ! docker image inspect $image >/dev/null 2>&1;then
        echo "No docker image: ${image}!"
        echo "docker build -t $image ."
        docker build -t $image .
    fi
    #if not exist container
    if ! docker container inspect $container >/dev/null 2>&1;then
        echo "No container: $container"
        echo "Create and start one"
        echo "docker run --name $container $pflag $vflag -d $image"
        docker run --name $container $pflag $vflag -d $image
    else
        #if exist and not running
        state=$(docker container inspect -f {{.State.Running}} $container)
        if [  $state == "false" ];then
            echo "Start..."
            echo "docker start $container"
            docker start $container
        else
        #if exist and already running
            echo "Alread running."
        fi
    fi


}
stop(){
    state=$(docker container inspect -f {{.State.Running}} $container)
    if [ $state == "true" ];then
        docker stop $container
    else
        echo "Container: $container is not running"
    fi
}
rm(){
    #stop container and rm it
    docker stop $container
    docker container rm $container
    docker image rm $image
}

log(){
    docker logs $container
}

config(){
    $editor $cfg

    #check modify time and restart if possible
}

case $1 in
    -h|--help)
        usage
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    rm)
        rm
        ;;
    log)
        log
        ;;
    config)
        config
        ;;
    *)
        usage
        ;;
esac
