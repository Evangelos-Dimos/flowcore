# καθαριζει το inventory και κραταει το header
echo "product_id,product_type,location" > ../data/inventory.txt
echo "[INFO] Inventory reset" >> ../logs/system.log # γραφει στο log
echo "Inventory reset completed." #μηνυμα στον user
