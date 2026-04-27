#!/bin/bash

echo "======================================"
echo "       FLOWCORE WAREHOUSE DEMO"
echo "======================================"

# ============================================
# 1. NETWORK CHECK
# ============================================

echo ""
echo "🔧 Step 1: Checking system readiness..."
./check_network.sh || exit 1

# ============================================
# 2. CONFIG VALIDATION (C++)
# ============================================

echo ""
echo "🔧 Step 2: Validating configuration..."
./check_system_configuration.sh || exit 1

# ============================================
# 3. SYNC CONFIG TO DATABASE
# ============================================

echo ""
echo "🔧 Step 3: Syncing configuration to database..."
./sync_config_to_db.sh || exit 1

# ============================================
# 4. CLEAN OLD DATA (IMPORTANT FOR DEMO)
# ============================================

echo ""
echo "🧹 Cleaning old data..."

docker exec -i oracle-db sqlplus -s system/flowcore123@//localhost:1521/FREEPDB1 <<EOF
DELETE FROM order_items;
DELETE FROM orders;
DELETE FROM inventory;
DELETE FROM products;
COMMIT;
EXIT;
EOF

# ============================================
# 5. RECEIVE PRODUCTS (SIMULATION)
# ============================================

echo ""
echo "📦 Step 4: Receiving products..."

./receive_product.sh "Laptop Dell" laptop 2
./receive_product.sh "iPhone 15" smartphone 2
./receive_product.sh "iPad Air" tablet 2

# ============================================
# 6. SHOW INVENTORY
# ============================================

echo ""
echo "📊 Step 5: Current inventory..."
./check_inventory.sh

# ============================================
# 7. CREATE ORDER
# ============================================

echo ""
echo "🧾 Step 6: Creating order..."

echo "🔍 Selecting available product with stock..."

PRODUCT_ID=$(docker exec -i oracle-db sqlplus -s system/flowcore123@//localhost:1521/FREEPDB1 <<EOF
SET HEADING OFF FEEDBACK OFF
SELECT product_id FROM inventory WHERE quantity_number > 0 AND ROWNUM = 1;
EXIT;
EOF
)

PRODUCT_ID=$(echo "$PRODUCT_ID" | tr -d '[:space:]')

echo "Selected product: $PRODUCT_ID"

./create_order.sh 1 $PRODUCT_ID 1
ORDER_ID=$(docker exec -i oracle-db sqlplus -s system/flowcore123@//localhost:1521/FREEPDB1 <<EOF
SET HEADING OFF FEEDBACK OFF
SELECT MAX(order_id) FROM orders;
EXIT;
EOF
)

ORDER_ID=$(echo "$ORDER_ID" | tr -d '[:space:]')

echo "Order ID to process: $ORDER_ID"

# ============================================
# 8. PROCESS ORDER
# ============================================

echo ""
echo "🚚 Step 7: Processing order..."

./process_order.sh $ORDER_ID

# ============================================
# 9. FINAL INVENTORY
# ============================================

echo ""
echo "📊 Step 8: Final inventory..."
./check_inventory.sh

# ============================================

echo ""
echo "======================================"
echo "✅ DEMO COMPLETED SUCCESSFULLY"
echo "======================================"
