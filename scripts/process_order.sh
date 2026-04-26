#!/bin/bash
source "$(dirname "$0")/docker.sh"

OID=$1

if [ -z "$OID" ]; then
    echo "Usage: ./process_order.sh <order_id>"
    exit 1
fi

# call procedure
call_database "
BEGIN
    process_order_proc($OID);
END;
/"

# get status
STATUS=$(call_database "SELECT status FROM orders WHERE order_id=$OID;")
STATUS=$(echo "$STATUS" | tr -d '[:space:]')

echo "Order $OID → $STATUS"
