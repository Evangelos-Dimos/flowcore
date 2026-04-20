PRODUCT_ID="$1"
ORDER_QUANTITY="$2"

INVENTORY_FILE="../data/inventory.txt"
LOG_FILE="../logs/system.log"
DISPATCHED_ORDER="../data/orders.txt"

if [ ! -f "$INVENTORY_FILE" ]; then
	echo "Inventory is empty!">>"$LOG_FILE"
	exit 1
fi

while IFS=',' read -r product_id product_type location;do
	if [ "$PRODUCT_ID" != "$product_id" ]; then
		continue
	else

		echo "Product with id: $product_id ($product_type) at location: $location has dispatched"

		FIND_EXISTING_QUANTITY_SQL=$(docker exec -i oracle23ai sqlplus -s system/my_strong_password@FREEPDB1 <<EOF
SET HEAD OFF FEED OFF
SELECT quantity_number FROM inventory
WHERE product_id='$product_id';
EXIT;
EOF
						)
		CURRENT_QUANTITY=$(echo "$CURRENT_QUANTITY" | tr -d ' ' | tr -d '\n' | tr -d '\r')

		QUERY=$(cat <<EOF
INSERT INTO orders(product_id, quantity) VALUES ('$product_id','$ORDER_QUANTITY');
COMMIT;
UPDATE inventory SET quantity_number = $FIND_EXISTING_QUANTITY_SQL - $ORDER_QUANTITY
WHERE product_id='$product_id';
COMMIT;
EXIT;
EOF
)
		docker exec -i oracle23ai sqlplus -s system/my_strong_password@FREEPDB1 <<< "$QUERY"
		sed -i "/^$product_id/d" "$INVENTORY_FILE"
echo "[INFO] Product $PRODUCT_ID removed from inventory (stock: 0)" >> "$LOG_FILE"
exit
	fi
done<"$INVENTORY_FILE"

