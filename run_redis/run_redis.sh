#!/usr/bin/env bash


docker kill redis1 || true;

docker run --rm -d -p 6379:6379 --name redis1 redis

echo ''
echo 'Some Commands :==>'
echo ''

echo 'docker exec -it redis1 redis-cli -h localhost'
echo 'set k1 v1'
echo 'get k1'

echo ''
echo ''
sleep 3
docker logs redis1
