#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh
sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"


CONTAINERS_KAFKA_ZK="run_kafka_kafka-server1_1 run_kafka_kafka-server2_1 run_kafka_kafka-server3_1 run_kafka_zookeeper_1"

CONTAINER_KAFKA=$(echo $CONTAINERS_KAFKA_ZK | cut -d' ' -f1)

function createSampleRecords() {
    KAFKA_MC_IP_ADDR=$(${SCRIPT_DIR}/../util-scripts/.myIP) && echo 'KAFKA_MC_IP_ADDR='$KAFKA_MC_IP_ADDR
    BROKER_LIST=${KAFKA_MC_IP_ADDR}:9092,${KAFKA_MC_IP_ADDR}:9093,${KAFKA_MC_IP_ADDR}:9094
    ZK_LIST=${KAFKA_MC_IP_ADDR}:2181
    KAFKA_HOME=~/softwares/kafka

    TOPIC=test-topic-1 &&  ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper localhost:2181 --partitions 1  --replication-factor 1 --topic $TOPIC
    TOPIC=test-topic-2 &&  ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper localhost:2181 --partitions 3  --replication-factor 1 --topic $TOPIC

    TOPIC=test-topic-1 && ${KAFKA_HOME}/bin/kafka-topics.sh --describe --zookeeper ${ZK_LIST} --topic $TOPIC
    TOPIC=test-topic-2 && ${KAFKA_HOME}/bin/kafka-topics.sh --describe --zookeeper ${ZK_LIST} --topic $TOPIC
}


for c in $CONTAINERS_KAFKA_ZK; do
  echo 'c=>>>>>>>>>>> '$c
  docker kill $c || true;
  docker rm $c || true;
done

cd ${SCRIPT_DIR}
docker-compose up -d

sleep 4


echo "Tailing to logs...... >> docker logs $CONTAINER_KAFKA"
docker logs  $CONTAINER_KAFKA



echo ''
echo "Sample commands : ====>>"
echo ''


echo '
=============>
docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 3 --partitions 3 --topic mytopic

docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic mytopic

docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --list --zookeeper zookeeper:2181

docker exec -it run_kafka_kafka-server1_1 kafka-console-producer.sh --broker-list kafka-server1:9092 --topic mytopic

docker exec -it run_kafka_kafka-server1_1 kafka-console-consumer.sh --bootstrap-server kafka-server1:9092 --topic mytopic --from-beginning
<====
'


createSampleRecords
