#!/bin/sh
dockerd --host=unix:///var/run/docker.sock &

echo '[W] Aguardando Docker Engine...'
until docker info > /dev/null 2>&1; do sleep 1; done

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
