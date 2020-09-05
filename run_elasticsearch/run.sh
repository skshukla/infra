#!/usr/bin/env bash


MULTI_NODE="false"
SETUP_KIBANA="true"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../common-vars.sh
source $SCRIPT_DIR/../util-scripts/vm-util.sh

sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP ${MACHINE_ALIAS}"


IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
echo 'IP_ADDRESS = '${IP_ADDR}

if [ "${MULTI_NODE}" == "false" ]; then

  docker kill es_single_node || true;
  docker run -d --rm --name es_single_node \
    --add-host="${MACHINE_ALIAS}:${IP_ADDR}" \
    -p 9200:9200 \
    -p 9300:9300 \
    -e "discovery.type=single-node" \
    docker.elastic.co/elasticsearch/elasticsearch:7.1.0

    sleep 3
    docker logs es_single_node

else
      docker kill es01 es02 es03 || true;
      docker rm es01 es02 es03 || true;
      cd ${SCRIPT_DIR} && docker-compose up -d
      sleep 3
      docker logs es01
fi

# sysctl -w vm.max_map_count=262144 (Inside the container)
echo ''
echo "Access the node/cluster at ......  http://${MACHINE_ALIAS}:9200/_cat/nodes?v&pretty"
echo "Access the node/cluster at ......  http://${MACHINE_ALIAS}:9200/_cat/indices?v&pretty"
echo "Usually it takes apprx 30 seconds to get it up and running....."



if [[ "${SETUP_KIBANA}" == "true" ]]; then
  echo 'Going to setup Kibana also....'
  docker run --rm -d \
    --add-host="${MACHINE_ALIAS}:${IP_ADDR}" \
    --name kibana \
    -p 5601:5601 \
    -e "ELASTICSEARCH_HOSTS=http://${MACHINE_ALIAS}:9200" \
    docker.elastic.co/kibana/kibana:7.1.0
else
  echo 'Skipping Kibana setup....'
fi


