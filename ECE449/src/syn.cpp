#include <iostream>
#include <fstream>
#include <string>
#include <cctype>
#include <vector>
#include <sstream>
#include <map>
#include <utility>
#include "net.h"

using namespace std;
int syntactic_analysis(vector<Token> &token_list, string filename){
    string output_file_name = filename+".syntax";
    ofstream output_file(output_file_name.c_str());
    vector<Wire> wire_list; //used to store wires in order
    vector<Component> component_list; //used to store components in order
    int current_wire_width = 1; //default value
    string module_name="";
    for(size_t i=0; i<token_list.size(); ++i){
        if(token_list[i].type == NAME){
            if(!token_list[i].value.compare("module")){
                ++i;
                module_name = token_list[i].value;
                continue;
            }
            if(!token_list[i].value.compare("wire")){
                ++i;
                if(token_list[i].type == NAME){ //not a bus
                    while(1){
                        current_wire_width = 1;
                        Wire wire_add(token_list[i].value, current_wire_width);
                        wire_list.push_back(wire_add); // add wire
                        ++i;
                        if(token_list[i].type == SINGLE){
                            if(!token_list[i].value.compare(";")){
                                break; //wires are done being declared
                            }else{ //must be a ','
                                ++i;
                            }

                        }
                        
                    }
                }else {// get bus info
                    //first extract wire width, then see if more wires exist
                    ++i;
                    current_wire_width = token_list[i].number+1;
                    i+=4;
                    // skip to the name of the wires
                    while(1){
                        Wire wire_add(token_list[i].value, current_wire_width);
                        wire_list.push_back(wire_add); // add new wire to list
                        ++i;
                        if(token_list[i].type == SINGLE){
                            if(!token_list[i].value.compare(";")){
                                break;
                            }else{
                                ++i;
                            }

                        }
                    }


                }

            } else if(token_list[i].value.compare("endmodule")){
                string component_name = token_list[i].value; //save name for struct
                ++i;
                if(token_list[i].type == NAME){
                    component_name += " " + token_list[i].value;
                    ++i;
                }
                ++i;
                vector<Pin> pin_vector;
                while(1){ //loop to extract pins
                    if(token_list[i].type == NAME){
                        string pin_name = token_list[i].value;
                        int bit1 = -1;
                        int bit2 = -1;
                        ++i;
                        if(!token_list[i].value.compare("[")){ //must extract number
                            ++i;
                            bit1 = token_list[i].number;
                            i+=2;
                            if(token_list[i].type == NUMBER ){
                                bit2 = token_list[i].number;
                                i+=2;
                            }
                        }
                        if(!token_list[i].value.compare(",")){
                            Pin add_pin(pin_name, bit1, bit2);
                            pin_vector.push_back(add_pin);
                            ++i;
                            continue; //get next pin
                        }
                        if(!token_list[i].value.compare(")")){
                            Pin add_pin(pin_name, bit1, bit2);
                            pin_vector.push_back(add_pin);
                            break; //end of pins
                        }
                        
                        
                    }
    
                }
                Component add_component(component_name, pin_vector);
                ++i;
                component_list.push_back(add_component);                

            }



             
        }
    }
    netlist_creation(component_list, wire_list, filename, module_name);
    
    return 0;
}
