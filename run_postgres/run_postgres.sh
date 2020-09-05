#!/usr/bin/env bash

BUILD_IMG="false"

#IMG_NAME="sachin_pg:1.0.0"
IMG_NAME="sachin_pg_dz:1.0.1"

CONTAINER_NAME="sachin_pg"


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${BUILD_IMG}" == "true" ]; then
  echo 'Going to build the postgres image.....'
  docker build -t ${IMG_NAME} ${SCRIPT_DIR}/image
fi


docker kill ${CONTAINER_NAME} || true;

IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
echo 'IP_ADDRESS = '${IP_ADDR}

docker run --rm --name ${CONTAINER_NAME} -d -p 5432:5432 \
    --add-host="vm-sachin:${IP_ADDR}" \
    -h ${CONTAINER_NAME} \
    -v ${SCRIPT_DIR}/int_setup.sql:/init.sql \
    -e POSTGRES_USER=sachin \
    -e POSTGRES_PASSWORD=123456 \
    -e POSTGRES_DB=mydb \
    ${IMG_NAME}


sleep 8
docker exec ${CONTAINER_NAME}  psql -U sachin mydb -f /init.sql;


echo ''
echo 'Some Commands :==>'
echo ''

echo "docker exec -it ${CONTAINER_NAME} psql -h localhost --user sachin --db mydb"

echo '\l <== to list the databases.'
echo '\d <== to list the tables.'