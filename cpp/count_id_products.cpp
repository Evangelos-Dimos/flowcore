#include "count_id_products.h"
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int countIdProductsFromFile(const string& filename) 
{
    ifstream file(filename);
    string line;
    int count = 0;

    if (!file.is_open())
    {
        cout << "Error: Could not open file: " << filename << endl;
        return -1;
    }
    
    while (getline(file, line))
    {
        if (!line.empty())
        {
            count++;
        }
    }
    
    return count;
}