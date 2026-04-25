// cpp/count_products.cpp
#include "count_products.h"
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int countProductsFromFile(const string& filename) {
    ifstream file(filename);
    string line;
    int count = 0;
    
    while (getline(file, line)) {
        if (!line.empty()) {
            count++;
        }
    }
    
    return count;
}

int main() {
    ifstream file("../tmp/inventory_export.csv");
    string line;
    int count = 0;
    
    while (getline(file, line)) {
        if (!line.empty()) {
            count++;
        }
    }
    
    cout << "Total products in warehouse: " << count << endl;
    
    return 0;
}
