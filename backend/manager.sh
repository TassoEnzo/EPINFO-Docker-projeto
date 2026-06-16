#!/bin/sh
set -e
export DOCKER_HOST=unix:///var/run/docker.sock
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

echo '[1/6] Aguardando Docker Engine...'
sleep 10
until docker -H unix:///var/run/docker.sock info > /dev/null 2>&1; do
  echo '[1/6] Ainda aguardando...'
  sleep 2
done

echo '[2/6] Buildando backend...'
docker build -t epinfo_backend:latest /epinfo/backend

echo '[3/6] Buildando frontend...'
docker build -t epinfo_frontend:latest /epinfo/frontend

echo '[3.5/6] Buildando banco...'
docker build -t epinfo_db:latest /epinfo/banco_de_dados

echo '[4/6] Exportando imagens para workers...'
docker save epinfo_backend:latest epinfo_frontend:latest epinfo_db:latest -o /epinfo/images/epinfo.tar
touch /epinfo/images/ready

echo '[5/6] Inicializando Swarm...'
MANAGER_IP=$(getent hosts manager | awk '{ print $1 }')
echo "Manager IP: $MANAGER_IP"
docker swarm init --advertise-addr $MANAGER_IP --listen-addr 0.0.0.0:2377

docker swarm join-token worker -q > /epinfo/token/join.token.tmp
cat /epinfo/token/join.token.tmp | sed 's/[^A-Za-z0-9:_-]//g' > /epinfo/token/join.token
echo "Token salvo: $(cat /epinfo/token/join.token)"

echo '[6/6] Aguardando workers entrarem no cluster...'
until [ "$(docker node ls --filter role=worker -q 2>/dev/null | wc -l)" -ge 2 ]; do
  sleep 3
done
echo 'Workers prontos!'
docker stack deploy --resolve-image never -c /epinfo/docker-stack.yml epinfo
echo 'Cluster pronto!'

tail -f /dev/null
