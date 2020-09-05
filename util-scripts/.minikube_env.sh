#!/usr/bin/env bash


supported_options="usage set unset"

function usage() {
  echo 'Usage of the script with valid options are as below.'
  echo "source .minikube_env.sh ${supported_options// /|}"
  exit
}

function get_options() {
    if [[ -z "$1" || "$1" == "set" ]]; then
      echo 'Going to {set} the environment for Mini-Kube....'
      export ENV_SETUP="set"
    else
      echo 'Going to {unset} the environment for Mini-Kube....'
      export ENV_SETUP="unset"
    fi
}


function set_minikube_docker_env_vars() {
    export KUBECONFIG=~/.minikube/minikube-config
    eval $(minikube docker-env)
    minikube update-context
}

function unset_minikube_docker_env_vars() {
    unset DOCKER_TLS_VERIFY
    unset DOCKER_HOST
    unset DOCKER_CERT_PATH
    unset KUBECONFIG
}

function print_minikube_envs() {
  echo 'KUBECONFIG='$KUBECONFIG
  echo 'DOCKER_TLS_VERIFY='$DOCKER_TLS_VERIFY
  echo 'DOCKER_HOST='$DOCKER_HOST
  echo 'DOCKER_CERT_PATH='$DOCKER_CERT_PATH
}


##########################################################

if [[ "$1" == "usage" ]]; then
      usage
      exit
fi

get_options $1



if [[ "${ENV_SETUP}" == "unset" ]]; then
    unset_minikube_docker_env_vars
else
    set_minikube_docker_env_vars
fi

print_minikube_envs
#############################






