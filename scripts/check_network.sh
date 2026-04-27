#!/bin/bash

source "$(dirname "$0")/../config/db.conf"

echo "======================================"
echo "      NETWORK & SYSTEM CHECK"
echo "======================================"

# ============================================
# 1. CHECK DOCKER CONTAINER
# ============================================

echo "🔍 Checking Docker container..."

docker ps | grep -q "$DB_CONTAINER"

if [ $? -ne 0 ]; then
    echo "❌ Database container '$DB_CONTAINER' is NOT running"
    exit 1
else
    echo "✅ Docker container '$DB_CONTAINER' is running"
fi

# ============================================
# 2. CHECK DATABASE CONNECTIVITY
# ============================================

echo "🔍 Checking database connectivity..."

docker exec -i $DB_CONTAINER sqlplus -s $DB_CONNECT <<EOF > /dev/null
EXIT;
EOF

if [ $? -ne 0 ]; then
    echo "❌ Cannot connect to database"
    exit 1
else
    echo "✅ Database connection OK"
fi

# ============================================
# 3. CHECK NETWORK (PING)
# ============================================

echo "🔍 Checking network connectivity..."

ping -c 1 8.8.8.8 > /dev/null

if [ $? -ne 0 ]; then
    echo "⚠️ Network unreachable"
else
    echo "✅ Network reachable"
fi

# ============================================
# 4. CHECK DB PORT (1521)
# ============================================

echo "🔍 Checking DB port..."

nc -z localhost 1521

if [ $? -ne 0 ]; then
    echo "⚠️ Port 1521 not reachable"
else
    echo "✅ Port 1521 is open"
fi

# ============================================

echo "======================================"
echo "✅ SYSTEM READY"
echo "======================================"

