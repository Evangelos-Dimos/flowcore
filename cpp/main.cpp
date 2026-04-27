#include <iostream>
#include <string>
#include "count_id_products.h"
#include "check_configuration.cpp"

using namespace std;

int main() 
{
    string filename = "/home/alex/flowcore/config/warehouse.conf";
    
    int count = countIdProductsFromFile(filename);
    
    cout << "Total unique product IDs: " << count << endl;

    check_quantity_config();
    
    return 0;
}