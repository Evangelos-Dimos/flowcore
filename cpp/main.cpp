#include <iostream>
#include <string>
#include "count_id_products.h"
#include "check_configuration.h"
#include "low_stock_alert.h"

using namespace std;

int main() 
{
    string filename = "/home/alex/flowcore/config/warehouse.conf";
    
    int count = countIdProductsFromFile(filename);
    cout << "Total unique product IDs: " << count << endl;

    check_quantity_config();

    runLowStockAlert("../tmp/inventory_export.csv", 3);

    return 0;
}