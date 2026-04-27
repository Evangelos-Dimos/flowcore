#!/bin/bash
# sync_config_to_db.sh

source ../config/warehouse.conf
source ../config/db.conf
source ./docker.sh

# 1. Sync product types
TYPE_LIST=$(echo $VALID_TYPES | tr ' ' ',')
echo "🔄 Syncing product types to database..."

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
BEGIN
    sync_product_types('$TYPE_LIST');
END;
/
EXIT;
EOF

# 2. Sync location mappings with MAX_ITEMS_PER_LOCATION
MAPPINGS=""
for var in $(set | grep -E '^ALLOWED_LOCATIONS_' | cut -d'=' -f1); do
    product_type=$(echo $var | sed 's/ALLOWED_LOCATIONS_//' | tr '[:upper:]' '[:lower:]')
    location_value=${!var}
    MAPPINGS="${MAPPINGS}${product_type}:${location_value},"
done
MAPPINGS=${MAPPINGS%,}

echo "🔄 Syncing location config (max capacity: $MAX_ITEMS_PER_LOCATION)..."

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE << EOF
BEGIN
    sync_location_config('$MAPPINGS', $MAX_ITEMS_PER_LOCATION);
END;
/
EXIT;
EOF

echo "✅ Full config synced successfully!"