#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

using namespace std;

int main() {

    string filename = "/home/chris/las_project/flowcore/tmp/inventory_export.csv";
    ifstream file(filename);

    string line;
    int laptops = 0, tablets = 0, smartphones = 0;

    while (getline(file, line)) {
        stringstream ss(line);
        string id, name, type;

        getline(ss, id, ',');
        getline(ss, name, ',');
        getline(ss, type, ',');

        if (type == "laptop") laptops++;
        else if (type == "tablet") tablets++;
        else if (type == "smartphone") smartphones++;
    }

    cout << "Product Summary:" << endl;
    cout << "Laptops: " << laptops << endl;
    cout << "Tablets: " << tablets << endl;
    cout << "Smartphones: " << smartphones << endl;

    return 0;
}