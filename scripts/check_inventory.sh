INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

<<<<<<< HEAD
INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"

#Checks if the file exists
if [ ! -f "../data/inventory.txt" ]; then
        echo "[ERROR] Inventory file not found" >> ../logs/system.log
        echo "Inventory file not found"
        exit 1
=======
# file exists?
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Inventory file not found"
    echo "[ERROR] Inventory file missing" >> "$LOG_FILE"
    exit 1
>>>>>>> 6f62d1f (Changes for receive, assign, check)
fi

# empty?
if [ ! -s "$INVENTORY_FILE" ]; then
    echo "Inventory is empty"
    exit 0
fi

<<<<<<< HEAD
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
=======
echo "------ INVENTORY ------"
cat "$INVENTORY_FILE"
echo "-----------------------"
>>>>>>> 6f62d1f (Changes for receive, assign, check)
