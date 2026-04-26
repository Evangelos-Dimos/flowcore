#include <iostream>
#include <string>
#include "count_id_products.h"

using namespace std;

int main() 
{
    string filename = "/home/dimos/flowcore/tmp/inventory_export.csv";
    
    int count = countIdProductsFromFile(filename);
    
    cout << "Total unique product IDs: " << count << endl;
    
    return 0;
}