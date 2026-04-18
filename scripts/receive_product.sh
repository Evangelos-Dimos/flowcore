source ../config/warehouse.conf

PRODUCT_ID=$1	#παιρνει το 1ο argument (id προιοντος)
PRODUCT_TYPE=$2	#παιρνει το 2ο argument (τυπος προιοντος)
LOCATION=$3	#παιρνει το 3ο argument (location/rack)

#ελεγχος αν λειπουν οι παραμετροι
if [ -z "$PRODUCT_ID" ] || [ -z "$PRODUCT_TYPE" ] || [ -z "$LOCATION" ]; then
	echo "[ERROR] Missing input" >> ../logs/system.log #error στο log
	echo "Usage: ./receive_product.sh <id> <type> <location>" #Σωστη χρηση
	exit 1 #στοπ script
fi

#δημιουργει δυναμικα το ονομα της μεταβλητης config
VAR_NAME="ALLOWED_LOCATIONS_${PRODUCT_TYPE}" 

ALLOWED_LOCATION=${!VAR_NAME}

if [ -z "$ALLOWED_LOCATION" ]; then
	echo "[ERROR] Unknown product type: $PRODUCT_TYPE" >> ../logs/system.log #error στο log
	echo "Invalid product type" #μηνυμα στον user
	exit 1 ##στοπ script
fi

#ελεγχος αν το προιον μπαινει στο lacation/rack
if [ "$LOCATION" != "$ALLOWED_LOCATION" ]; then
	echo "[ERROR] $PRODUCT_TYPE must be stored in $ALLOWED_LOCATION, not $LOCATION" >> ../logs/system.log  #error στο log
	echo "Invalid location"  # μηνυμα στον χρηστη
	exit 1 #στοπ script
fi

#μετραει ποσο προιοντα υπαρχουν ηδη στο συγκεκριμενο location/rack
COUNT=$(grep -c ",$LOCATION$" ../data/inventory.txt)

#ελεγχος αν εχει γεμισει το lacation/rack
if [ "$COUNT" -ge "$MAX_ITEMS_PER_LOCATION" ]; then
	echo "[ERROR] $LOCATION is full" >> ../logs/system.log  # error στο log
	echo "Location is full"  # μηνυμα στον user
	exit 1  #στοπ script
fi

#αποθηκευση προιοντος στο inventory
echo "$PRODUCT_ID,$PRODUCT_TYPE,$LOCATION" >> ../data/inventory.txt  # append στο αρχειο
NEW_COUNT=$(grep -c ",$LOCATION$" ../data/inventory.txt)

#καταγραφη σωστης ενεργειας
echo "[INFO] Stored $PRODUCT_ID in $LOCATION" >> ../logs/system.log  # log info
echo "Product stored successfully. Items in $LOCATION: $NEW_COUNT"

