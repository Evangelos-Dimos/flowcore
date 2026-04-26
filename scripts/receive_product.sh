#!/bin/bash
source "$(dirname "$0")/docker.sh"

NAME=$1
TYPE=$2
QTY=$3

if [ -z "$NAME" ] || [ -z "$TYPE" ] || [ -z "$QTY" ]; then
    echo "Usage: ./receive_product.sh <name> <type> <quantity>"
    exit 1
fi

PID=$(call_database "SELECT product_id FROM products WHERE name='$NAME' AND product_type='$TYPE' AND ROWNUM=1;")
PID=$(echo "$PID" | tr -d '[:space:]')

if [ -z "$PID" ]; then
    PID=$(call_database "SELECT '$ID_PREFIX' || LPAD(FLOOR(DBMS_RANDOM.VALUE(1000,9999)),4,'0') FROM dual;")
    PID=$(echo "$PID" | tr -d '[:space:]')

    call_database "INSERT INTO products VALUES ('$PID','$NAME','$TYPE',$QTY,SYSDATE);"
else
    call_database "UPDATE products SET quantity = quantity + $QTY WHERE product_id='$PID';"
fi

./assign_location.sh "$PID" "$TYPE" "$QTY"

if [ $? -ne 0 ]; then
    echo "Product NOT stored due to capacity limits"
    exit 1
fi

call_database "COMMIT;"

echo "Product stored with ID: $PID"
