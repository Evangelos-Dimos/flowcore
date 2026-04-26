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
    exit 1
fi

# check quantity
if ! [[ "$QUANTITY" =~ ^[0-9]+$ ]]; then
    echo "Quantity must be a number"
    exit 1
fi

# check customer exists
EXISTS=$(call_database "SELECT COUNT(*) FROM customers WHERE customer_id=$CUSTOMER_ID;")
EXISTS=$(echo "$EXISTS" | tr -d '[:space:]')

if [ "$EXISTS" -eq 0 ]; then
    echo "Customer not found"
    exit 1
fi

# check product exists
EXISTS=$(call_database "SELECT COUNT(*) FROM products WHERE product_id='$PRODUCT_ID';")
EXISTS=$(echo "$EXISTS" | tr -d '[:space:]')

if [ "$EXISTS" -eq 0 ]; then
    echo "Product not found"
    exit 1
fi

# check stock using function
STOCK_OK=$(call_database "SELECT check_stock('$PRODUCT_ID',$QUANTITY) FROM dual;")
STOCK_OK=$(echo "$STOCK_OK" | tr -d '[:space:]')

if [ "$STOCK_OK" -eq 0 ]; then
    echo "Not enough stock"
    exit 1
fi

# create order
call_database "INSERT INTO orders (customer_id,status,ordered_at) VALUES ($CUSTOMER_ID,'PENDING',SYSDATE);"

# get order id
ORDER_ID=$(call_database "SELECT MAX(order_id) FROM orders;")
ORDER_ID=$(echo "$ORDER_ID" | tr -d '[:space:]')

# insert order item
call_database "INSERT INTO order_items (order_id,product_id,quantity) VALUES ($ORDER_ID,'$PRODUCT_ID',$QUANTITY);"

# commit
call_database "COMMIT;"

# get status
STATUS=$(call_database "SELECT status FROM orders WHERE order_id=$ORDER_ID;")
STATUS=$(echo "$STATUS" | tr -d '[:space:]')

echo "Order created: $ORDER_ID ($STATUS)"
echo "Customer: $CUSTOMER_ID"
echo "Product: $PRODUCT_ID"
echo "Quantity: $QUANTITY"
