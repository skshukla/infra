#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh
sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"


CONTAINERS_KAFKA_ZK="run_kafka-kafka-server-1 run_kafka-zookeeper-1"

CONTAINER_KAFKA=$(echo $CONTAINERS_KAFKA_ZK | cut -d' ' -f1)


function createTempDir() {
    rm -rf $SCRIPT_DIR/.tmp && mkdir -p $SCRIPT_DIR/.tmp/ssl
}



function createStoresData() {
  createTempDir
  openssl genrsa -out $SCRIPT_DIR/.tmp/ssl/ca.key

  echo -e "SG\nSingapore\nSingapore\nMYCOMP\ndev\n$MACHINE_ALIAS\na@a.com" | openssl req -new -x509 -key $SCRIPT_DIR/.tmp/ssl/ca.key -out $SCRIPT_DIR/.tmp/ssl/ca.crt
  echo -e '123456\n123456\nyes' | keytool -keystore $SCRIPT_DIR/.tmp/ssl/kafka.truststore.jks -alias CARoot -import -file $SCRIPT_DIR/.tmp/ssl/ca.crt

  echo -e '123456\n123456\nSachin Shukla\ndev\nMYCOMP\nSingapore\nSingapore\nSG\nyes' | keytool -keystore $SCRIPT_DIR/.tmp/ssl/kafka.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:$MACHINE_ALIAS

  echo -e '123456' | keytool -keystore $SCRIPT_DIR/.tmp/ssl/kafka.keystore.jks -alias localhost -certreq -file $SCRIPT_DIR/.tmp/ssl/kafka.unsigned.crt


  openssl x509 -req -CA $SCRIPT_DIR/.tmp/ssl/ca.crt -CAkey $SCRIPT_DIR/.tmp/ssl/ca.key -in $SCRIPT_DIR/.tmp/ssl/kafka.unsigned.crt -out $SCRIPT_DIR/.tmp/ssl/kafka.signed.crt -days 365 -CAcreateserial


  echo -e '123456\nyes' | keytool -keystore $SCRIPT_DIR/.tmp/ssl/kafka.keystore.jks -alias CARoot -import -file $SCRIPT_DIR/.tmp/ssl/ca.crt
  echo '123456' | keytool -keystore $SCRIPT_DIR/.tmp/ssl/kafka.keystore.jks -alias localhost -import -file $SCRIPT_DIR/.tmp/ssl/kafka.signed.crt


echo "bootstrap.servers=$MACHINE_ALIAS:39093
security.protocol=SSL
ssl.truststore.location=${SCRIPT_DIR}/.tmp/ssl/kafka.truststore.jks
ssl.truststore.password=123456
ssl.keystore.location=${SCRIPT_DIR}/.tmp/ssl/kafka.keystore.jks
ssl.keystore.password=123456
ssl.key.password=123456
ssl.endpoint.identification.algorithm=

">$SCRIPT_DIR/.tmp/ssl/client-ssl-host.properties

}


for c in $CONTAINERS_KAFKA_ZK; do
  echo 'c=>>>>>>>>>>> '$c
  docker kill $c || true;
  sleep 1
  docker rm $c || true;
  sleep 1
done

createStoresData

cd ${SCRIPT_DIR}
docker compose -f docker-compose-ssl.yaml up -d

sleep 4


echo "Tailing to logs...... >> docker logs $CONTAINER_KAFKA"
docker logs  $CONTAINER_KAFKA


echo 'Done!!!!'
