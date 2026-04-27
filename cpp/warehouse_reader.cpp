#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

// ============================================
// Βοηθητική συνάρτηση για ασφαλή μετατροπή
// ============================================
int safe_stoi(const string& str) {
    if (str.empty()) return 0;
    try {
        return stoi(str);
    } catch (...) {
        cerr << "⚠️ Warning: Cannot convert '" << str << "' to number" << endl;
        return 0;
    }
}

// ============================================
// 1. ΚΛΑΣΗ PRODUCT
// ============================================
class Product {
public:
    string product_id;
    string name;
    string product_type;
    int quantity;
    string receive_date;
    
    Product(string id, string n, string type, int qty, string date)
        : product_id(id), name(n), product_type(type), quantity(qty), receive_date(date) {}
    
    void display() const {
        cout << "  ID: " << product_id
             << ", Name: " << name
             << ", Type: " << product_type
             << ", Qty: " << quantity
             << ", Date: " << receive_date << endl;
    }
};

// ============================================
// 2. ΚΛΑΣΗ CUSTOMER
// ============================================
class Customer {
public:
    int customer_id;
    string first_name;
    string last_name;
    string address;
    
    Customer(int id, string fname, string lname, string addr)
        : customer_id(id), first_name(fname), last_name(lname), address(addr) {}
    
    void display() const {
        cout << "  ID: " << customer_id
             << ", Name: " << first_name << " " << last_name
             << ", Address: " << address << endl;
    }
};

// ============================================
// 3. ΚΛΑΣΗ ORDER
// ============================================
class Order {
public:
    int order_id;
    int customer_id;
    string status;
    string ordered_at;
    
    Order(int oid, int cid, string stat, string date)
        : order_id(oid), customer_id(cid), status(stat), ordered_at(date) {}
    
    void display() const {
        cout << "  Order ID: " << order_id
             << ", Customer ID: " << customer_id
             << ", Status: " << status
             << ", Date: " << ordered_at << endl;
    }
};

// ============================================
// 4. ΚΛΑΣΗ ORDER ITEM
// ============================================
class OrderItem {
public:
    int order_item_id;
    int order_id;
    string product_id;
    int quantity;
    
    OrderItem(int oiid, int oid, string pid, int qty)
        : order_item_id(oiid), order_id(oid), product_id(pid), quantity(qty) {}
    
    void display() const {
        cout << "  Item ID: " << order_item_id
             << ", Order ID: " << order_id
             << ", Product: " << product_id
             << ", Qty: " << quantity << endl;
    }
};

// ============================================
// 5. ΚΛΑΣΗ INVENTORY ITEM
// ============================================
class InventoryItem {
public:
    string product_id;
    string product_type;
    string location_id;
    int quantity;
    
    InventoryItem(string pid, string ptype, string loc, int qty)
        : product_id(pid), product_type(ptype), location_id(loc), quantity(qty) {}
    
    void display() const {
        cout << "  Product: " << product_id
             << ", Type: " << product_type
             << ", Location: " << location_id
             << ", Stock: " << quantity << endl;
    }
};

// ============================================
// 6. ΚΛΑΣΗ RACK (LOCATION)
// ============================================
class Rack {
public:
    string rack_id;
    int max_capacity;
    int current_count;
    
    Rack(string rid, int max_cap, int curr)
        : rack_id(rid), max_capacity(max_cap), current_count(curr) {}
    
    void display() const {
        cout << "  Rack: " << rack_id
             << ", Capacity: " << current_count << "/" << max_capacity << endl;
    }
};

// ============================================
// 7. CSV READER
// ============================================
class CSVReader {
public:
    static vector<Product> readProducts(const string& filename) {
        vector<Product> products;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return products;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string pid, name, type, qty_str, date;
            
            getline(ss, pid, ',');
            getline(ss, name, ',');
            getline(ss, type, ',');
            getline(ss, qty_str, ',');
            getline(ss, date, ',');
            
            if (pid.empty()) continue;
            
            int qty = safe_stoi(qty_str);
            products.push_back(Product(pid, name, type, qty, date));
        }
        return products;
    }
    
    static vector<Customer> readCustomers(const string& filename) {
        vector<Customer> customers;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return customers;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string id_str, fname, lname, addr;
            
            getline(ss, id_str, ',');
            getline(ss, fname, ',');
            getline(ss, lname, ',');
            getline(ss, addr, ',');
            
            if (id_str.empty()) continue;
            
            int id = safe_stoi(id_str);
            customers.push_back(Customer(id, fname, lname, addr));
        }
        return customers;
    }
    
    static vector<Order> readOrders(const string& filename) {
        vector<Order> orders;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return orders;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string oid_str, cid_str, status, date;
            
            getline(ss, oid_str, ',');
            getline(ss, cid_str, ',');
            getline(ss, status, ',');
            getline(ss, date, ',');
            
            if (oid_str.empty()) continue;
            
            int oid = safe_stoi(oid_str);
            int cid = safe_stoi(cid_str);
            orders.push_back(Order(oid, cid, status, date));
        }
        return orders;
    }
    
    static vector<OrderItem> readOrderItems(const string& filename) {
        vector<OrderItem> orderItems;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return orderItems;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string oiid_str, oid_str, pid, qty_str;
            
            getline(ss, oiid_str, ',');
            getline(ss, oid_str, ',');
            getline(ss, pid, ',');
            getline(ss, qty_str, ',');
            
            if (oiid_str.empty()) continue;
            
            int oiid = safe_stoi(oiid_str);
            int oid = safe_stoi(oid_str);
            int qty = safe_stoi(qty_str);
            orderItems.push_back(OrderItem(oiid, oid, pid, qty));
        }
        return orderItems;
    }
    
    static vector<InventoryItem> readInventory(const string& filename) {
        vector<InventoryItem> inventory;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return inventory;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string pid, ptype, loc, qty_str;
            
            getline(ss, pid, ',');
            getline(ss, ptype, ',');
            getline(ss, loc, ',');
            getline(ss, qty_str, ',');
            
            if (pid.empty()) continue;
            
            int qty = safe_stoi(qty_str);
            inventory.push_back(InventoryItem(pid, ptype, loc, qty));
        }
        return inventory;
    }
    
    static vector<Rack> readRacks(const string& filename) {
        vector<Rack> racks;
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "❌ Cannot open: " << filename << endl;
            return racks;
        }
        
        string line;
        while (getline(file, line)) {
            if (line.empty()) continue;
            
            stringstream ss(line);
            string rid, max_str, curr_str;
            
            getline(ss, rid, ',');
            getline(ss, max_str, ',');
            getline(ss, curr_str, ',');
            
            if (rid.empty()) continue;
            
            racks.push_back(Rack(rid, safe_stoi(max_str), safe_stoi(curr_str)));
        }
        return racks;
    }
};

// ============================================
// 8. MAIN
// ============================================
int main() {
    cout << "╔═══════════════════════════════════════════════════════════╗" << endl;
    cout << "║              WAREHOUSE DATA IMPORT                         ║" << endl;
    cout << "╚═══════════════════════════════════════════════════════════╝" << endl;
    cout << endl;
    
    // 1. READ PRODUCTS
    vector<Product> products = CSVReader::readProducts("../tmp/products_export.csv");
    cout << "📦 Products:      " << products.size() << " items" << endl;
    
    // 2. READ CUSTOMERS
    vector<Customer> customers = CSVReader::readCustomers("../tmp/customers_export.csv");
    cout << "👥 Customers:     " << customers.size() << " items" << endl;
    
    // 3. READ ORDERS
    vector<Order> orders = CSVReader::readOrders("../tmp/orders_export.csv");
    cout << "📋 Orders:        " << orders.size() << " items" << endl;
    
    // 4. READ ORDER ITEMS
    vector<OrderItem> orderItems = CSVReader::readOrderItems("../tmp/order_items_export.csv");
    cout << "📄 Order Items:   " << orderItems.size() << " items" << endl;
    
    // 5. READ INVENTORY
    vector<InventoryItem> inventory = CSVReader::readInventory("../tmp/inventory_export.csv");
    cout << "📊 Inventory:     " << inventory.size() << " items" << endl;
    
    // 6. READ RACKS
    vector<Rack> racks = CSVReader::readRacks("../tmp/locations_export.csv");
    cout << "🏪 Racks:         " << racks.size() << " items" << endl;
    
    // ============================================
    // DISPLAY RESULTS
    // ============================================
    cout << "\n═══════════════════════════════════════════════════════════" << endl;
    cout << "                    DATA DISPLAY" << endl;
    cout << "═══════════════════════════════════════════════════════════" << endl;
    
    // Products
    cout << "\n📦 PRODUCTS (" << products.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& p : products) {
        p.display();
    }
    
    // Customers
    cout << "\n👥 CUSTOMERS (" << customers.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& c : customers) {
        c.display();
    }
    
    // Orders
    cout << "\n📋 ORDERS (" << orders.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& o : orders) {
        o.display();
    }
    
    // Order Items
    cout << "\n📄 ORDER ITEMS (" << orderItems.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& oi : orderItems) {
        oi.display();
    }
    
    // Inventory
    cout << "\n📊 INVENTORY (" << inventory.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& i : inventory) {
        i.display();
    }
    
    // Racks
    cout << "\n🏪 RACKS (" << racks.size() << ")" << endl;
    cout << "─────────────────────────────────────────────────────────" << endl;
    for (const auto& r : racks) {
        r.display();
    }
    
    cout << "\n═══════════════════════════════════════════════════════════" << endl;
    cout << "                    IMPORT COMPLETE" << endl;
    cout << "═══════════════════════════════════════════════════════════" << endl;
    
    return 0;
}