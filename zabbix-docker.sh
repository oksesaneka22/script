#!/bin/bash

sudo apt update
sudo apt install apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce

sudo usermod -aG docker $USER

sudo systemctl status docker
docker -v

mkdir /var/lib/zabbix/
cd /var/lib/zabbix/
ln -s /usr/share/zoneinfo/Europe/Kiev localtime
echo 'Europe/Kiev' > timezone

sudo docker network create zabbix-net

sudo docker run -d \
--name zabbix-server \
-p 80:8080 -p 443:8443 \
--network zabbix-net \
-e DB_SERVER_HOST="zabbix-server" \
-e ZBX_SERVER_HOST="zabbix-server" \
-e PHP_TZ="Europe/Kiev" \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/localtime:/etc/localtime \
-v /var/lib/zabbix/localtime:/etc/localtime \
-v /var/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
-v /var/lib/zabbix/timezone:/etc/timezone \
-v /var/lib/zabbix/localtime:/etc/localtime \
-p 10051:10051 -e DB_SERVER_HOST="zabbix-postgres" \
-e POSTGRES_PASSWORD=zabbix \
-e POSTGRES_USER=zabbix \
-d postgres:alpine
-d zabbix/zabbix-server-pgsql:alpine-latest
-d zabbix/zabbix-web-nginx-pgsql:alpine-latest




sudo docker start zabbix-web
