#!/bin/bash
source "$(dirname "$0")/docker.sh"
source "$(dirname "$0")/../config/warehouse.conf"

NAME=$1
TYPE=$2
QTY=$3

if [ -z "$NAME" ] || [ -z "$TYPE" ] || [ -z "$QTY" ]; then
    echo "Usage: ./receive_product.sh <name> <type> <quantity>"
    exit 1
fi

# ============================================
# 1. ΕΛΕΓΧΟΣ ΧΩΡΗΤΙΚΟΤΗΤΑΣ (χωρίς αλλαγές)
# ============================================

VAR_NAME="ALLOWED_LOCATIONS_${TYPE}"
LOC=${!VAR_NAME}

if [ -z "$LOC" ]; then
    echo "ERROR: No location defined for product type: $TYPE"
    exit 1
fi

CURRENT=$(call_database "SELECT current_count FROM locations WHERE location_id='$LOC';")
CURRENT=$(echo "$CURRENT" | tr -d '[:space:]' | head -1)

MAX=$(call_database "SELECT max_capacity FROM locations WHERE location_id='$LOC';")
MAX=$(echo "$MAX" | tr -d '[:space:]' | head -1)

[ -z "$CURRENT" ] && CURRENT=0
[ -z "$MAX" ] && MAX=0

AVAILABLE=$((MAX - CURRENT))

if [ "$QTY" -gt "$AVAILABLE" ]; then
    echo "Not enough space in $LOC (Available: $AVAILABLE, Requested: $QTY)"
    echo "Product NOT stored due to capacity limits"
    exit 1
fi

# ============================================
# 2. ΠΡΟΧΩΡΑ ΜΕ ΤΗΝ ΕΙΣΑΓΩΓΗ
# ============================================

# Βρες αν υπάρχει ήδη το προϊόν
PID=$(call_database "SELECT product_id FROM products WHERE name='$NAME' AND product_type='$TYPE' AND ROWNUM=1;")
PID=$(echo "$PID" | tr -d '[:space:]' | head -1)

if [ -z "$PID" ]; then
    # Δημιουργία νέου ID
    PID=$(call_database "SELECT 'P' || LPAD(FLOOR(DBMS_RANDOM.VALUE(1,9999)),4,'0') FROM dual;")
    PID=$(echo "$PID" | tr -d '[:space:]' | head -1)
    
    call_database "INSERT INTO products (product_id, name, product_type, quantity, receive_date) 
                    VALUES ('$PID', '$NAME', '$TYPE', $QTY, SYSDATE);"
else
    call_database "UPDATE products SET quantity = quantity + $QTY WHERE product_id='$PID';"
fi

# ============================================
# 3. ΚΛΗΣΗ assign_location.sh
# ============================================
./assign_location.sh "$PID" "$TYPE" "$QTY"

if [ $? -ne 0 ]; then
    echo "Product NOT stored due to capacity limits"
    call_database "ROLLBACK;"
    exit 1
fi

# ============================================
# 4. COMMIT
# ============================================
call_database "COMMIT;"

echo "Product stored with ID: $PID"