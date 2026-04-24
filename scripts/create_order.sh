#!/bin/bash

source ../config/db.conf

CUSTOMER_ID=$1
PRODUCT_ID=$2
QUANTITY=$3
LOG_FILE="../logs/system.log"

# ============================
# VALIDATION
# ============================

if [ -z "$CUSTOMER_ID" ] || [ -z "$PRODUCT_ID" ] || [ -z "$QUANTITY" ]; then
    echo "Usage: ./create_order.sh <customer_id> <product_id> <quantity>"
    echo "[ERROR] Missing input for order creation" >> "$LOG_FILE"
    exit 1
fi

if ! [[ "$QUANTITY" =~ ^[0-9]+$ ]]; then
    echo "Quantity must be a number"
    echo "[ERROR] Invalid quantity: $QUANTITY" >> "$LOG_FILE"
    exit 1
fi

# ============================
# CHECK CUSTOMER EXISTS
# ============================

CUSTOMER_EXISTS=$(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM customers WHERE customer_id = $CUSTOMER_ID;
EXIT;
EOF
)

CUSTOMER_EXISTS=$(echo "$CUSTOMER_EXISTS" | tr -d '[:space:]')

if [ "$CUSTOMER_EXISTS" -eq 0 ]; then
    echo "Customer not found"
    echo "[ERROR] Customer $CUSTOMER_ID does not exist" >> "$LOG_FILE"
    exit 1
fi

# ============================
# CHECK PRODUCT EXISTS
# ============================

PRODUCT_EXISTS=$(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM products WHERE product_id = '$PRODUCT_ID';
EXIT;
EOF
)

PRODUCT_EXISTS=$(echo "$PRODUCT_EXISTS" | tr -d '[:space:]')

if [ "$PRODUCT_EXISTS" -eq 0 ]; then
    echo "Product not found"
    echo "[ERROR] Product $PRODUCT_ID does not exist" >> "$LOG_FILE"
    exit 1
fi

# ============================
# CREATE ORDER + ITEM
# ============================

ORDER_ID=$(docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0

INSERT INTO orders (customer_id, status, ordered_at)
VALUES ($CUSTOMER_ID, 'PENDING', SYSDATE);

SELECT MAX(order_id) FROM orders;

COMMIT;
EXIT;
EOF
)

ORDER_ID=$(echo "$ORDER_ID" | tr -d '[:space:]')

# insert order item
docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
INSERT INTO order_items (order_id, product_id, quantity)
VALUES ($ORDER_ID, '$PRODUCT_ID', $QUANTITY);

COMMIT;
EXIT;
EOF

# ============================
# SUCCESS
# ============================

echo "[INFO] Created order $ORDER_ID for product $PRODUCT_ID (qty:$QUANTITY)" >> "$LOG_FILE"

echo "Order created successfully!"
echo "Order ID: $ORDER_ID"
