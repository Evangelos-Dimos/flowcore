#!/bin/bash
source "$(dirname "$0")/docker.sh"
source "$(dirname "$0")/../config/warehouse.conf"

PID=$1
TYPE=$2
QTY=$3

# Βρες το location από το config
VAR_NAME="ALLOWED_LOCATIONS_${TYPE}"
LOC=${!VAR_NAME}

if [ -z "$LOC" ]; then
    echo "ERROR: No location defined for product type: $TYPE"
    exit 1
fi

# ================================
# CHECK CAPACITY
# ================================

# Παίρνουμε current_count και max_capacity (ξεχωριστά)
CURRENT=$(call_database "SELECT current_count FROM locations WHERE location_id='$LOC';")
CURRENT=$(echo "$CURRENT" | tr -d '[:space:]' | head -1)

MAX=$(call_database "SELECT max_capacity FROM locations WHERE location_id='$LOC';")
MAX=$(echo "$MAX" | tr -d '[:space:]' | head -1)

[ -z "$CURRENT" ] && CURRENT=0
[ -z "$MAX" ] && MAX=0

AVAILABLE=$((MAX - CURRENT))

if [ "$QTY" -gt "$AVAILABLE" ]; then
    echo "Not enough space in $LOC (Available: $AVAILABLE, Requested: $QTY)"
    exit 1
fi

# ================================
# UPDATE INVENTORY
# ================================

EXISTS=$(call_database "SELECT COUNT(*) FROM inventory WHERE product_id='$PID';")
EXISTS=$(echo "$EXISTS" | tr -d '[:space:]' | head -1)

if [ "$EXISTS" -gt 0 ]; then
    call_database "UPDATE inventory SET quantity_number = quantity_number + $QTY WHERE product_id='$PID';"
    call_database "UPDATE products SET products.quantity = "
else
    call_database "INSERT INTO inventory (product_id, product_type, location_id, quantity_number) 
                    VALUES ('$PID', '$TYPE', '$LOC', $QTY);"
fi

# Ενημέρωση του current_count στο locations
call_database "UPDATE locations l SET current_count = (
    SELECT NVL(SUM(quantity_number), 0) 
    FROM inventory i 
    WHERE i.location_id = l.location_id
) WHERE l.location_id = '$LOC';"

# Commit
call_database "COMMIT;"

echo "Stored $QTY items in $LOC (Total in $LOC: $((CURRENT + QTY))/$MAX)"