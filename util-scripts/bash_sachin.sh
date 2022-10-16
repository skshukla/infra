#!/usr/bin/env bash


BASEDIR=$(dirname "$0")


# Bash My AWS
export PATH="$PATH:$HOME/.bash-my-aws/bin"
source ~/.bash-my-aws/aliases

source $BASEDIR/vm-util.sh


#echo 'Entering .bash_profile....'
alias c='clear'
alias ll=' ls -ltra'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Maven aliases
alias mcg='mvn clean generate-sources -DskipTests'
alias mci='mvn clean install -DskipTests'
alias mcp='mvn clean package -DskipTests'
alias mct='mvn clean test'
alias mdr='mvn dependency:resolve'
alias mdt='mvn dependency:tree'


alias t1='cd ~/tmp/t1'
alias t2='cd ~/tmp/t2'
alias t3='cd ~/tmp/t3'
alias t4='cd ~/tmp/t4'
alias t5='cd ~/tmp/t5'
alias gcdi='git checkout dev-initial'
alias gpdi='git pull origin dev-initial'
alias grdi='git reset --hard origin/dev-initial'


# GIT shortcuts
alias gp='git pull'
alias gs='git status --short'

#alias pip='/Library/Frameworks/Python.framework/Versions/3.6/bin/pip3'
#alias python='/Library/Frameworks/Python.framework/Versions/3.6/bin/python3.6'

#####

####
export MAVEN_HOME=~/softwares/maven
export GRADLE_HOME=/usr/local/Cellar/gradle/5.6
export M2_HOME=$MAVEN_HOME



export KAFKA_HOME=/Users/sachin/softwares/kafka
export MAVEN_HOME=/Users/sachin/softwares/maven
export SPARK_HOME=/Users/sachin/softwares/spark
export ZK_HOME=/Users/sachin/softwares/zookeeper



export JAVA_HOME=/Users/sachin/softwares/java/Contents/Home
#export JAVA11_HOME=/Users/sachin/softwares/java11/Contents/Home
#export JAVA_HOME=/Users/sachin/softwares/jdk-11.0.4.jdk/Contents/Home

export PATH=~/workspace/skshukla/infra/util-scripts:$JAVA_HOME/bin:$MAVEN_HOME/bin:$ZK_HOME/bin:${GRADLE_HOME}/bin:$KAFKA_HOME/bin:/usr/local/opt/libpq/bin:$PATH


# Setting PATH for Python 2.7
# The original version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
#export PATH

# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:/Users/sachin/softwares/bins:${PATH}"
PATH="/Users/sachin/softwares/bins:${PATH}"
export PATH




export GRADLE_OPTS="-Xms1024m -Xmx2048m"
export JAVA_OPTS="-Xms1024m -Xmx2048m"

alias .fixIP='sudo bash -c "$(declare -f updateHostFileForCurrentIP); updateHostFileForCurrentIP"'




alias .encryption="cd /Users/sachin/work/workspaces/ws_sks336/SachinWSNew/PasswordEncryption/target && java -cp '.:PasswordEncryption-1.0.0.jar:dependency/*' sachin.EncryptionUtil /Users/sachin/work/keys"

# Infra Alias
alias k='kubectl'
alias kn='kubectl -n $NS'
export KUBECONFIG=/Users/sachin/.kube/config
alias .refreshMinikubeIP='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/scripts/refreshMinikubeIP.sh'
# --
alias .kafka='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/kafka/run.sh'
alias .mongo='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/mongodb/run.sh'

alias .nginx='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/nginx/run.sh'
alias .postgres='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/postgres/run.sh'
alias .redis='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/redis/run.sh'

alias .zookeeper='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/zookeeper/run.sh'
alias .ks='/Users/sachin/workspace/skshukla/KafkaStreamProject/scripts/kafka-stream.sh -s vm-minikube:30092,vm-minikube:30093,vm-minikube:30094'

alias .kc='/Users/sachin/work/workspaces/ws_skshukla/KubernetesSample/kafka-connect/run.sh'
alias .vm-reboot='/Users/sachin/work/workspaces/ws_sks336/VagrantProj/projects/250_run_kubernetes_cluster/scripts/reboot.sh'



