#!/bin/bash
rp=$(cd $(dirname $(realpath "${BASH_SOURCE}")) && pwd)
cd $rp

if [[ "$EUID" != 0 ]];then
    echo "Need root privilege!"
    exit 1
fi

#check docker
if ! command -v docker >/dev/null 2>&1;then
    release=$(grep '^ID=' /etc/os-release | grep '(?<=ID=).+')
    version=$(grep '^VERSION_ID=' /etc/os-release | grep -oP '[0-9.]+')
    if [ $release == "ubuntu" ];then
        if [ $version =~ 17 ];then
            echo "Install docker on ubuntu 17."
            apt-get update
            apt-get install -y docker.io
            systemctl enable docker
            systemctl start docker
        fi
    fi
fi

if ! command -v docker >/dev/null 2>&1;then
    echo "No docker,install docker by yourself and retry!"
    exit 1
fi


#soft link
ln -sf $PWD/manager.sh /usr/local/bin

#systemd service file
cp ssgo.service /etc/systemd/system/
systemctl enable ssgo.service
systemctl start ssgo.service


#crontab to reboot
item="0 0 * * * /sbin/reboot #reboot every day"
(crontab -l 2>/dev/null;echo "$item") | sort | uniq | crontab -


#enable BBR
bash enableBBR.sh
