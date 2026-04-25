#!/bin/bash

source "$(dirname "$0")/docker.sh"

ORDER_ID=$1

# check arguments
if [ -z "$ORDER_ID" ]; then
    echo "Usage: ./process_order.sh <order_id>"
    echo "[ERROR] Missing order ID" >> "$LOG_FILE"
    exit 1
fi

# check order exists
ORDER_EXISTS=$(call_database "SELECT COUNT(*) FROM orders WHERE order_id = $ORDER_ID;")
ORDER_EXISTS=$(echo "$ORDER_EXISTS" | tr -d '[:space:]')

if [ "$ORDER_EXISTS" -eq 0 ]; then
    echo "Order $ORDER_ID not found"
    echo "[ERROR] Order $ORDER_ID does not exist" >> "$LOG_FILE"
    exit 1
fi

# check order status
STATUS=$(call_database "SELECT status FROM orders WHERE order_id = $ORDER_ID;")
STATUS=$(echo "$STATUS" | tr -d '[:space:]')

if [ "$STATUS" != "PENDING" ]; then
    echo "Order $ORDER_ID is already $STATUS"
    echo "[WARNING] Order $ORDER_ID already processed" >> "$LOG_FILE"
    exit 0
fi

# get order items
echo "Processing order $ORDER_ID..."
echo "[INFO] Processing order $ORDER_ID" >> "$LOG_FILE"

ORDER_ITEMS=$(call_database "
SELECT product_id, quantity FROM order_items WHERE order_id = $ORDER_ID;
")

if [ -z "$ORDER_ITEMS" ]; then
    echo "No items found in order $ORDER_ID"
    echo "[ERROR] Order $ORDER_ID has no items" >> "$LOG_FILE"
    exit 1
fi

# check availability and update
PROCESS_SUCCESS=1

while IFS= read -r line; do
    if [ -n "$line" ]; then
        PROD_ID=$(echo "$line" | awk '{print $1}')
        REQ_QTY=$(echo "$line" | awk '{print $2}')
        # get available quantity from products
        AVAIL_QTY=$(call_database "SELECT quantity FROM products WHERE product_id = '$PROD_ID';")
        AVAIL_QTY=$(echo "$AVAIL_QTY" | tr -d '[:space:]')

        if [ -z "$AVAIL_QTY" ] || [ "$AVAIL_QTY" -lt "$REQ_QTY" ]; then
            echo "Insufficient stock for product $PROD_ID (available: $AVAIL_QTY, requested: $REQ_QTY)"
            echo "[ERROR] Insufficient stock for product $PROD_ID" >> "$LOG_FILE"
            PROCESS_SUCCESS=0
        else
            # 1. Update products table
            call_database "UPDATE products SET quantity = quantity - $REQ_QTY WHERE product_id = '$PROD_ID';"

            # 2. Get location_id from inventory
            LOCATION=$(call_database "SELECT location_id FROM inventory WHERE product_id = '$PROD_ID' AND ROWNUM = 1;")
            LOCATION=$(echo "$LOCATION" | tr -d '[:space:]')

            # 3. Update inventory table
            if [ -n "$LOCATION" ]; then
                call_database "UPDATE inventory SET quantity_number = quantity_number - $REQ_QTY WHERE product_id = '$PROD_ID' AND location_id = '$LOCATION';"
                # 4. Update locations current_count
                call_database "UPDATE locations SET current_count = current_count - $REQ_QTY WHERE location_id = '$LOCATION';"
            fi

            echo "[INFO] Reserved $REQ_QTY of $PROD_ID from $LOCATION" >> "$LOG_FILE"
        fi
    fi
done <<< "$ORDER_ITEMS"

# update order status
if [ $PROCESS_SUCCESS -eq 1 ]; then
    call_database "UPDATE orders SET status = 'COMPLETED' WHERE order_id = $ORDER_ID;"
    echo "Order $ORDER_ID processed successfully!"
    echo "[INFO] Order $ORDER_ID completed successfully" >> "$LOG_FILE"
else
    call_database "UPDATE orders SET status = 'FAILED' WHERE order_id = $ORDER_ID;"
    echo "Order $ORDER_ID failed due to insufficient stock"
    echo "[ERROR] Order $ORDER_ID failed - insufficient stock" >> "$LOG_FILE"
fi

# commit all changes
call_database "COMMIT;"
