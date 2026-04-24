#!/bin/bash

source ../config/db.conf

ORDER_ID=$1
LOG_FILE="../logs/system.log"

if [ -z "$ORDER_ID" ]; then
    echo "Usage: ./process_order.sh <order_id>"
    echo "[ERROR] Missing order_id" >> "$LOG_FILE"
    exit 1
fi

# ============================
# CHECK ORDER EXISTS
# ============================

ORDER_EXISTS=$(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM orders WHERE order_id = $ORDER_ID;
EXIT;
EOF
)

ORDER_EXISTS=$(echo "$ORDER_EXISTS" | tr -d '[:space:]')

if [ "$ORDER_EXISTS" -eq 0 ]; then
    echo "Order not found"
    echo "[ERROR] Order $ORDER_ID not found" >> "$LOG_FILE"
    exit 1
fi

# ============================
# GET ORDER ITEM
# ============================

read PRODUCT_ID QUANTITY <<< $(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT product_id, quantity FROM order_items WHERE order_id = $ORDER_ID;
EXIT;
EOF
)

PRODUCT_ID=$(echo "$PRODUCT_ID" | tr -d '[:space:]')
QUANTITY=$(echo "$QUANTITY" | tr -d '[:space:]')

# ============================
# CHECK TOTAL STOCK
# ============================

TOTAL_STOCK=$(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT NVL(SUM(quantity_number),0) FROM inventory WHERE product_id = '$PRODUCT_ID';
EXIT;
EOF
)

TOTAL_STOCK=$(echo "$TOTAL_STOCK" | tr -d '[:space:]')

if [ "$TOTAL_STOCK" -lt "$QUANTITY" ]; then
    echo "Not enough stock to process order"
    echo "[ERROR] Order $ORDER_ID failed - insufficient stock" >> "$LOG_FILE"
    exit 1
fi

# ============================
# REDUCE INVENTORY
# ============================

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
UPDATE inventory
SET quantity_number = quantity_number - $QUANTITY
WHERE product_id = '$PRODUCT_ID';

COMMIT;
EXIT;
EOF

# ============================
# UPDATE ORDER STATUS
# ============================

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
UPDATE orders
SET status = 'SHIPPED'
WHERE order_id = $ORDER_ID;

COMMIT;
EXIT;
EOF

# ============================
# SUCCESS
# ============================

echo "[INFO] Order $ORDER_ID processed successfully" >> "$LOG_FILE"

echo "Order $ORDER_ID processed successfully!"
