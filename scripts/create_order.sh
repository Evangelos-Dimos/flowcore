#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/docker.sh"

CUSTOMER_ID=$1
PRODUCT_ID=$2
QUANTITY=$3
LOG_FILE="../logs/system.log"

# check arguments
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

# check customer exists
CUSTOMER_EXISTS=$(call_database "SELECT COUNT(*) FROM customers WHERE customer_id = $CUSTOMER_ID;")
CUSTOMER_EXISTS=$(echo "$CUSTOMER_EXISTS" | tr -d ' \n\r\t')

if [ "$CUSTOMER_EXISTS" -eq 0 ]; then
    echo "Customer not found"
    echo "[ERROR] Customer $CUSTOMER_ID does not exist" >> "$LOG_FILE"
    exit 1
fi

# check product exists
PRODUCT_EXISTS=$(call_database "SELECT COUNT(*) FROM products WHERE product_id = '$PRODUCT_ID';")
PRODUCT_EXISTS=$(echo "$PRODUCT_EXISTS" | tr -d ' \n\r\t')

if [ "$PRODUCT_EXISTS" -eq 0 ]; then
    echo "Product not found"
    echo "[ERROR] Product $PRODUCT_ID does not exist" >> "$LOG_FILE"
    exit 1
fi

# check inventory has enough stock
STOCK=$(call_database "SELECT NVL(quantity_number, 0) FROM inventory WHERE product_id = '$PRODUCT_ID';")
STOCK=$(echo "$STOCK" | tr -d ' \n\r\t')

if [ -z "$STOCK" ] || [ "$STOCK" -lt "$QUANTITY" ]; then
    echo "Not enough stock. Available: $STOCK"
    echo "[ERROR] Insufficient stock for $PRODUCT_ID (available: $STOCK, requested: $QUANTITY)" >> "$LOG_FILE"
    exit 1
fi

# create order
docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
INSERT INTO orders (customer_id, status, ordered_at)
VALUES ($CUSTOMER_ID, 'PENDING', SYSDATE);
COMMIT;
EXIT;
EOF

# get the new order id
ORDER_ID=$(call_database "SELECT MAX(order_id) FROM orders;")
ORDER_ID=$(echo "$ORDER_ID" | tr -d ' \n\r\t')

# insert order item
docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
INSERT INTO order_items (order_id, product_id, quantity)
VALUES ($ORDER_ID, '$PRODUCT_ID', $QUANTITY);
COMMIT;
EXIT;
EOF

echo "[INFO] Created order $ORDER_ID for product $PRODUCT_ID (qty:$QUANTITY)" >> "$LOG_FILE"
echo "Order created successfully!"
echo "Order ID: $ORDER_ID"
echo "Customer ID: $CUSTOMER_ID"
echo "Product: $PRODUCT_ID"
echo "Quantity: $QUANTITY"
