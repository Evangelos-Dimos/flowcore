#include <iostream>
#include <fstream>
#include <string>

int main() {
    std::ifstream config("../config/warehouse.conf");
    if (!config.is_open()) {
        std::cerr << "❌ Cannot open warehouse.conf" << std::endl;
        return 1;
    }
    
    std::string line;
    int max_capacity = 0;
    
    while (getline(config, line)) {
        if (line.find("MAX_ITEMS_PER_LOCATION") != std::string::npos) {
            sscanf(line.c_str(), "MAX_ITEMS_PER_LOCATION=%d", &max_capacity);
        }
    }
    
    if (max_capacity <= 0 || max_capacity > 1000) {
        std::cerr << "❌ Invalid MAX_ITEMS_PER_LOCATION: " << max_capacity << std::endl;
        return 1;
    }
    
    std::cout << "✅ Configuration is valid!" << std::endl;
    return 0;
}