#include<iostream>
#include<vector>
#include<map>
#include "syn.h"

using namespace std;

typedef struct NetPin{
    string name;
    int pos;
};

typedef struct Net{
    string name;
    int num_of_pins;
    vector<NetPin> net_pins;
};

typedef struct Netlist{
    vector<Net> nets;
};
int netlist_creation(vector<Component> &component_list, vector<Wire> &wire_list, string filename, string module_name);
