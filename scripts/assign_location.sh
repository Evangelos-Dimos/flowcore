source ../config/warehouse.conf

PRODUCT_ID=$1
PRODUCT_TYPE=$2
QUANTITY=$3

INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

# get location dynamically
VAR_NAME="ALLOWED_LOCATIONS_${PRODUCT_TYPE}"
LOCATION=${!VAR_NAME}

# safety check
if [ -z "$LOCATION" ]; then
    echo "Invalid product type"
    echo "[ERROR] No location for type: $PRODUCT_TYPE" >> "$LOG_FILE"
    exit 1
fi

# count current items in rack
CURRENT_COUNT=$(grep -c ",$LOCATION$" "$INVENTORY_FILE" 2>/dev/null)

# calculate available space
AVAILABLE=$((MAX_ITEMS_PER_LOCATION - CURRENT_COUNT))

# rack full
if [ "$AVAILABLE" -le 0 ]; then
    echo "Rack $LOCATION is full"
    echo "[ERROR] $LOCATION is full" >> "$LOG_FILE"
    exit 1
fi

# partial insert if needed
if [ "$QUANTITY" -gt "$AVAILABLE" ]; then
    echo "Only $AVAILABLE items can be stored in $LOCATION"
    echo "[WARNING] Partial insert for $PRODUCT_ID: requested $QUANTITY, stored $AVAILABLE" >> "$LOG_FILE"
    QUANTITY=$AVAILABLE
fi

# insert items (one per line)
for ((i=1; i<=QUANTITY; i++)); do
    echo "$PRODUCT_ID,$PRODUCT_TYPE,$LOCATION" >> "$INVENTORY_FILE"
done

# log success
echo "[INFO] Stored $PRODUCT_ID ($PRODUCT_TYPE) x$QUANTITY in $LOCATION" >> "$LOG_FILE"

# user message
echo "Stored $QUANTITY items in $LOCATION"
