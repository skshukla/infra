#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker build -t sachin-kafka ${SCRIPT_DIR}/kafka
#docker build -t sachin-zookeeper ${SCRIPT_DIR}/zookeeper