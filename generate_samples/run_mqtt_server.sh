#!/bin/bash

# Step 1: Define variables
CONTAINER_NAME="mqtt-broker"
IMAGE_NAME="mqtt-image"
MQTT_CONFIG_DIR="$PWD/mqtt_config"
MQTT_DATA_DIR="$PWD/mqtt_data"
MQTT_PORT=1883
MQTT_PORT_SECURE=8883

# Step 2: Create necessary directories for configuration and persistence
mkdir -p "$MQTT_CONFIG_DIR"
mkdir -p "$MQTT_DATA_DIR"

# Step 3: Create the Mosquitto configuration file only if it doesn't exist
if [ ! -f "$MQTT_CONFIG_DIR/mosquitto.conf" ]; then
    cat > "$MQTT_CONFIG_DIR/mosquitto.conf" <<EOL
# Config for MQTT Broker (Mosquitto)
listener $MQTT_PORT
allow_anonymous true

persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

# Uncomment to enable secure MQTT with TLS
#listener $MQTT_PORT_SECURE
#cafile /mosquitto/config/ca.crt
#certfile /mosquitto/config/server.crt
#keyfile /mosquitto/config/server.key
EOL
    echo "Created new mosquitto.conf configuration."
else
    echo "Using existing mosquitto.conf configuration."
fi

# Step 4: Create Dockerfile only if it doesn't exist
if [ ! -f Dockerfile ]; then
    cat > Dockerfile <<EOL
# Base image
FROM eclipse-mosquitto:2.0

# Copy Mosquitto configuration
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Expose MQTT ports
EXPOSE $MQTT_PORT $MQTT_PORT_SECURE
EOL
    echo "Created new Dockerfile."
else
    echo "Using existing Dockerfile."
fi

# Step 5: Check if the image already exists
if podman image exists $IMAGE_NAME; then
    echo "Image $IMAGE_NAME already exists, skipping build."
else
    echo "Building new image $IMAGE_NAME."
    podman build -t $IMAGE_NAME .
fi

# Step 6: Check if the container is already running
if podman ps --filter "name=$CONTAINER_NAME" | grep -q $CONTAINER_NAME; then
    echo "Container $CONTAINER_NAME is already running."
else
    if podman ps -a --filter "name=$CONTAINER_NAME" | grep -q $CONTAINER_NAME; then
        echo "Container $CONTAINER_NAME exists but is stopped. Starting it."
        podman start $CONTAINER_NAME
    else
        echo "Running new container $CONTAINER_NAME."
        podman run -d \
            --name $CONTAINER_NAME \
            -p $MQTT_PORT:$MQTT_PORT \
            -p $MQTT_PORT_SECURE:$MQTT_PORT_SECURE \
            -v "$MQTT_CONFIG_DIR:/mosquitto/config:Z" \
            -v "$MQTT_DATA_DIR:/mosquitto/data:Z" \
            $IMAGE_NAME
    fi
fi

# Step 7: Display connection info
echo "MQTT broker is running on ports $MQTT_PORT (insecure) and $MQTT_PORT_SECURE (secure)."
echo "To check logs: podman logs $CONTAINER_NAME"

