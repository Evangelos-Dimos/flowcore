#!/bin/bash
source ../config/warehouse.conf

INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

#Checks if the file exists
if [ ! -f "../data/inventory.txt" ]; then
        echo "[ERROR] Inventory file not found" >> ../logs/system.log
        echo "Inventory file not found"
        exit 1
fi

#Checks if inventory is empty
if [ ! -s "../data/inventory.txt" ]; then
        echo "[WARNING] Inventory is empty" >> ../logs/system.log
        echo "Inventory is empty"
        exit 0
fi

echo "FlowCore Warehouse - Inventory Check"

#Prints all products
echo "ID,Type,Quantity,Location"

while IFS=',' read -r id type quantity location; 
	do
        	echo "$id,$type,$quantity,$location"
	done < "$INVENTORY_FILE"

total=$(wc -l < "$INVENTORY_FILE")
echo "Total unique items: $total"

#Logs completion
echo "[INFO] Inventory check completed. Total items: $total" >> "$LOG_FILE"
