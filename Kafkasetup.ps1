#https://github.com/confluentinc/cp-docker-images/wiki/Getting-Started
#Run zookeeper confluentinc/cp-zookeeper:5.0.1
docker run -d --net=host --name=zookeeper -e ZOOKEEPER_CLIENT_PORT=2181 -e ZOOKEEPER_TICK_TIME=2000 confluentinc/cp-zookeeper:5.0.1
docker logs zookeeper
#run kafka
docker run -d --net=host --name=kafka -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 confluentinc/cp-kafka:5.0.1
docker logs kafka
#create a topic
docker run --net=host --rm confluentinc/cp-kafka:5.0.1 kafka-topics --create --topic jaeger-spans --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:2181
docker run --net=host --rm confluentinc/cp-kafka:5.0.1 kafka-topics --describe --topic jaeger-spans --zookeeper localhost:2181
#generetae data
docker run --net=host --rm confluentinc/cp-kafka:5.0.1 bash -c "seq 42 | kafka-console-producer --broker-list localhost:9092 --topic jaeger-spans && echo 'Produced 42 messages.'"
#readback data
docker run --net=host --rm confluentinc/cp-kafka:5.0.1 kafka-console-consumer --bootstrap-server localhost:9092 --topic jaeger-spans -from-beginning --max-messages 42

docker exec -it $(docker ps -qf "name=kafka") /bin/bash
kafka-server-stop
kafka-server-start -daemon config/server.properties
kafka-consumer-groups --bootstrap-server kafka:9092 --describe --group jaeger-ingester

#kafka consumer
kafka-console-consumer --bootstrap-server kafka:9092 --topic jaeger-spans
#kafka producer
bash -c "seq 42 | kafka-console-producer --broker-list kafka:9092 --topic jaeger-spans && echo 'Produced 42 messages.'"