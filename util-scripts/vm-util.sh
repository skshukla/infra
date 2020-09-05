#!/bin/bash

#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#source $SCRIPT_DIR/../common-vars.sh
#echo 'Inside vm-util.sh file, MACHINE_ALIAS='$MACHINE_ALIAS

function healthCheck() {
URL=$1
INTERVAL=$2
TIMEOUT=$3
N_TRIES=$((TIMEOUT/INTERVAL))
echo "Health check for URL {$URL}, with TIMEOUT {$TIMEOUT}, INTERVAL {$INTERVAL} and N_TRIES="$N_TRIES

GOT_RESPONSE="false"
for ((i=0;i<N_TRIES;i++)); do
    STATUS_CODE=$(curl -sSI $URL | head -1 | cut -d$' ' -f2)
    echo 'STATUS_CODE='$STATUS_CODE
    GOT_RESPONSE='true'
    if [[ -z ${STATUS_CODE} || "${STATUS_CODE}" == "404" ]]; then
        GOT_RESPONSE='false';
    fi
    if [[ "${GOT_RESPONSE}" == "false" && ${i} -lt $((N_TRIES-1)) ]]; then
        echo "URL not up, Going to sleep for {$INTERVAL} seconds. i is {$i}, N_TRIES is {$N_TRIES}"
        sleep $INTERVAL
    elif [ "${GOT_RESPONSE}" == "false" ]; then
        echo "Timeout reached, server is yet not responding. i is {$i}, N_TRIES is {$N_TRIES}"
        break;
    else
        echo "Server responded with Status code {$STATUS_CODE}. i is {$i}, N_TRIES is {$N_TRIES}"
        break;
    fi

done
echo 'Returning from healthCheck()..'

}


function makeHostAndBashEntries() {
    IFS=
    bash_entries=$(curl -sS https://raw.githubusercontent.com/sks336/vm-repo/master/config/bash_entries.txt)
    echo ${bash_entries} > /home/sachin/.bashrc
}

function updateHostFileForCurrentIP() {
    MACHINE_ALIAS=$1
    IP_ADDR=$(ifconfig | grep -A 3 'en0' | grep inet | grep netmask | awk '{print $2}')
    echo 'IP_ADDRESS IS = '${IP_ADDR}', MACHINE_ALIAS='${MACHINE_ALIAS}
    HOST_FILE="/private/etc/hosts"

    sed -i '' "/${MACHINE_ALIAS}/d" ${HOST_FILE}
    echo "${IP_ADDR}    ${MACHINE_ALIAS}" >> ${HOST_FILE}

    cat ${HOST_FILE}
}


function makeBashEntries() {
    IFS=
    bash_entries=$(curl -sS https://raw.githubusercontent.com/sks336/vm-repo/master/config/bash_entries.txt)
    echo ${bash_entries} > /home/sachin/.bashrc
}

function refreshIPsFromConsul() {
CONSUL_IP=192.168.109.11
HOST_FILE=/etc/hosts
if [[ "$(uname -s)" != "Linux" ]]; then
        HOST_FILE=/private/etc/hosts
fi
echo 'HOST_FILE='${HOST_FILE}
nServices=$(curl -sS http://${CONSUL_IP}:8500/v1/catalog/services | jq keys | jq length)
entriesFromConsul=''
for ((i=0;i<nServices;i++)); do
        CMD="curl -sS http://${CONSUL_IP}:8500/v1/catalog/services | jq keys | jq -r '.[$i]'"
        serviceName=$(/bin/sh -c $CMD)
        #echo 'serviceName is'$serviceName
        if [[ "${serviceName}" == "consul" ]]; then
                echo 'Ignore consul service entries' > /dev/null 2>&1
        else
                serviceJSON=$(curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${serviceName})
                nMachines=$(curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${serviceName} | jq length)
                #echo 'nMachines='$nMachines
                for ((j=0;j<nMachines;j++)); do
                machineJSON=$(/bin/sh -c "curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${serviceName} | jq '.[$j]'")
                #echo 'machineJSON='$machineJSON
                ip=$(echo $machineJSON | jq -r .ServiceAddress)
                vmName="vm-"$(echo $machineJSON | jq -r .ServiceID)
                hostEntry="${ip}"$'\t'"${vmName}"
                entriesFromConsul=${entriesFromConsul}${hostEntry}$'\n'
                done
        fi
done

echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
255.255.255.255 broadcasthost
127.0.0.1       vm-sachin
192.168.0.120   vm-0
192.168.109.11  vm-consul-vault-1
192.168.109.12  vm-consul-vault-2
192.168.109.13  vm-consul-vault-3
########################################
127.0.0.1 kafka-dev
114.143.142.228 zenit.global
54.169.99.65 reality.deskera.com
'>${HOST_FILE}

echo "$entriesFromConsul" >> ${HOST_FILE}
echo 'Host Entry cleaned....'
cat ${HOST_FILE}
}

function waitForIPAddressPopulation() {
    TIMEOUT=$1
    INTERVAL=$2
    ATTEMPT_COUNT=$(($TIMEOUT/$INTERVAL))
    echo "TIMEOUT=$TIMEOUT, INTERVAL=$INTERVAL, ATTEMPT_COUNT=$ATTEMPT_COUNT"
    i=1
        while [ "$i" -le "$ATTEMPT_COUNT" ]; do
            if [ "$ATTEMPT_COUNT" = "$i" ]; then
                echo 'Reached Time Out!!!!'
                ifconfig | grep -A 5 'eth1'
                return 1;
            fi
            IP_ADDR=$(ifconfig | grep -A 3 'eth1' | grep inet | grep netmask | awk '{print $2}')
            if [ ! -z $IP_ADDR ]; then
                echo 'IP Address is available and having value as ['${IP_ADDR}'] with HostName as ['$(hostname -f)']'
                return 0;
            fi
            echo '['$i'] - IP not available yet, would be attempted again in '$INTERVAL' seconds'
            sleep $INTERVAL
            i=$(($i + 1))
        done

}

function registerToConsul() {
    NODE_ID=$1
    NODE_TYPE=$2
    CONSUL_IP=192.168.109.11
    IP_ADDR=$(ifconfig | grep -A 3 'eth1' | grep inet | grep netmask | awk '{print $2}')
    find ${HOME}/resources/config/consul/service -type f | xargs sed -i  "s/<ID>/${NODE_ID}/g"
    find ${HOME}/resources/config/consul/service -type f | xargs sed -i  "s/<NODE_ID>/${IP_ADDR}/g"
    find ${HOME}/resources/config/consul/service -type f | xargs sed -i  "s/<NODE_TYPE>/${NODE_TYPE}/g"
    nohup consul agent -node ${IP_ADDR} -bind '{{ GetInterfaceIP "eth1" }}' -retry-join "${CONSUL_IP}" -config-dir ${HOME}/resources/config/consul/service -data-dir /tmp/consul --enable-local-script-checks=true > ${HOME}/consul.out &
    echo 'Services registered to Consul..'
}

function deregisterService() {
    SERVICE_NAME=$1
    CONSUL_IP=192.168.109.11
    if [ -z ${SERVICE_NAME} ]; then
        echo 'SERVICE_NAME not provided, exiting!!!!'
        return;
    fi
    nServiceNodes=$(curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${SERVICE_NAME} | jq length)
    str=''
    for ((i=0;i<nServiceNodes;i++)); do
        serviceID=$(/bin/sh -c "curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${SERVICE_NAME} | jq -r '.[$i]'.ServiceID")
        ip=$(curl -sS http://${CONSUL_IP}:8500/v1/catalog/service/${SERVICE_NAME} | jq -r .[$i].Address)
        str=${str}" "${ip}"_""${serviceID}"
    done
    echo "[${str}]"

for e in ${str}; do
    ip=$(echo $e | cut -d '_' -f 1)
    serviceID=$(echo $e | cut -d '_' -f 2)
    echo 'ip='$ip', serviceID='$serviceID
    deregisterCmd="curl -sS --request PUT http://127.0.0.1:8500/v1/agent/service/deregister/${serviceID}"
    echo "${deregisterCmd}" | ssh sachin@${ip} -T "/bin/bash"
done
}

function healthCheck() { # healthCheck $1 $2 $3
URL=$1
INTERVAL=$2
TIMEOUT=$3
N_TRIES=$((TIMEOUT/INTERVAL))
echo "Health check for URL {$URL}, with TIMEOUT {$TIMEOUT}, INTERVAL {$INTERVAL} and N_TRIES="$N_TRIES

GOT_RESPONSE="false"
for ((i=0;i<N_TRIES;i++)); do
    STATUS_CODE=$(curl -sSI $URL | head -1 | cut -d$' ' -f2)
    echo 'STATUS_CODE='$STATUS_CODE
    GOT_RESPONSE='true'
    if [[ -z ${STATUS_CODE} || "${STATUS_CODE}" == "404" ]]; then
        GOT_RESPONSE='false';
    fi
    if [[ "${GOT_RESPONSE}" == "false" && ${i} -lt $((N_TRIES-1)) ]]; then
        echo "URL not up, Going to sleep for {$INTERVAL} seconds. i is {$i}, N_TRIES is {$N_TRIES}"
        sleep $INTERVAL
    elif [ "${GOT_RESPONSE}" == "false" ]; then
        echo "Timeout reached, server is yet not responding. i is {$i}, N_TRIES is {$N_TRIES}"
        break;
    else
        echo "Server responded with Status code {$STATUS_CODE}. i is {$i}, N_TRIES is {$N_TRIES}"
        break;
    fi

done
echo 'Returning from healthCheck()..'

}
