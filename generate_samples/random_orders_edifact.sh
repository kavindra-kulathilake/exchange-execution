#!/bin/bash

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
ORDER_DATE=$(date +"%Y-%m-%d")

# Fixed organization numbers
SENDER_ORG_NUMBERS=("123456789" "987654321" "555444333" "111222333" "444555666")
RECEIVER_ORG_NUMBERS=("111999888" "222888777" "333777666" "444666555" "555333222")

# Define random senderId and receiverId as country codes with fixed organization numbers
SENDER_ID=$(shuf -n 1 -e "US" "DE" "IN" "JP" "GB")_$(shuf -n 1 -e "${SENDER_ORG_NUMBERS[@]}")
RECEIVER_ID=$(shuf -n 1 -e "US" "DE" "IN" "JP" "GB")_$(shuf -n 1 -e "${RECEIVER_ORG_NUMBERS[@]}")

# Use order_id as messageId
MESSAGE_ID="$ORDER_ID"

# Create EDIFACT ORDERS message
ORDERS_EDIFACT=$(cat <<EOF
UNH+1+ORDERS:D:96A:UN'
BGM+220+$ORDER_ID+9'
DTM+137:$ORDER_DATE:102'
NAD+BY+${SENDER_ID}:160:ZZZ'
NAD+SE+${RECEIVER_ID}:160:ZZZ'
LIN+1++ItemA:SRV'
QTY+21:$QUANTITY1'
LIN+2++ItemB:SRV'
QTY+21:$QUANTITY2'
LIN+3++ItemC:SRV'
UNS+S'
CNT+2:3'
UNT+14+1'
EOF
)

# Define the filename for ORDERS with the current timestamp
FILENAME="orders_$(date +"%Y%m%d%H%M%S").edi"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Save the EDIFACT ORDERS to a file
echo "$ORDERS_EDIFACT" > "$FILEPATH"
chmod 777 "$FILEPATH"
echo "ORDERS EDIFACT saved to $FILEPATH"

# Wait for a few minutes before generating the order response
sleep 120  # Sleep for 2 minutes

# Use order_id as messageId for the ORDRSP response
RESPONSE_MESSAGE_ID="$ORDER_ID"

# Generate EDIFACT ORDRSP message
RESPONSE_STATUS=$(shuf -n 1 -e "27" "42" "28")  # 27: Accepted without amendment, 42: Changed, 28: Rejected
RESPONSE_DATE=$(date +"%Y%m%d")

# Swap senderId and receiverId for the response
ORDRSP_EDIFACT=$(cat <<EOF
UNH+2+ORDRSP:D:96A:UN'
BGM+231+$ORDER_ID+9'
DTM+137:$RESPONSE_DATE:102'
NAD+BY+${RECEIVER_ID}:160:ZZZ'
NAD+SE+${SENDER_ID}:160:ZZZ'
LIN+1++ItemA:SRV'
QTY+21:$QUANTITY1'
LIN+2++ItemB:SRV'
QTY+21:$QUANTITY2'
LIN+3++ItemC:SRV'
UNS+S'
CNT+2:3'
UNT+14+2'
EOF
)

# Define the filename for ORDRSP with the current timestamp
RESPONSE_FILENAME="order_response_$(date +"%Y%m%d%H%M%S").edi"
RESPONSE_FILEPATH="$RESPONSE_OUTPUT_DIR/$RESPONSE_FILENAME"

# Save the EDIFACT ORDRSP to a file
echo "$ORDRSP_EDIFACT" > "$RESPONSE_FILEPATH"
chmod 777 "$RESPONSE_FILEPATH"
echo "ORDRSP EDIFACT saved to $RESPONSE_FILEPATH"

# Wait again before generating the invoice
sleep 60  # Sleep for 1 more minute (adjust as needed)

# Use order_id as messageId for the INVOIC
INVOICE_MESSAGE_ID="$ORDER_ID"

# Generate EDIFACT INVOIC message
INVOICE_ID=$((RANDOM % 9000 + 1000))
INVOICE_DATE=$(date +"%Y%m%d")
DUE_DATE=$(date -d "+30 days" +"%Y%m%d")

# Swap senderId and receiverId for the invoice
INVOIC_EDIFACT=$(cat <<EOF
UNH+3+INVOIC:D:96A:UN'
BGM+380+$INVOICE_ID+9'
DTM+137:$INVOICE_DATE:102'
DTM+200:$DUE_DATE:102'
NAD+BY+${RECEIVER_ID}:160:ZZZ'
NAD+SE+${SENDER_ID}:160:ZZZ'
LIN+1++ItemA:SRV'
QTY+21:$QUANTITY1'
PRI+AAA:10.00'
LIN+2++ItemB:SRV'
QTY+21:$QUANTITY2'
PRI+AAA:15.00'
LIN+3++ItemC:SRV'
QTY+21:$QUANTITY3'
PRI+AAA:20.00'
UNS+S'
CNT+2:3'
UNT+16+3'
EOF
)

# Define the filename for INVOIC with the current timestamp
INVOICE_FILENAME="invoice_$(date +"%Y%m%d%H%M%S").edi"
INVOICE_FILEPATH="$INVOICE_OUTPUT_DIR/$INVOICE_FILENAME"

# Save the EDIFACT INVOIC to a file
echo "$INVOIC_EDIFACT" > "$INVOICE_FILEPATH"
chmod 777 "$INVOICE_FILEPATH"
echo "INVOIC EDIFACT saved to $INVOICE_FILEPATH"

