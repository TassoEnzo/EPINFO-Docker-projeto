#!/bin/sh
set -e
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

echo '[1/6] Aguardando Docker Engine...'
until docker info > /dev/null 2>&1; do sleep 1; done

echo '[2/6] Buildando backend...'
docker build -t epinfo_backend:latest /epinfo/backend

echo '[3/6] Buildando frontend...'
docker build -t epinfo_frontend:latest /epinfo/frontend

echo '[4/6] Exportando imagens para workers...'
docker save epinfo_backend:latest epinfo_frontend:latest -o /epinfo/images/epinfo.tar
touch /epinfo/images/ready

echo '[5/6] Inicializando Swarm...'
docker swarm init --advertise-addr eth0

docker swarm join-token worker -q > /epinfo/token/join.token.tmp
cat /epinfo/token/join.token.tmp | sed 's/[^A-Za-z0-9:_-]//g' > /epinfo/token/join.token
echo "Token salvo: $(cat /epinfo/token/join.token)"

echo '[6/6] Aguardando workers entrarem no cluster...'
until [ "$(docker node ls --filter role=worker -q 2>/dev/null | wc -l)" -ge 2 ]; do
  sleep 3
done
echo 'Workers prontos!'
docker stack deploy --resolve-image never -c /epinfo/docker-stack.yml epinfo

tail -f /dev/null
