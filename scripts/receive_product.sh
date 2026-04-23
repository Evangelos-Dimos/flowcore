#!/bin/bash
source ../config/warehouse.conf

NAME=$1
PRODUCT_TYPE=$2
QUANTITY=$3
LOG_FILE="../logs/system.log"

# check arguments
if [ -z "$NAME" ] || [ -z "$PRODUCT_TYPE" ] || [ -z "$QUANTITY" ]; then
    echo "Usage: ./receive_product.sh <name> <type> <quantity>"
    echo "[ERROR] Missing input" >> "$LOG_FILE"
    exit 1
fi

# check quantity is number
if ! [[ "$QUANTITY" =~ ^[0-9]+$ ]]; then
    echo "Quantity must be a number"
    echo "[ERROR] Invalid quantity: $QUANTITY" >> "$LOG_FILE"
    exit 1
fi

# check product type
VALID=0
for type in $VALID_TYPES; do
    if [ "$PRODUCT_TYPE" = "$type" ]; then
        VALID=1
    fi
done

if [ "$VALID" -eq 0 ]; then
    echo "Invalid product type. Valid: $VALID_TYPES"
    echo "[ERROR] Unknown product type: $PRODUCT_TYPE" >> "$LOG_FILE"
    exit 1
fi

# get location for this product type
VAR_NAME="ALLOWED_LOCATIONS_${PRODUCT_TYPE}"
LOCATION=${!VAR_NAME}

# check available space in rack BEFORE doing anything
CURRENT_COUNT=$(docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT NVL(SUM(quantity_number), 0) FROM inventory WHERE location_id = '$LOCATION';
EXIT;
EOF
)

CURRENT_COUNT=$(echo "$CURRENT_COUNT" | tr -d '[:space:]')

if [ -z "$CURRENT_COUNT" ] || [ "$CURRENT_COUNT" = "" ]; then
    CURRENT_COUNT=0
fi

AVAILABLE=$((MAX_ITEMS_PER_LOCATION - CURRENT_COUNT))

# rack full
if [ "$AVAILABLE" -le 0 ]; then
    echo "Rack $LOCATION is full. Product not received."
    echo "[ERROR] Rack $LOCATION full - product rejected" >> "$LOG_FILE"
    exit 1
fi

# not enough space
if [ "$QUANTITY" -gt "$AVAILABLE" ]; then
    echo "Not enough space. Rack $LOCATION has only $AVAILABLE spots available."
    echo "Product not received."
    echo "[ERROR] Not enough space in $LOCATION - rejected" >> "$LOG_FILE"
    exit 1
fi

# check if product already exists
EXISTING_ID=$(docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT product_id FROM products
WHERE name = '$NAME' AND product_type = '$PRODUCT_TYPE'
AND ROWNUM = 1;
EXIT;
EOF
)

EXISTING_ID=$(echo "$EXISTING_ID" | tr -d '[:space:]')

if [ -n "$EXISTING_ID" ]; then
    # product exists - update quantity
    docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
UPDATE products SET quantity = quantity + $QUANTITY
WHERE product_id = '$EXISTING_ID';
COMMIT;
EXIT;
EOF
    echo "[INFO] Updated $EXISTING_ID ($NAME) qty+$QUANTITY" >> "$LOG_FILE"
    echo "Product updated successfully with ID: $EXISTING_ID"
    ./assign_location.sh "$EXISTING_ID" "$PRODUCT_TYPE" "$QUANTITY"
else
    # generate new product_id
    PRODUCT_ID=$(docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT 'PL' || LPAD(FLOOR(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0') FROM dual;
EXIT;
EOF
)
    PRODUCT_ID=$(echo "$PRODUCT_ID" | tr -d '[:space:]')

    # insert new product
    docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
INSERT INTO products (product_id, name, product_type, quantity, receive_date)
VALUES ('$PRODUCT_ID', '$NAME', '$PRODUCT_TYPE', $QUANTITY, SYSDATE);
COMMIT;
EXIT;
EOF
    echo "[INFO] Received $PRODUCT_ID ($NAME) type:$PRODUCT_TYPE qty:$QUANTITY" >> "$LOG_FILE"
    echo "Product received successfully with ID: $PRODUCT_ID"
    ./assign_location.sh "$PRODUCT_ID" "$PRODUCT_TYPE" "$QUANTITY"
fi
