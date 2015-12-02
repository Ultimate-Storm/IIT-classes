#include <iostream>
#include <vector>
#include <map>
#include <fstream>
#include <tr1/unordered_set>
#include <string>
#include <sstream>
#include <cmath>
#include "sim.h"
// Yo you have a list of pins with their widths. Use this array list to re do how you set up your hash table. Too tired now. It'll be easy once this is done. Then it's just a matter of computation

using namespace std;
using namespace tr1;

int netlist_creation(vector<Component> &component_list, vector<Wire> &wire_list, string filename, string module_name){

    //First create File
    ofstream netlist_input_file(string(filename+".netlist").c_str());
    
    netlist_input_file << "module " << module_name << endl;

    Netlist netlist;
    
    map<string, int> array_pins;
    map<string, int>::iterator it;
    //This runtime is terrible Big O, however it only runs slow for cpu32. Would absolutely redesign this eloquently if deadlines weren't approaching
    for(size_t i=0; i<wire_list.size(); ++i){
        int wire_width = wire_list[i].width;
        string name = wire_list[i].name;
        array_pins.insert(pair<string, int>(name, wire_width));
        for(int j=0; j<wire_width; j++){
            //search for wire in component list
            stringstream ss;
            ss << j;
            Net net;
            string array_name;
            if(wire_width == 1){
                array_name = wire_list[i].name;
            }else{
                array_name = wire_list[i].name +"["+ ss.str()+ "]";
            }
            net.name = array_name;
            for(size_t k=0; k < component_list.size();++k){
                for(size_t l=0; l < component_list[k].pins.size();++l){
                    if(!name.compare(component_list[k].pins[l].name)){
                        if(component_list[k].pins[l].bit2 !=-1 && component_list[k].pins[l].bit1 != -1){
                            //check if array num is in number range
                            if(j <= component_list[k].pins[l].bit1 && j >= component_list[k].pins[l].bit2){
                                NetPin net_pin2;
                                net_pin2.name = component_list[k].name;
                                net_pin2.pos = (int) l;
                                net.net_pins.push_back(net_pin2);
                                continue;
                            }
                            
                        }
                        if(component_list[k].pins[l].bit1 == -1){
                            NetPin net_pin;
                            net_pin.name = component_list[k].name;
                            net_pin.pos = (int) l;
                            net.net_pins.push_back(net_pin);
                        }else{
                            if(component_list[k].pins[l].bit1 == j){
                                NetPin net_pin2;
                                net_pin2.name = component_list[k].name;
                                net_pin2.pos = (int) l;
                                net.net_pins.push_back(net_pin2);
                            }
                        }
                    }
                }
            }
            net.num_of_pins = (int) net.net_pins.size();
            netlist.nets.push_back(net);
        }

    }

    simulate_output(component_list,array_pins, filename);
    return 0;
}
