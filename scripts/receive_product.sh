source ../config/warehouse.conf

PRODUCT_ID=$1   #1st argument id product
PRODUCT_TYPE=$2 #2nd argument product type
QUANTITY=$3     #3rd argument quantity

#Checks if there are all the arguments
if [ -z "$PRODUCT_ID" ] || [ -z "$PRODUCT_TYPE" ] || [ -z "$QUANTITY" ]; then
        echo "[ERROR] Missing input" >> ../logs/system.log 
        echo "Arguments missing - Usage: ./receive_product.sh <id> <type> <quantity>" 
        exit 1 
fi

#Checks if type of product is valid
VALID=0
for type in $VALID_TYPES;
    do
        if [ "$PRODUCT_TYPE" = "$type" ]; then
                VALID=1
        fi
    done

if [ "$VALID" -eq 0 ]; then
        echo "[ERROR] Unknown product type: $PRODUCT_TYPE" >> ../logs/system.log
        echo "Invalid product type. Valid types: $VALID_TYPES"
        exit 1
fi

#Sending the product to pending 
echo "$PRODUCT_ID,$PRODUCT_TYPE,$QUANTITY" >> ../data/pending.txt  

#Adds the message to log
echo "[INFO] Stored $PRODUCT_ID in $QUANTITY" >> ../logs/system.log
