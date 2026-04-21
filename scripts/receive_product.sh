source ../config/warehouse.conf

PRODUCT_ID=$1
PRODUCT_TYPE=$2
QUANTITY=$3

LOG_FILE="../logs/system.log"

# check arguments
if [ -z "$PRODUCT_ID" ] || [ -z "$PRODUCT_TYPE" ] || [ -z "$QUANTITY" ]; then
    echo "Usage: ./receive_product.sh <id> <type> <quantity>"
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

docker exec -i oracle23ai sqlplus -s system/my_strong_password@FREEPDB1 << EOF
INSERT INTO products (product_id, product_type, quantity) 
VALUES ('$PRODUCT_ID', '$PRODUCT_TYPE', $QUANTITY);
COMMIT;
EXIT;
EOF

# call assign automatically
./assign_location.sh "$PRODUCT_ID" "$PRODUCT_TYPE" "$QUANTITY"
