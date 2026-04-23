docker exec -i oracle-flowcore-db sqlplus -s system/flowcore123@FREEDB1 <<EOF

 

SET LINESIZE 200
SET PAGESIZE 50

 

SELECT i.product_id,
       i.product_type,
       i.quantity_number,
       l.rack
FROM inventory i
JOIN locations l ON i.location_id = l.location_id;

 

EXIT;
EOF
