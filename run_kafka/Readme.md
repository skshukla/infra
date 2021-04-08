Running the *run_kafka.sh* shell script file would bring up 3 node kafka cluster and one zookeeper. It internally creates some variations of topics too. Finally there are some useful commands echoed which would help developer to test the cluster. specially console producer and consumer command can be hit in two different shells and message can be produced/consumed.






###### Trigger Preferred-Leader Partition.

```shell
docker exec -it run_kafka_kafka-server1_1 kafka-preferred-replica-election.sh --zookeeper zookeeper:2181
```

###### Trigger Preferred-Leader Partition.

```bash
docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 2 --partitions 3 --topic test-topic-03
docker exec -it run_kafka_kafka-server1_1 kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic test-topic-03
docker exec -it run_kafka_kafka-server1_1 /bin/sh -c "echo '{\"topics\":[{\"topic\":\"test-topic-03\"}],\"version\":1}' > /tmp/reassign-topics.json"
docker exec -it run_kafka_kafka-server1_1 cat /tmp/reassign-topics.json
docker exec -it run_kafka_kafka-server1_1 kafka-reassign-partitions.sh --zookeeper zookeeper:2181  --generate --topics-to-move-json-file /tmp/reassign-topics.json --broker-list 1001,1002

```
-- Now get the content of above command and save in file in below path `/tmp/reassign.json` and execute the below command
```bash
docker exec -it run_kafka_kafka-server1_1 kafka-reassign-partitions.sh --zookeeper zookeeper:2181 --execute --reassignment-json-file /tmp/reassign.json
```


