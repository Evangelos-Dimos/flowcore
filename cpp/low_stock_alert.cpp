// cpp/low_stock_alert.cpp
#include "low_stock_alert.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

vector<Product> getLowStockProducts(const string& filename, int threshold) {
    vector<Product> lowStock;
    ifstream file(filename);
    string line;
    
    while (getline(file, line)) {
        Product p;
        string qtyStr;
        
        size_t pos1 = line.find(',');
        size_t pos2 = line.find(',', pos1 + 1);
        size_t pos3 = line.find(',', pos2 + 1);
        
        p.id = line.substr(0, pos1);
        p.name = line.substr(pos1 + 1, pos2 - pos1 - 1);
        qtyStr = line.substr(pos3 + 1);
        
        p.quantity = stoi(qtyStr);
        
        if (p.quantity < threshold) {
            lowStock.push_back(p);
        }
    }
    return lowStock;
}

int main(int argc, char* argv[]) {
    int threshold = 3;  // default
    
    if (argc >= 2) {
        threshold = atoi(argv[1]);
    }
    
    vector<Product> lowStock = getLowStockProducts("../tmp/inventory_export.csv", threshold);
    
    cout << "=== LOW STOCK ALERT ===" << endl;
    cout << "Threshold: < " << threshold << " items" << endl;
    cout << endl;
    
    if (lowStock.empty()) {
        cout << "✓ No products with low stock" << endl;
        return 0;
    }
    
    cout << "WARNING: The following products need restocking:" << endl;
    for (const auto& p : lowStock) {
        cout << "  " << p.id << " - " << p.name << " (only " << p.quantity << " left)" << endl;
    }
    
    return lowStock.size();
}
