#include "net.h"
#include <map>
typedef struct{

    int out;

}Output;

int simulate_output(vector<Component> &component_list, map<string, int> &array_pins, string filename);
