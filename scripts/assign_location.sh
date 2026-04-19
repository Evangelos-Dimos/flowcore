#!/bin/bash
source ../config/warehouse.conf

PENDING_FILE="../data/pending.txt"
INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

#Checks if pending file exists
if [ ! -f "$PENDING_FILE" ]; then
        echo "[ERROR] Pending file not found" >> "$LOG_FILE"
        exit 1
fi

echo "Processing pending file..."

while IFS=',' read -r id type quantity; do
        #Skip empty lines
        if [ -z "$id" ]; then
                continue
        fi

        #Checks if type exists
        if [ -z "$type" ]; then
                echo "[ERROR] No type for product: $id" >> "$LOG_FILE"
                continue
        fi

        #Gets the location from conf based on product type
        VAR_NAME="ALLOWED_LOCATIONS_${type}"
        LOCATION=${!VAR_NAME}

        #Checks if location was found
        if [ -z "$LOCATION" ]; then
                echo "[WARNING] Unknown type '$type' for product $id" >> "$LOG_FILE"
                continue
        fi

        #Adds product to inventory
        echo "$id,$type,$quantity,$LOCATION" >> "$INVENTORY_FILE"

        #Removes product from pending
        sed -i "/^$id,/d" "$PENDING_FILE"

        echo "[INFO] Assigned $id ($type) to $LOCATION" >> "$LOG_FILE"

done < "$PENDING_FILE"

echo "Done processing inventory"
