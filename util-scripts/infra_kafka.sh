#!/usr/bin/env bash

CONTAINER=run_kafka_kafka_1
KAFKA_BROKERS=localhost:9092
ZK_BROKERS=localhost:2181
STREAM_TOPIC=test-stream


supported_options="usage to-file to-kafka read-kafka read-topic list-topics"

function usage() {
  echo 'Usage of the script with valid options are as below.'
  echo "infra_kafka.sh ${supported_options// /|}"
  exit
}


function get_options() {
    if [[ -z "$1" ]]; then
      echo 'command invoked with no option. Chosing the default one {usage}.'
      export OPTION="usage"
    else
      export OPTION=$1
    fi

    EXISTS="false"

    for f in $supported_options; do
      if [[ "$f" == "$OPTION" ]]; then
        EXISTS="true"
      fi
    done

    if [[ "${EXISTS}" == "false" ]]; then
      usage
      exit
    fi
}

function load_stream_to_file() {
    echo 'Going to load realtime stream in file... Do not forget to kill the process which is loading content in file {/tmp/a.out} ....'
    curl -s http://stream.meetup.com/2/rsvps -o /tmp/a.out
}

########################################################################################################################
get_options $1

if [[ "$OPTION" == "usage" ]]; then
  usage
  exit
elif [[ "$OPTION" == "to-file" ]]; then
  load_stream_to_file
elif [[ "$OPTION" == "to-kafka" ]]; then
  echo 'Going to push content to kafka.....'
  tail -f /tmp/a.out | ${KAFKA_HOME}/bin/kafka-console-producer.sh --broker-list ${KAFKA_BROKERS} --topic ${STREAM_TOPIC}
elif [[ "$OPTION" == "list-topics" ]]; then
  echo 'Going to list topics of kafka.....'
  docker exec -it ${CONTAINER} /opt/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper:2181
elif [[ "$OPTION" == "read-kafka" ]]; then
  echo 'Going to read content from kafka.....'
#  ${KAFKA_HOME}/bin/kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKERS}  --topic test-stream  --from-beginning
  docker exec -it ${CONTAINER} /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKERS}  --topic test-stream  --from-beginning
elif [[ "$OPTION" == "read-topic" ]]; then
  if [[ -z ${TOPIC} ]]; then
    echo 'Variable "TOPIC" not set, exiting, please set this variable to a valid kafka topic.'
    exit
  fi
  echo "Going to read content from kafka topic {${TOPIC}}"
  docker exec -it ${CONTAINER} /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKERS}  --topic ${TOPIC}  --from-beginning
fi
########################################################################################################################

