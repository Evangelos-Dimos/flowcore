INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

# file exists?
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Inventory file not found"
    echo "[ERROR] Inventory file missing" >> "$LOG_FILE"
    exit 1
fi

# empty?
if [ ! -s "$INVENTORY_FILE" ]; then
    echo "Inventory is empty"
    exit 0
fi

echo "------ INVENTORY ------"
cat "$INVENTORY_FILE"
echo "-----------------------"
