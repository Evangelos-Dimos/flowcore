#!/bin/bash
# docker.sh

source ../config/db.conf

call_database() {
    docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
    SET HEADING OFF FEEDBACK OFF
    $1
    COMMIT;
    EXIT;
EOF
}

export_to_csv() {
    local table=$1
    local output=$2
    
    case $table in
        "customers")
            query="SELECT TRIM(customer_id) || ',' || TRIM(customer_fname) || ',' || TRIM(customer_lname) || ',' || TRIM(address) FROM customers"
            ;;
        "products")
            query="SELECT TRIM(product_id) || ',' || TRIM(name) || ',' || TRIM(product_type) || ',' || TRIM(TO_CHAR(quantity)) || ',' || TRIM(TO_CHAR(receive_date, 'YYYY-MM-DD')) FROM products"
            ;;
        "locations")
            query="SELECT TRIM(location_id) || ',' || TRIM(TO_CHAR(max_capacity)) || ',' || TRIM(TO_CHAR(current_count)) FROM locations"
            ;;
        "inventory")
            query="SELECT TRIM(product_id) || ',' || TRIM(product_type) || ',' || TRIM(location_id) || ',' || TRIM(TO_CHAR(quantity_number)) FROM inventory"
            ;;
        "orders")
            query="SELECT TRIM(TO_CHAR(order_id)) || ',' || TRIM(TO_CHAR(customer_id)) || ',' || TRIM(status) || ',' || TRIM(TO_CHAR(ordered_at, 'YYYY-MM-DD')) FROM orders"
            ;;
        "order_items")
            query="SELECT TRIM(TO_CHAR(order_item_id)) || ',' || TRIM(TO_CHAR(order_id)) || ',' || TRIM(product_id) || ',' || TRIM(TO_CHAR(quantity)) FROM order_items"
            ;;
        *)
            echo "Unknown table: $table"
            return 1
            ;;
    esac
    
    docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF > "$output"
    SET HEADING OFF FEEDBACK OFF PAGESIZE 0
    $query;
    EXIT;
EOF
    
    # Αφαίρεσε κενές γραμμές
    sed -i '/^$/d' "$output"
}