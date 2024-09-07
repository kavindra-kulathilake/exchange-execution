#!/bin/bash

# Path to the main scripts
ORDER_SCRIPT="/opt/exchange-execution/generate_samples/random_orders.sh"
EDIFACT_SCRIPT="/opt/exchange-execution/generate_samples/random_orders_edifact.sh"

# Generate a random sleep time between 0 and 59 seconds
SLEEP_TIME=$((RANDOM % 60))

# Sleep for the random amount of time
sleep $SLEEP_TIME

# Run the main scripts
bash "$ORDER_SCRIPT"
bash "$EDIFACT_SCRIPT"

