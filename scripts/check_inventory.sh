#!/bin/bash
source ../config/warehouse.conf

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
