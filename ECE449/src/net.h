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
    //vector<Gate> gates;
};

/*
typedef struct Component_Position{
    string name; //gate name
    int position;

    Component_Position(string n, int p):
        name(n),
        position(p){}
};
typedef struct Connection{

    string name; //specific sname
    vector<Component_Position> component_position;

    Connection(string n):
        name(n){}

};

typedef struct Net{
    string name; //top level name
    map<string, Connection> list_of_pin_connections;
};

typedef struct Net_Component{
    string name;
    vector<string> pins;
};

typedef struct Netlist{
    vector<Net> nets;
    vector<Net_Component> net_components;    
};

*/
int netlist_creation(vector<Component> &component_list, vector<Wire> &wire_list, string filename, ifstream& input_file);
