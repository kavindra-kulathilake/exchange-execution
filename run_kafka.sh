#!/bin/bash

# Set variables
NETWORK_NAME="kafka-net"
ZOOKEEPER_CONTAINER_NAME="zookeeper"
KAFKA_CONTAINER_NAME="kafka"
TOPIC_NAME="my-topic"
ZOOKEEPER_IMAGE="zookeeper:3.8"
KAFKA_IMAGE="docker.io/apache/kafka-native:3.8.0"
ZOOKEEPER_PORT=2181
KAFKA_PORT=9092

# Create a Podman network
echo "Creating Podman network: $NETWORK_NAME"
podman network create $NETWORK_NAME

# Run ZooKeeper container in the network
echo "Running ZooKeeper container..."
podman run -d --name $ZOOKEEPER_CONTAINER_NAME --network $NETWORK_NAME -p $ZOOKEEPER_PORT:$ZOOKEEPER_PORT $ZOOKEEPER_IMAGE

# Run Kafka container in the same network
echo "Running Kafka container..."
podman run -d --name $KAFKA_CONTAINER_NAME --network $NETWORK_NAME \
  -e KAFKA_ZOOKEEPER_CONNECT=$ZOOKEEPER_CONTAINER_NAME:$ZOOKEEPER_PORT \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:$KAFKA_PORT \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -p $KAFKA_PORT:$KAFKA_PORT \
  $KAFKA_IMAGE

# Wait for Kafka to be ready
echo "Waiting for Kafka to start up..."
RETRIES=20
SLEEP_TIME=10
while ! podman exec $KAFKA_CONTAINER_NAME kafka-broker-api-versions.sh --bootstrap-server localhost:$KAFKA_PORT > /dev/null 2>&1; do
  sleep $SLEEP_TIME
  RETRIES=$((RETRIES - 1))
  if [ $RETRIES -le 0 ]; then
    echo "Kafka did not start in time, exiting..."
    exit 1
  fi
  echo "Retrying... ($RETRIES retries left)"
done

# Create a Kafka topic
echo "Creating Kafka topic: $TOPIC_NAME"
podman exec -it $KAFKA_CONTAINER_NAME kafka-topics.sh --create --topic $TOPIC_NAME --bootstrap-server localhost:$KAFKA_PORT --partitions 1 --replication-factor 1

# Start Kafka producer (optional)
echo "Starting Kafka producer for topic: $TOPIC_NAME"
podman exec -it $KAFKA_CONTAINER_NAME kafka-console-producer.sh --topic $TOPIC_NAME --bootstrap-server localhost:$KAFKA_PORT

echo "Kafka setup complete."

