#!/bin/bash

echo "=== FlowCore Database Setup ==="
echo "Δώσε το όνομα του Docker container σου:"
read CONTAINER
echo "Δώσε το password της Oracle σου:"
read PASSWORD
echo "Δώσε το service name (πχ FREEPDB1):"
read SERVICE

# ενημέρωση config
sed -i "s/DB_CONTAINER=.*/DB_CONTAINER=$CONTAINER/" ../config/db.conf
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$PASSWORD/" ../config/db.conf
sed -i "s/DB_SERVICE=.*/DB_SERVICE=$SERVICE/" ../config/db.conf

echo "✓ Αρχείο config/db.conf ενημερώθηκε!"
echo "Στοιχεία:"
echo "  Container: $CONTAINER"
echo "  Service:   $SERVICE"
