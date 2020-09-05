#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR


docker build -t sachin_redis:1.0.0 .

docker kill redis12 || true;
sleep 3

docker run --rm -d -p 6379:6379 --name redis12 sachin_redis:1.0.0




echo ''
echo 'Some Commands :==>'
echo ''

echo 'docker exec -it redis1 redis-cli -h localhost'
echo 'set k1 v1'
echo 'get k1'

echo ''
echo ''
sleep 3
docker logs redis12
