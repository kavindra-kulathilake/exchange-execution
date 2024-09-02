#!/bin/bash
set -x
echo "Current date and time: $(date)"

# Create network if it doesn't exist
podman network inspect exchange >/dev/null 2>&1 || podman network create exchange

# Check for updates and only proceed if there are changes
EXCHANGE_UPDATED=$(podman pull sprintlyinterchange/exchange:latest | tee /dev/tty | grep -q "Downloaded"; echo $?)
EXCHANGE_WEB_UPDATED=$(podman pull sprintlyinterchange/exchange-web:latest | tee /dev/tty | grep -q "Downloaded"; echo $?)

if [[ "$EXCHANGE_UPDATED" -eq 0 || "$EXCHANGE_WEB_UPDATED" -eq 0 ]]; then
    # Stop and remove the existing containers
    podman stop exchange
    podman rm exchange
    podman stop exchange-web
    podman rm exchange-web
    podman stop nginx-exchange
    podman rm nginx-exchange

    # Run the exchange container
    podman run -d --restart=always --name exchange --network exchange \
        -e FILE_STORAGE_DIR=/exchange \
        -e CONFIG_STORAGE_DIR=/exchange \
        -v $PWD/exchange:/exchange:z \
        -p 4000:4000 \
        docker.io/sprintlyinterchange/exchange:latest

    # Run the exchange-web container
    podman run -d --restart=always --name exchange-web --network exchange \
        -e REACT_APP_API_BASE_URL=https://app.sprintly-exchange.com \
        -p 3000:3000 \
        docker.io/sprintlyinterchange/exchange-web:latest

    # Build the Nginx container
    docker build -t kkulathilake/nginx-exchange:latest .

    # Run the nginx-exchange container
    podman run -d --restart=always -p 8080:8080 -p 8443:8443 --network exchange \
        --name nginx-exchange \
        localhost/kkulathilake/nginx-exchange:latest
else
    echo "No updates found, skipping deployment."
fi

