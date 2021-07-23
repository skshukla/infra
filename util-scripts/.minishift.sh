#!/usr/bin/env bash


#supported_options="usage force-clean-start clean-start restart start stop watch-pods watch-infra alias"
supported_options="usage force-clean-start"

function usage() {
  echo 'Usage of minishift script with valid options are as below.'
  echo ".minishift.sh ${supported_options// /|}"
  exit
}

function set_minishift_docker_env_vars() {
    export KUBECONFIG=~/.minishift/minishift-config
    eval $(minishift docker-env)
    minishift update-context
}

function unset_minishift_docker_env_vars() {
    unset DOCKER_TLS_VERIFY
    unset DOCKER_HOST
    unset DOCKER_CERT_PATH
    unset KUBECONFIG
}

function get_options() {
    if [[ -z "$1" ]]; then
      echo 'minishift invoked with no option. Chosing the default one {restart}.'
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

function run_minishift() {

    if [[ "$1" == "stop" ]]; then
      echo 'Going to stop (Only) the minishift cluster.... (Not stopping the infra containers!)'
      minishift stop
      exit
    elif [[ "$1" == "start" ]]; then
      echo 'Going to start the minishift cluster....'
      minishift start
    elif [[ "$1" == "restart" ]]; then
      echo 'Going to re-start the minishift cluster....'
      minishift stop
      minishift start
    elif [[ "$1" == "watch-pods" ]]; then
      echo 'Going 2 watch the pods in minishift cluster....'
      source set_minishift_docker_env_vars
      while clear; do date; /bin/sh -c "kubectl get pods -o wide --all-namespaces --show-labels";sleep 3; done
      exit
    elif [[ "$1" == "watch-infra" ]]; then
      echo 'Going to watch the infra in local machine (not in minishift Cluster)....'
      source unset_minishift_docker_env_vars
      while clear; do date; /bin/sh -c "docker ps -a";sleep 3; done
      exit
    elif [[ "$1" == "clean-start" ]]; then ##  Most of the time clean-start would be needed to start afresh.
      echo 'Clean start is true, cleaning up minishift directories..'
      minishift delete
      minishift start --vm-driver=virtualbox --cpus 4 --memory 8192
    elif [[ "$1" == "force-clean-start" ]]; then
      echo 'Force clean start is true, cleaning up minishift directories..including the iso image files.'
      minishift delete
      rm -rf ~/.kube && rm -rf .minishift
      minishift start --vm-driver=virtualbox --cpus 4 --memory 8192
    fi

    source set_minishift_docker_env_vars
    pull_base_images
}

function update_host_entries() {
 export VMIP=$(echo $(minishift ssh "route -n | grep ^0.0.0.0 | awk '{ print \$2 }'") | tr -d '\r')
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
    echo '*** Command to setup shell for minishift'
    echo 'source .minishift_env.sh set'

    echo ''
    echo '*** Command to watch the docker containers'
    echo ".minishift.sh watch-infra"

    echo ''
    echo '*** Command to watch the kubernetes deployment and services'
    echo ".minishift.sh watch-pods"

#    echo ''
#    echo '*** Command to setup the data and nginx rules (Need to be run once all services are deployed)'
#    echo '${HOME}/work/workspace/ms-run-locally/src/main/scripts/run_data_setup.sh'
#    echo ''
#    echo '*************************************************[ENDS]******************************'
}

function run_minishift_cluster() {

  if [[ -z "$1" || "$1" == "usage" ]]; then
      usage
      exit
  elif [[ "$1" == "alias" ]]; then
      echo_useful_commands
      exit
  fi
  run_minishift $1
  echo_useful_commands
}




##########################################################
export KUBECONFIG=~/.minishift/minishift-config
get_options $1
start=`date +%s`
run_minishift_cluster $OPTION
end=`date +%s`
execTime=$((end-start))
echo 'Execution time for minishift start = '$execTime' seconds.'
##########################################################






