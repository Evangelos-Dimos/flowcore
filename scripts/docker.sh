source ../config/warehouse.conf
source ../config/db.conf

call_database() {
    docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF
    SET HEADING OFF FEEDBACK OFF
    $1
    EXIT;
EOF
}
