#!/usr/bin/env bash

nArgs=$#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

config='{
  "es": "1",
  "kafka": "2",
  "nginx": "3",
  "postgres": "4",
  "redis": "5"
}'


entries=$(echo $config | jq -r 'keys[] as $k | "\($k):\(.[$k]) "')


#function usage() {
#  echo 'The script runs in two modes, one is invoked with just the script name without argument in that case it would display the supported objects it needs to create. e.g. execute ".infra.sh"'
#  echo 'The other mode is to invoke it with specific object by passing the arguments. it also supports multiple arguments. e.g. ".infra.sh es redis postgres" to run Elastic Search, Redis and Postgres"'
#}


function promptAppOptions() {

  for e in $entries; do
    IFS=':'; arrIN=($e); unset IFS;
    echo 'Enter ('${arrIN[1]}') to run "'${arrIN[0]}'"'
  done
    echo 'Enter (-1) to exit!!!'
}


function getObjectFromOption() {
  OPTION=$1
  for e in $entries; do
    IFS=':'; arrIN=($e); unset IFS;
    if [ "${arrIN[1]}" == "${OPTION}" ]; then
      chosenInfra=${arrIN[0]}
      echo 'Chosen Infra val = "'${chosenInfra}'"'
      return;
    fi
  done
  chosenInfra="-100"
}

function showUsage() {
    echo '.infra.sh {es|kafka|nginx|postgres|redis}'
}


##### Execute the main logic.....

#while getopts d:f: o; do
#  case $o in
#    (f) file=$OPTARG;;
#    (d) dir=$OPTARG;;
#    (h) help="true";;
#    (*) usage
#  esac
#done
#
#echo 'file='$file', dir='$dir
#shift "$((OPTIND - 1))"
#
#echo Remaining arguments: "$@"



LOG_DIR="/tmp/logs/infra"
if [ ! -d "${LOG_DIR}" ]; then
  echo "Log directory : {${LOG_DIR}} doesnot exists. Going to create!"
  mkdir -p ${LOG_DIR}
fi

if [[ "$1" = "usage" ]]; then
  showUsage
  exit;
fi

if [[ "${nArgs}" -gt 0 ]]; then
  for arg in "$@"; do
   if [[ "${arg}" == "es" ]]; then
    CMD="${SCRIPT_DIR}/../run_elasticsearch/run.sh"
   elif [[ "${arg}" == "kafka" ]]; then
    CMD="${SCRIPT_DIR}/../run_kafka/run_kafka.sh"
   elif [[ "${arg}" == "nginx" ]]; then
    CMD="${SCRIPT_DIR}/../run_nginx/run.sh"
   elif [[ "${arg}" == "postgres" ]]; then
    CMD="${SCRIPT_DIR}/../run_postgres/run_postgres.sh"
   elif [[ "${arg}" == "redis" ]]; then
    CMD="${SCRIPT_DIR}/../run_redis/run_redis.sh"
   else
    echo 'Argument {'${arg}'} not found, Exiting!!....'
    exit
   fi

    >${LOG_DIR}/${arg}.log
    nohup $CMD > ${LOG_DIR}/${arg}.log &
  done
  echo "Execute the command to see the logs>>>"
  echo "tail -100f ${LOG_DIR}/*.log"
  exit
fi




echo 'Enter the app option you want to run :'
for (( ; ; ))
do
   promptAppOptions
   read appOption
   if
     [ "$appOption" == "-1" ]; then
     echo 'Good bye!!'
     break
   else
     getObjectFromOption $appOption

      if [ "${chosenInfra}" == "-100" ]; then
        echo 'Chose the right option!!'
      else
        CMD='.run_'${chosenInfra}'.sh'
        $CMD
      fi

   fi

done





