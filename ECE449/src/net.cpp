#include <iostream>
#include <vector>
#include <map>
#include <fstream>
#include "net.h"
#include <tr1/unordered_set>
#include <string>
#include <sstream>
#include <cmath>


using namespace std;
using namespace tr1;

int netlist_creation(vector<Component> &component_list, vector<Wire> &wire_list, string filename, ifstream& input_file){
    //REALLY NEED TO FIX THIS THIS IS A GARBAGE WAY OF GETTING THE MODULE TOKEN
    //REFACTORING IS A MUST!!!!!!!

    //First create File
    ofstream netlist_input_file(string(filename+".netlist").c_str());
    
    stringstream get_module;
    string token;
    string line;
    getline(input_file, line);
    getline(input_file,line);
    get_module.str(line);
    get_module >> token;
    get_module >> token;
    netlist_input_file << "module " << token << endl;

    Netlist netlist;
    
    map<string, int> array_pins;
    map<string, int>::iterator it;
    //This runtime is terrible Big O but for the format in the file, it's necessary :(
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
    //Put Netlist into file
    netlist_input_file << "nets " << (int) netlist.nets.size() << endl;
    for(size_t i=0; i < netlist.nets.size(); ++i){
        netlist_input_file << "  net " << netlist.nets[i].name << " " << netlist.nets[i].num_of_pins << endl;  
        for(size_t j=0; j < netlist.nets[i].net_pins.size(); ++j){
            netlist_input_file << "    " << netlist.nets[i].net_pins[j].name << " " << netlist.nets[i].net_pins[j].pos << endl;
        }
    }
    //We already have components basically, just need to add them to netlist data structure
    netlist_input_file << "components " << (int) component_list.size() << endl; 
    for(size_t i=0; i < component_list.size(); ++i){
        netlist_input_file << "  component " << component_list[i].name << " " << component_list[i].pins.size() << endl;
        for(size_t j=0; j < component_list[i].pins.size(); ++j){
            int width;
            if(component_list[i].pins[j].bit1 != -1 && component_list[i].pins[j].bit2 !=-1){
                //handle this shit
                width = abs(component_list[i].pins[j].bit1 - component_list[i].pins[j].bit2)+1;
                netlist_input_file << "    pin " << width << " ";
                for(int k=min(component_list[i].pins[j].bit1, component_list[i].pins[j].bit2); k <max(component_list[i].pins[j].bit1, component_list[i].pins[j].bit2)+1; k++){
                    
                     stringstream ss;
                     ss << k;
                     netlist_input_file << component_list[i].pins[j].name +"["+ ss.str()+ "] ";
                    
                
                }
                netlist_input_file << endl;
                continue;
            }
            if(component_list[i].pins[j].bit1 == -1){
                width = array_pins.at(component_list[i].pins[j].name);
                netlist_input_file << "    pin " << width << " ";
                for(int k=0; k < width; k++){
                if(width == 1){
                    netlist_input_file << component_list[i].pins[j].name;
                    break;
                }
                    
                     stringstream ss;
                     ss << k;
                     netlist_input_file << component_list[i].pins[j].name +"["+ ss.str()+ "] ";
                }
                netlist_input_file << endl;
                continue;
            }else{
                width=1;
            }
                     stringstream ss;
                     ss << component_list[i].pins[j].bit1;
                     string name = component_list[i].pins[j].name +"["+ ss.str()+ "]";
            netlist_input_file << "    pin " << width << " " << name << endl;
        }
    }


//    Netlist netlist; //create netlist structure

    //create hash set of visited pins
    /*map<string,map<string,Net> > created_nets;
    map<string,map<string, Net> >::iterator found;

    map<string, Connection>::iterator got;

    map<string, int> indexes_of_top_level_names;
    //parse components to create nets
    for(size_t i=0; i< component_list.size(); ++i){
        for(size_t j=0; j< component_list[i].pins.size();++j){
            string top_level_pin_name = component_list[i].pins[j].name;
            //search netlist for net of top level name
            bool contains_top_level_pin = false;
            int index_of_top_level_pin;
            for(size_t k=0; k< netlist.nets.size(); ++k){
                if(!top_level_pin_name.compare(netlist.nets[k].name)){
                    contains_top_level_pin = true;
                    index_of_top_level_pin = k;
                    indexes_of_top_level_names.insert(pair<string, int>(top_level_pin_name, k));
                }

            }
            if(!contains_top_level_pin){
                Net top_level_net;
                top_level_net.name = top_level_pin_name;
                //extract connection specific name
                if(component_list[i].pins[j].bit1 == -1){
                    //not an array
                    Connection connection(top_level_pin_name);
                    Component_Position cp(component_list[i].name, (int) j);
                    connection.component_position.push_back(cp);
                    top_level_net.list_of_pin_connections.insert(pair<string, Connection>(top_level_pin_name, connection));
                }else{
                    //its an array extract the specific name
                    stringstream ss;
                    ss << component_list[i].pins[j].bit1;
                    string specific_name = top_level_pin_name + "[" + ss.str()+"]";
                    Connection connection(specific_name);
                    Component_Position cp(component_list[i].name, (int) j);
                    connection.component_position.push_back(cp);
                    top_level_net.list_of_pin_connections.insert(pair<string, Connection>(specific_name, connection));
                }
                
                netlist.nets.push_back(top_level_net);
                
            }else{
            //handle the case when top level name is already in the system
                if(component_list[i].pins[j].bit1== -1){
                    Component_Position cp(component_list[i].name, (int) j);
                    //iterate through the maps of top level name
                    for(map<string, Connection>::iterator it = netlist.nets[index_of_top_level_pin].list_of_pin_connections.begin(); it !=  netlist.nets[index_of_top_level_pin].list_of_pin_connections.end();++it ){
                    it->second.component_position.push_back(cp);
                    }



                }else{
                    stringstream ss;
                    ss << component_list[i].pins[j].bit1;
                    string specific_name = top_level_pin_name + "[" + ss.str()+"]";
                    got = netlist.nets[index_of_top_level_pin].list_of_pin_connections.find(specific_name);
                
                    if(got != netlist.nets[index_of_top_level_pin].list_of_pin_connections.end()){
                        Component_Position cp(component_list[i].name, (int) j);
                        netlist.nets[index_of_top_level_pin].list_of_pin_connections.at(specific_name).component_position.push_back(cp);
                    }else{
                    //add specfic pin to vector
                        Connection connection(specific_name);
                        Component_Position cp(component_list[i].name, (int) j);
                        connection.component_position.push_back(cp);
                        netlist.nets[index_of_top_level_pin].list_of_pin_connections.insert(pair<string, Connection>(specific_name, connection));
                    }
                }



            }
        }
    }
    //file output
    int num_of_nets=0;
    for(size_t i=0; i<netlist.nets.size();++i){
        num_of_nets += (int) netlist.nets[i].list_of_pin_connections.size();
    }
    netlist_input_file << "nets " << num_of_nets << endl;
    for(size_t i=0; i<netlist.nets.size();++i){
        for(map<string, Connection>::iterator it = netlist.nets[i].list_of_pin_connections.begin(); it != netlist.nets[i].list_of_pin_connections.end(); it++){
            netlist_input_file << "  net " << it->second.name << " " << it->second.component_position.size() << endl;
            for(size_t j=0; j< it->second.component_position.size(); ++j){
                netlist_input_file << "    " << it->second.component_position[j].name << " " << it->second.component_position[j].position << endl;
            }
        }
    }
    netlist_input_file << "  components " << component_list.size() << endl;
    for(size_t i=0; i< component_list.size(); ++i){
    netlist_input_file << "    component " << component_list[i].name << " " << component_list[i].pins.size() <<endl;
        for(size_t j=0; j< component_list[i].pins.size(); ++j){
            if(component_list[i].pins[j].bit1== -1){
            //iterate through the maps of top level name
                int num_of_pins = 0;
                vector<string> pin_names;
                for(map<string, Connection>::iterator it = netlist.nets[indexes_of_top_level_names.at(component_list[i].pins[j].name)].list_of_pin_connections.begin(); it !=  netlist.nets[indexes_of_top_level_names.at(component_list[i].pins[j].name)].list_of_pin_connections.end();++it ){
                    pin_names.push_back(it->second.name);
                    num_of_pins++;
                }
                netlist_input_file << "      pin " << num_of_pins << " ";
                for(size_t k=0;k < pin_names.size();++k){
                    netlist_input_file << pin_names[k] << " ";
                }
                netlist_input_file << endl;


          }else{
                stringstream ss;
                ss << component_list[i].pins[j].bit1;
                string specific_name = component_list[i].pins[j].name + "[" + ss.str()+"]";
                netlist_input_file << "      pin 1 " << specific_name << endl;
          }
        }
    }*/
    return 0;
}
