#!/usr/bin/env bash

BUILD_IMG="false"

DOCKER_IMG="sachin_pg_dz"
DOCKER_IMG_VERSION="1.0.0"
CONTAINER_NAME="sachin_pg_c"

IMG_NAME="${DOCKER_IMG}:${DOCKER_IMG_VERSION}"


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh
sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"

if [ "${BUILD_IMG}" == "true" ]; then
  echo 'Going to force-build the postgres image.....'
  docker build -t ${IMG_NAME} ${SCRIPT_DIR}/image
else
  echo 'Image forece build is not enabled, going to check whether image exists or not'
  EXISTING_IMG=$(docker images | grep ${DOCKER_IMG} | grep ${DOCKER_IMG_VERSION})
  if [[ -z ${EXISTING_IMG} ]]; then
    echo 'Going to build the image as it doesnot exist'
    docker build -t ${IMG_NAME} ${SCRIPT_DIR}/image
  else
    echo 'Image already exist, skipping the new build....'
  fi
fi


docker kill ${CONTAINER_NAME} || true;

IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
echo 'IP_ADDRESS = '${IP_ADDR}

docker run --rm --name ${CONTAINER_NAME} -d -p 5432:5432 \
    --add-host="${MACHINE_ALIAS}:${IP_ADDR}" \
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