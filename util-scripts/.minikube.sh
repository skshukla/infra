#!/usr/bin/env bash

supported_options="usage force-clean-start clean-start restart start stop watch-pods watch-infra alias"

function usage() {
  echo 'Usage of minikube script with valid options are as below.'
  echo ".minikube.sh ${supported_options// /|}"
  exit
}

function get_options() {
    if [[ -z "$1" ]]; then
      echo 'minikube invoked with no option. Chosing the default one {restart}.'
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

function run_minikube() {

    if [[ "$1" == "stop" ]]; then
      echo 'Going to stop (Only) the minikube cluster.... (Not stopping the infra containers!)'
      minikube stop
      exit
    elif [[ "$1" == "start" ]]; then
      echo 'Going to start the minikube cluster....'
      minikube start
    elif [[ "$1" == "restart" ]]; then
      echo 'Going to re-start the minikube cluster....'
      minikube stop
      minikube start
    elif [[ "$1" == "watch-pods" ]]; then
      echo 'Going 2 watch the pods in minikube cluster....'
      source .minikube_env.sh set
      while clear; do date; /bin/sh -c "kubectl get pods -o wide --all-namespaces --show-labels";sleep 3; done
      exit
    elif [[ "$1" == "watch-infra" ]]; then
      echo 'Going to watch the infra in local machine (not in MiniKube Cluster)....'
      source .minikube_env.sh unset
      while clear; do date; /bin/sh -c "docker ps -a";sleep 3; done
      exit
    elif [[ "$1" == "clean-start" ]]; then ##  Most of the time clean-start would be needed to start afresh.
      echo 'Clean start is true, cleaning up minikube directories..'
#      ${HOME}/work/workspace/ms-run-locally/src/main/scripts/run_infra.sh
      minikube delete
#      rm -rf /tmp/minikube_tmp_dir && mkdir -p /tmp/minikube_tmp_dir
#      minikube start --vm-driver=virtualbox --cpus 4 --memory 8192 --mount-string /tmp/minikube_tmp_dir:/data --mount
      minikube start --vm-driver=virtualbox --cpus 4 --memory 8192
    elif [[ "$1" == "force-clean-start" ]]; then
      echo 'Force clean start is true, cleaning up minikube directories..including the iso image files.'
#      ${HOME}/work/workspace/ms-run-locally/src/main/scripts/run_infra.sh
      minikube delete
      rm -rf ~/.kube && rm -rf .minikube
#      rm -rf /tmp/minikube_tmp_dir && mkdir -p /tmp/minikube_tmp_dir
      minikube start --vm-driver=virtualbox --cpus 4 --memory 8192
    fi

    source .minikube_env.sh set

#    update_host_entries
    pull_base_images

#    ${HOME}/work/workspace/ms-run-locally/src/main/scripts/run_all_apps.sh
}

function update_host_entries() {
 export VMIP=$(echo $(minikube ssh "route -n | grep ^0.0.0.0 | awk '{ print \$2 }'") | tr -d '\r')
 awk '!/vm-sachin-mac/' /private/etc/hosts > /tmp/host_tmp
 echo "$VMIP vm-sachin-mac" >> /tmp/host_tmp
 IFS=' '
 cat /tmp/host_tmp
 sudo cat /tmp/host_tmp > /private/etc/hosts
}

function pull_base_images() {
    docker pull openjdk:8u222-jre-slim-buster
    docker pull node:alpine
    docker images
}

function echo_useful_commands() {
    echo ''
    echo '************************ Run below handy commands for quick information.....************************ '

#    echo ''
#    echo '*** Command to see the logs.'
#    echo 'tail -f /Users/sachin/work/workspace/ms-run-locally/src/main/scripts/apps/logs/*.log'

    echo ''
    echo '*** Command to setup shell for Minikube'
    echo 'source .minikube_env.sh set'

    echo ''
    echo '*** Command to watch the docker containers'
    echo ".minikube.sh watch-infra"

    echo ''
    echo '*** Command to watch the kubernetes deployment and services'
    echo ".minikube.sh watch-pods"

#    echo ''
#    echo '*** Command to setup the data and nginx rules (Need to be run once all services are deployed)'
#    echo '${HOME}/work/workspace/ms-run-locally/src/main/scripts/run_data_setup.sh'
#    echo ''
#    echo '*************************************************[ENDS]******************************'
}

function run_minikube_cluster() {

  if [[ -z "$1" || "$1" == "usage" ]]; then
      usage
      exit
  elif [[ "$1" == "alias" ]]; then
      echo_useful_commands
      exit
  fi
  run_minikube $1
  echo_useful_commands
}




##########################################################
export KUBECONFIG=~/.minikube/minikube-config
get_options $1
start=`date +%s`
run_minikube_cluster $OPTION
end=`date +%s`
execTime=$((end-start))
echo 'Execution time for minikube start = '$execTime' seconds.'
##########################################################






