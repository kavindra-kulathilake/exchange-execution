#!/bin/bash
set -x
echo "Current date and time: $(date)"

# Create network if it doesn't exist
podman network inspect exchange >/dev/null 2>&1 || podman network create exchange

# Get the current image IDs
CURRENT_EXCHANGE_ID=$(podman images -q sprintlyinterchange/exchange:latest)
CURRENT_EXCHANGE_WEB_ID=$(podman images -q sprintlyinterchange/exchange-web:latest)

# Pull the latest images
podman pull sprintlyinterchange/exchange:latest
podman pull sprintlyinterchange/exchange-web:latest

# Get the new image IDs
NEW_EXCHANGE_ID=$(podman images -q sprintlyinterchange/exchange:latest)
NEW_EXCHANGE_WEB_ID=$(podman images -q sprintlyinterchange/exchange-web:latest)

# Check if the image IDs have changed
if [[ "$CURRENT_EXCHANGE_ID" != "$NEW_EXCHANGE_ID" || "$CURRENT_EXCHANGE_WEB_ID" != "$NEW_EXCHANGE_WEB_ID" ]]; then
    echo "Updates detected, proceeding with deployment..."

    # Stop and remove the existing containers
    podman stop exchange || true
    podman rm exchange || true
    podman stop exchange-web || true
    podman rm exchange-web || true
    podman stop nginx-exchange || true
    podman rm nginx-exchange || true

    # Run the exchange container
    podman run -d --restart=always --name exchange --network exchange \
        -e FILE_STORAGE_DIR=/exchange \
        -e CONFIG_STORAGE_DIR=/exchange \
        -v "$PWD/exchange:/exchange:z" \
        -p 4000:4000 \
        sprintlyinterchange/exchange:latest

    # Run the exchange-web container
    podman run -d --restart=always --name exchange-web --network exchange \
        -e REACT_APP_API_BASE_URL=https://app.sprintly-exchange.com \
        -p 3000:3000 \
        sprintlyinterchange/exchange-web:latest

    # Build the Nginx container
    docker build -t kkulathilake/nginx-exchange:latest .

    # Run the nginx-exchange container
    podman run -d --restart=always -p 8080:8080 -p 8443:8443 --network exchange \
        --name nginx-exchange \
        localhost/kkulathilake/nginx-exchange:latest
else
    echo "No updates found, skipping deployment."
fi

