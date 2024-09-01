#!/bin/bash

# Set directories for orders, order responses, and invoices
OUTPUT_DIR="/home/ftpuser/orders/download"
RESPONSE_OUTPUT_DIR="/home/ftpuser/orderresponse/download"
INVOICE_OUTPUT_DIR="/home/ftpuser/invoice/download"

# Ensure the output directories exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$RESPONSE_OUTPUT_DIR"
mkdir -p "$INVOICE_OUTPUT_DIR"

# Generate a random order
ORDER_ID=$((RANDOM % 9000 + 1000))
CUSTOMER_NAME=$(shuf -n 1 -e Alice Bob Charlie David Eve)
ITEM_ID1=$((RANDOM % 10 + 1))
ITEM_ID2=$((RANDOM % 10 + 11))
ITEM_ID3=$((RANDOM % 10 + 21))
QUANTITY1=$((RANDOM % 5 + 1))
QUANTITY2=$((RANDOM % 5 + 1))
QUANTITY3=$((RANDOM % 5 + 1))
TOTAL_PRICE=$(awk -v min=10 -v max=100 'BEGIN{srand(); print min+rand()*(max-min)}')
ORDER_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Create the JSON structure for the order
ORDER_JSON=$(cat <<EOF
{
    "order_id": $ORDER_ID,
    "customer_name": "$CUSTOMER_NAME",
    "items": [
        {"item_id": $ITEM_ID1, "item_name": "ItemA", "quantity": $QUANTITY1},
        {"item_id": $ITEM_ID2, "item_name": "ItemB", "quantity": $QUANTITY2},
        {"item_id": $ITEM_ID3, "item_name": "ItemC", "quantity": $QUANTITY3}
    ],
    "total_price": $(printf "%.2f" $TOTAL_PRICE),
    "order_date": "$ORDER_DATE"
}
EOF
)

# Define the filename with the current timestamp
FILENAME="order_$(date +"%Y%m%d%H%M%S").json"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Save the JSON to a file
echo "$ORDER_JSON" > "$FILEPATH"
chmod 777 "$FILEPATH"
echo "Order saved to $FILEPATH"

# Wait for a few minutes before generating the order response
sleep 120  # Sleep for 2 minutes

# Generate the order response JSON
RESPONSE_STATUS=$(shuf -n 1 -e "Processing" "Completed" "Shipped" "Delivered")
RESPONSE_DATE=$(date +"%Y-%m-%d %H:%M:%S")

ORDER_RESPONSE_JSON=$(cat <<EOF
{
    "order_id": $ORDER_ID,
    "status": "$RESPONSE_STATUS",
    "response_date": "$RESPONSE_DATE"
}
EOF
)

# Define the filename for the response with the current timestamp
RESPONSE_FILENAME="order_response_$(date +"%Y%m%d%H%M%S").json"
RESPONSE_FILEPATH="$RESPONSE_OUTPUT_DIR/$RESPONSE_FILENAME"

# Save the response JSON to a file
echo "$ORDER_RESPONSE_JSON" > "$RESPONSE_FILEPATH"
chmod 777 "$RESPONSE_FILEPATH"
echo "Order response saved to $RESPONSE_FILEPATH"

# Wait again before generating the invoice
sleep 60  # Sleep for 1 more minute (adjust as needed)

# Generate the invoice JSON
INVOICE_ID=$((RANDOM % 9000 + 1000))
INVOICE_DATE=$(date +"%Y-%m-%d %H:%M:%S")
DUE_DATE=$(date -d "+30 days" +"%Y-%m-%d %H:%M:%S")

INVOICE_JSON=$(cat <<EOF
{
    "invoice_id": $INVOICE_ID,
    "order_id": $ORDER_ID,
    "customer_name": "$CUSTOMER_NAME",
    "items": [
        {"item_id": $ITEM_ID1, "item_name": "ItemA", "quantity": $QUANTITY1, "price": 10.00},
        {"item_id": $ITEM_ID2, "item_name": "ItemB", "quantity": $QUANTITY2, "price": 15.00},
        {"item_id": $ITEM_ID3, "item_name": "ItemC", "quantity": $QUANTITY3, "price": 20.00}
    ],
    "total_amount": $(printf "%.2f" $TOTAL_PRICE),
    "invoice_date": "$INVOICE_DATE",
    "due_date": "$DUE_DATE"
}
EOF
)

# Define the filename for the invoice with the current timestamp
INVOICE_FILENAME="invoice_$(date +"%Y%m%d%H%M%S").json"
INVOICE_FILEPATH="$INVOICE_OUTPUT_DIR/$INVOICE_FILENAME"

# Save the invoice JSON to a file
echo "$INVOICE_JSON" > "$INVOICE_FILEPATH"
chmod 777 "$INVOICE_FILEPATH"
echo "Invoice saved to $INVOICE_FILEPATH"

