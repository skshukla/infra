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


    TOPIC=test-topic-1 &&  docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic $TOPIC
    TOPIC=test-topic-2 &&  docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 3 --topic $TOPIC
    TOPIC=my-compacted-topic-01 &&  docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic $TOPIC \
      --config "cleanup.policy=compact" --config "delete.retention.ms=1000"  --config "segment.ms=1000" --config "min.cleanable.dirty.ratio=0.001"



    TOPIC=test-topic-1 && docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic $TOPIC
    TOPIC=test-topic-2 && docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic $TOPIC
    TOPIC=my-compacted-topic-01 && docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic $TOPIC

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
TOPIC=mytopic
docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 3 --partitions 3 --topic $TOPIC

docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic $TOPIC

docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --list --zookeeper zookeeper:2181

docker exec -it run_kafka_kafka-server1_1 kafka-console-producer.sh --broker-list kafka-server1:9092 --topic $TOPIC

docker exec -it run_kafka_kafka-server1_1 kafka-console-producer.sh --broker-list kafka-server1:9092 --topic $TOPIC --property parse.key=true --property key.separator=: ### To send key also

docker exec -it run_kafka_kafka-server1_1 kafka-console-consumer.sh --bootstrap-server kafka-server1:9092 --topic $TOPIC --property  print.key=true --property key.separator=: --from-beginning
<====
'


createSampleRecords

