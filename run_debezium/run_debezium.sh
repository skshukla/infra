#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh
sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"

echo 'Starting Debezium process....'

.dockerKillAndRemoveAllContainers

#docker kill debezium || true;


nohup .infra.sh postgres kafka > /tmp/out.log &

echo 'Command to tail the infra logs for postgres and kafka : ==>'
echo 'tail -200f /tmp/out.log'

echo 'Going to sleep for infra to be up and running.....'
sleep 15
echo 'Woke up.....'

IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
echo 'IP_ADDRESS = '${IP_ADDR}

docker run --rm --name debezium -d -p 8083:8083 \
    --add-host="${MACHINE_ALIAS}:${IP_ADDR}" \
    -h debezium \
    -e GROUP_ID=g1 \
    -e CONFIG_STORAGE_TOPIC=my_connect_configs \
    -e OFFSET_STORAGE_TOPIC=my_connect_offsets \
    -e STATUS_STORAGE_TOPIC=my_connect_statuses \
    --link run_kafka_zookeeper_1:zookeeper \
    --link run_kafka_kafka_1:kafka \
    --link sachin_pg:vm_postgres \
    debezium/connect

docker logs -f debezium
