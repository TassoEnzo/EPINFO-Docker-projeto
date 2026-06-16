#!/bin/sh
export DOCKER_HOST=unix:///var/run/docker.sock
dockerd --host=unix:///var/run/docker.sock &

echo '[W] Aguardando Docker Engine...'
sleep 10
until docker -H unix:///var/run/docker.sock info > /dev/null 2>&1; do
  echo '[W] Ainda aguardando...'
  sleep 2
done

echo '[W] Aguardando imagens do manager...'
until [ -f /epinfo/images/ready ]; do sleep 2; done

echo '[W] Carregando imagens...'
docker load -i /epinfo/images/epinfo.tar

echo '[W] Aguardando token...'
until [ -f /epinfo/token/join.token ] && [ -s /epinfo/token/join.token ]; do sleep 2; done

TOKEN=$(cat /epinfo/token/join.token)
echo "[W] Token lido: $TOKEN"
echo '[W] Entrando no cluster...'
docker swarm join --token "$TOKEN" manager:2377
echo '[W] Worker no cluster!'

tail -f /dev/null
