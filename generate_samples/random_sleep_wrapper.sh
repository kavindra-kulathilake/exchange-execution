#!/bin/bash

# Path to the main script
MAIN_SCRIPT="/opt/exchange-execution/generate_samples/random_orders.sh"

# Generate a random sleep time between 0 and 59 seconds
SLEEP_TIME=$((RANDOM % 60))

# Sleep for the random amount of time
sleep $SLEEP_TIME

# Run the main script
bash "$MAIN_SCRIPT"

