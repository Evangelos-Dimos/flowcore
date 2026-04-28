// cpp/low_stock_alert.h
#ifndef LOW_STOCK_ALERT_H
#define LOW_STOCK_ALERT_H

#include <string>
#include <vector>

using namespace std;

struct Product 
{
    string id;
    string name;
    int quantity;
};

// Function declarations
vector<Product> getLowStockProducts(const string& filename, int threshold);

void runLowStockAlert(const string& filename, int threshold);

#endif
