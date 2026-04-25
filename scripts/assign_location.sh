#!/bin/bash

source "$(dirname "$0")/docker.sh"

PRODUCT_ID=$1
PRODUCT_TYPE=$2
QUANTITY=$3

# get location dynamically
VAR_NAME="ALLOWED_LOCATIONS_${PRODUCT_TYPE}"
LOCATION=${!VAR_NAME}

# safety check
if [ -z "$LOCATION" ]; then
    echo "Invalid product type"
    echo "[ERROR] No location for type: $PRODUCT_TYPE" >> "$LOG_FILE"
    exit 1
fi

# create location if not exists
call_database "
BEGIN
    INSERT INTO locations (location_id, max_capacity, current_count)
    SELECT '$LOCATION', $MAX_ITEMS_PER_LOCATION, 0
    FROM dual
    WHERE NOT EXISTS (
        SELECT 1 FROM locations WHERE location_id = '$LOCATION'
    );
END;
/"

# get current count
CURRENT_COUNT=$(call_database "SELECT NVL(SUM(quantity_number), 0) FROM inventory WHERE location_id = '$LOCATION';")

CURRENT_COUNT=$(echo "$CURRENT_COUNT" | tr -d '[:space:]')
[ -z "$CURRENT_COUNT" ] && CURRENT_COUNT=0

AVAILABLE=$((MAX_ITEMS_PER_LOCATION - CURRENT_COUNT))

if [ "$AVAILABLE" -le 0 ]; then
    echo "Rack $LOCATION is full"
    echo "[ERROR] $LOCATION is full" >> "$LOG_FILE"
    exit 1
fi

if [ "$QUANTITY" -gt "$AVAILABLE" ]; then
    echo "Only $AVAILABLE items can be stored in $LOCATION"
    echo "[WARNING] Partial insert for $PRODUCT_ID: requested $QUANTITY, stored $AVAILABLE" >> "$LOG_FILE"
    QUANTITY=$AVAILABLE
fi

# check if exists
EXISTING_INV=$(call_database "SELECT NVL(quantity_number, 0) FROM inventory WHERE product_id = '$PRODUCT_ID' AND location_id = '$LOCATION';")

EXISTING_INV=$(echo "$EXISTING_INV" | tr -d '[:space:]')

if [ -n "$EXISTING_INV" ] && [ "$EXISTING_INV" != "0" ]; then

    call_database "UPDATE inventory SET quantity_number = quantity_number + $QUANTITY WHERE product_id = '$PRODUCT_ID' AND location_id = '$LOCATION';"

else

    call_database "INSERT INTO inventory (product_id, product_type, location_id, quantity_number) VALUES ('$PRODUCT_ID', '$PRODUCT_TYPE', '$LOCATION', $QUANTITY);"

fi

# sync current_count
call_database "
UPDATE locations
SET current_count = (
    SELECT NVL(SUM(quantity_number), 0)
    FROM inventory
    WHERE location_id = '$LOCATION'
)
WHERE location_id = '$LOCATION';"

# Final commit
call_database "COMMIT;"

echo "[INFO] Stored $PRODUCT_ID ($PRODUCT_TYPE) x$QUANTITY in $LOCATION" >> "$LOG_FILE"
echo "Stored $QUANTITY items in $LOCATION"
