source ../config/warehouse.conf

PRODUCT_ID=$1	#παιρνει το 1ο argument (id προιοντος)
PRODUCT_TYPE=$2	#παιρνει το 2ο argument (τυπος προιοντος)
QUANTITY=$3	#παιρνει το 3ο argument (location/rack)

#ελεγχος αν λειπουν οι παραμετροι
if [ -z "$PRODUCT_ID" ] || [ -z "$PRODUCT_TYPE" ] || [ -z "$QUANTITY" ]; then
	echo "[ERROR] Missing input" >> ../logs/system.log #error στο log
	echo "Usage: ./receive_product.sh <id> <type> <quantity>" #Σωστη χρηση
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

#αποθηκευση προιοντος στο inventory
echo "$PRODUCT_ID,$PRODUCT_TYPE,$QUANTITY" >> ../data/inventory.txt  # append στο αρχειο

#καταγραφη σωστης ενεργειας
echo "[INFO] Stored $PRODUCT_ID in $QUANTITY" >> ../logs/system.log  # log info

