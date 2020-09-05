#!/usr/bin/env bash


FOLDER_NAME="poc"
REGENERATE_CERTS="true"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh
sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"


docker kill nginx || true;
docker rm nginx || true;



function generateCertAndKey() {
     rm -rf ${SCRIPT_DIR}/conf_and_data/conf.d/cert/*
    echo -e "SG\nSingapore\nSingapore\nMYCOMP\ndev\n${MACHINE_ALIAS}\na@a.com" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${SCRIPT_DIR}/conf_and_data/conf.d/cert/nginx-selfsigned.key -out ${SCRIPT_DIR}/conf_and_data/conf.d/cert/nginx-selfsigned.crt
}

if [[ "${REGENERATE_CERTS}" == "true" ]]; then
  echo 'Regenerating certs....'
  generateCertAndKey
else
  echo 'Regenerating certs skipped....'
  if [[ ! -f ${SCRIPT_DIR}/conf_and_data/conf.d/cert/nginx-selfsigned.crt ]]; then
  echo 'Regenerate certs is false but crt file doesnot exist! Exiting'
  exit 0;
  fi
fi


FOLDER_FULL_PATH=${SCRIPT_DIR}/conf_and_data/${FOLDER_NAME}
#FOLDER_FULL_PATH=/Users/sachin/work/ws_sachin/sachin-angular-temp/dist/sachin-angular-temp

IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
echo 'IP_ADDRESS = '${IP_ADDR}
echo 'FOLDER_FULL_PATH = '${FOLDER_FULL_PATH}

#  -p 80:80 \
# --net host \
docker kill nginx || true;
docker rm nginx || true;

docker run -d --rm --name nginx \
  --add-host="sachin-mac:${IP_ADDR}" \
  -p 80:80 \
  -p 443:443 \
  -v ${SCRIPT_DIR}/conf_and_data/conf.d:/etc/nginx/conf.d \
  -v ${SCRIPT_DIR}/conf_and_data/nginx.conf:/etc/nginx/nginx.conf \
  -v ${FOLDER_FULL_PATH}:/usr/share/nginx/html \
  nginx:latest



containerId=$(docker inspect --format="{{.Id}}" nginx)

#indexFileLoc='/usr/share/nginx/html/index.html'

#docker exec -i nginx bash <<EOF
#	echo "Container ID : ${containerId}" >> "${indexFileLoc}"
#exit
#EOF

echo "Tailing the logs.....hit the webpage at http://$MACHINE_ALIAS"
echo "Tailing the logs.....hit the webpage at https://$MACHINE_ALIAS"

sleep 1

docker logs -f nginx

#  -v ${SCRIPT_DIR}/conf_and_data/html:/usr/share/nginx/html \