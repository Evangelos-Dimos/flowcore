#!/bin/bash
source "$(dirname "$0")/docker.sh"

echo "==============================================="
echo "              INVENTORY STATUS"
echo "==============================================="

printf "%-12s %-20s %-10s %-10s\n" "PRODUCT ID" "PRODUCT NAME" "LOCATION" "QUANTITY"
echo "-----------------------------------------------"

call_database "
SELECT 
    RPAD(p.product_id,12) || ' ' ||
    RPAD(p.name,20) || ' ' ||
    RPAD(i.location_id,10) || ' ' ||
    i.quantity_number
FROM inventory i
JOIN products p ON i.product_id = p.product_id
ORDER BY i.location_id;
"

echo "==============================================="
