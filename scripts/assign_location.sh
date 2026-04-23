#!/bin/bash
source ../config/warehouse.conf

PRODUCT_ID=$1
PRODUCT_TYPE=$2
QUANTITY=$3
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

# create location if not exists
docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
BEGIN
    INSERT INTO locations (location_id, max_capacity, current_count)
    SELECT '$LOCATION', $MAX_ITEMS_PER_LOCATION, 0
    FROM dual
    WHERE NOT EXISTS (
        SELECT 1 FROM locations WHERE location_id = '$LOCATION'
    );
    COMMIT;
END;
/
EXIT;
EOF

# get current count directly from inventory
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

# check if product already exists in inventory
EXISTING_INV=$(docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT NVL(quantity_number, 0) FROM inventory
WHERE product_id = '$PRODUCT_ID' AND location_id = '$LOCATION';
EXIT;
EOF
)

EXISTING_INV=$(echo "$EXISTING_INV" | tr -d '[:space:]')

if [ -n "$EXISTING_INV" ] && [ "$EXISTING_INV" != "0" ]; then
    # product exists in inventory, update quantity
    docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
UPDATE inventory
SET quantity_number = quantity_number + $QUANTITY
WHERE product_id = '$PRODUCT_ID' AND location_id = '$LOCATION';
COMMIT;
EXIT;
EOF
else
    # new entry in inventory
    docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
INSERT INTO inventory (product_id, product_type, location_id, quantity_number)
VALUES ('$PRODUCT_ID', '$PRODUCT_TYPE', '$LOCATION', $QUANTITY);
COMMIT;
EXIT;
EOF
fi

# sync current_count from inventory
docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEPDB1 << EOF
UPDATE locations
SET current_count = (
    SELECT NVL(SUM(quantity_number), 0)
    FROM inventory
    WHERE location_id = '$LOCATION'
)
WHERE location_id = '$LOCATION';
COMMIT;
EXIT;
EOF

echo "[INFO] Stored $PRODUCT_ID ($PRODUCT_TYPE) x$QUANTITY in $LOCATION" >> "$LOG_FILE"
echo "Stored $QUANTITY items in $LOCATION"
