#!/bin/bash
# sync_config_to_db.sh

source ../config/warehouse.conf
source ../config/db.conf
source ./docker.sh

# Δημιουργία comma-separated list
TYPE_LIST=$(echo $VALID_TYPES | tr ' ' ',')


echo "🔄 Syncing product types to database..."
echo "   Types: $VALID_TYPES"

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
SET SERVEROUTPUT ON
BEGIN
    sync_product_types('$TYPE_LIST');
END;
/
EXIT;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Database sync completed successfully!"
else
    echo "❌ Database sync failed!"
    exit 1
fi

MAPPINGS=""
for var in $(set | grep -E '^ALLOWED_LOCATIONS_' | cut -d'=' -f1); do
    product_type=$(echo $var | sed 's/ALLOWED_LOCATIONS_//' | tr '[:upper:]' '[:lower:]')
    location_value=${!var}
    MAPPINGS="${MAPPINGS}${product_type}:${location_value},"
done
MAPPINGS=${MAPPINGS%,}

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
BEGIN
    sync_location_config('$MAPPINGS');
END;
/
EXIT;
EOF
