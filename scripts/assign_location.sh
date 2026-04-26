#!/bin/bash
source "$(dirname "$0")/docker.sh"

PID=$1
TYPE=$2
QTY=$3

VAR="ALLOWED_LOCATIONS_${TYPE}"
LOC=${!VAR}

# ================================
# CHECK CAPACITY
# ================================

CURRENT=$(call_database "SELECT current_count FROM locations WHERE location_id='$LOC';")
CURRENT=$(echo "$CURRENT" | tr -d '[:space:]')

MAX=$(call_database "SELECT max_capacity FROM locations WHERE location_id='$LOC';")
MAX=$(echo "$MAX" | tr -d '[:space:]')

# αν για κάποιο λόγο είναι null
[ -z "$CURRENT" ] && CURRENT=0
[ -z "$MAX" ] && MAX=0

AVAILABLE=$((MAX - CURRENT))

if [ "$QTY" -gt "$AVAILABLE" ]; then
    echo "Not enough space in $LOC (Available: $AVAILABLE)"
    exit 1
fi

# ================================
# INSERT / UPDATE INVENTORY
# ================================

EXISTS=$(call_database "SELECT COUNT(*) FROM inventory WHERE product_id='$PID' AND location_id='$LOC';")
EXISTS=$(echo "$EXISTS" | tr -d '[:space:]')

if [ "$EXISTS" -gt 0 ]; then
    call_database "UPDATE inventory SET quantity_number = quantity_number + $QTY WHERE product_id='$PID' AND location_id='$LOC';"
else
    call_database "INSERT INTO inventory VALUES (DEFAULT,'$PID','$TYPE','$LOC',$QTY);"
fi

# commit
call_database "COMMIT;"

echo "Stored $QTY items in $LOC"
