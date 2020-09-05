#!/usr/bin/env bash


POD_NAME=$1
INTERVAL=$2


if [ -z $POD_NAME ]; then
    echo 'Enter the POD name to be monitored!!'
    exit 0;
fi

if [ -z $INTERVAL ]; then
    INTERVAL=4
fi

echo 'POD_NAME='$POD_NAME', INTERVAL='$INTERVAL

##

while clear; do date; /bin/sh -c "kubectl get pods -n ${ENV_VAL_KUBE} -o wide --all-namespaces --show-labels | grep $POD_NAME";sleep $INTERVAL; done