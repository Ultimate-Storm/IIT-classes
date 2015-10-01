#include <iostream>
#include <fstream>
#include <string>
#include <cctype>
#include <vector>
#include <sstream>
#include <map>
#include <utility>
# include "syn.h"

using namespace std;
int syntactic_analysis(ifstream& input_file, string filename){
    if(!input_file){
        cerr <<"I can't read the .tokens file" << endl;
        return -1;
    }
    cout << "Reading file for syntactic analysis!" << endl;
    //Now we parse the *.tokens file
    string line;
    vector<string> line_tokens;
    string output_file_name = filename+".syntax";
    ofstream output_file(output_file_name.c_str());
    stringstream ss;
    string token;
    vector<Wire> wire_list; //used to store wires in order
    vector<Component> component_list; //used to store components in order
    int current_wire_width = 1; //default value

    while(getline(input_file, line)){
        ss.str(line);
        ss >> token;
        if(!token.compare("NAME")){
            ss >> token;
            if(!token.compare("module")){
                getline(input_file, line);
                ss.clear();
                ss.str(line);
                ss >> token;
                ss >> token; //extract module name
                output_file << "module " << token << endl;
                ss.clear();
                continue;
            }
            if(!token.compare("wire")){
                getline(input_file, line);
                ss.clear();
                ss.str(line);
                ss >> token;
                if(!token.compare("NAME")){ //not a bus
                    while(1){ 
                        ss >> token;
                        current_wire_width = 1;
                        Wire wire_add(token, current_wire_width);
                        wire_list.push_back(wire_add); //add wire
                        getline(input_file, line);
                        ss.clear();
                        ss.str(line);
                        ss >> token;
                        if(!token.compare("SINGLE")){
                            ss >> token;
                            if(!token.compare(";")){
                                break; //wires are done being declared
                            }else{ //must be a ','
                                getline(input_file, line);
                                ss.clear();
                                ss.str(line);
                                ss >> token; //skip the "NAME" token
                            }

                        }
                    }
                }else { //must get bus info
                    //first extract wire width, then see if more wires exist
                    getline(input_file, line); //get line containing NUMBER
                    ss.clear();
                    ss.str(line);
                    ss >> token;
                    ss >> token;
                    current_wire_width = atoi(token.c_str())+1;
                    for(int i=0; i < 4; ++i){
                        getline(input_file, line);
                    } // skip to the name of the wires
                    ss.clear();
                    ss.str(line);
                    ss >> token; // skip "NAME" token
                    while(1){
                        ss >> token;
                        Wire wire_add(token, current_wire_width);
                        wire_list.push_back(wire_add); // add new wire to list
                        getline(input_file, line);
                        ss.clear();
                        ss.str(line);
                        ss >> token;
                        if(!token.compare("SINGLE")){
                            ss >> token;
                            if(!token.compare(";")){
                                break;
                            }else{
                                getline(input_file, line);
                                ss.clear();
                                ss.str(line);
                                ss >> token; //skip "NAME" token
                            }

                        }
                    }
                }

            }else if(token.compare("endmodule")){ //it's a component!
                string component_name = token; //save name for struct
                getline(input_file, line);
                ss.clear();
                ss.str(line);
                ss >> token;
                if(!token.compare("NAME")){
                    ss >> token;
                    component_name += " " + token;
                    getline(input_file, line);
                }
                getline(input_file, line); //skip to first pin
                ss.clear();
                ss.str(line);
                ss >> token;
                vector<Pin> pin_vector;
                while(1){ //loop to extract pins
                    if(!token.compare("NAME")){
                        ss >> token;
                        string pin_name = token;
                        int bit1 = -1;
                        int bit2 = -1;
                        getline(input_file, line);
                        ss.clear();
                        ss.str(line);
                        ss >> token;
                        ss >> token;
                        if(!token.compare("[")){ //must extract number
                            getline(input_file, line);
                            ss.clear();
                            ss.str(line);
                            ss >> token;
                            ss >> token; //get number;
                            bit1 = atoi(token.c_str());
                            for(int i=0;i<2;++i){
                                getline(input_file, line);
                            }
                            ss.clear();
                            ss.str(line);
                            ss >> token;
                            if(!token.compare("NUMBER")){
                                ss >> token;
                                bit2 = atoi(token.c_str());
                                for(int i=0;i<2;++i){
                                    getline(input_file, line);
                                }  
                                ss.clear();
                                ss.str(line);
                                ss >> token;
                                ss >> token;
                            }else{
                                ss >> token; //skip the SINGLE and see if we're at  
                            }
                        }
                        if(!token.compare(",")){
                            Pin add_pin(pin_name, bit1, bit2);
                            pin_vector.push_back(add_pin);
                            getline(input_file, line);
                            ss.clear();
                            ss.str(line);
                            ss >> token;
                            continue; //get next pin
                        }
                        if(!token.compare(")")){
                            Pin add_pin(pin_name, bit1, bit2);
                            pin_vector.push_back(add_pin);
                            break; //end of pins
                        }
                        
                        
                    }
    
                }
                Component add_component(component_name, pin_vector);
                getline(input_file, line);
                component_list.push_back(add_component);                

            }
        }


        ss.clear();

    }
    //end of syntactic analysis

    output_file << "wires " << wire_list.size() << endl;
    for(size_t i=0; i<wire_list.size(); ++i){
        output_file << "\t wire " << wire_list[i].name << " " << wire_list[i].width << endl;
    }

    output_file << "components " << component_list.size() << endl;
    
    for(size_t i=0; i< component_list.size(); ++i){
       output_file << "\tcomponent " << component_list[i].name << " " << component_list[i].pins.size() <<  endl;
       
       for(size_t j=0; j<component_list[i].pins.size(); ++j ){
            output_file << "\t\t pin " << component_list[i].pins[j].name;
            
            if(component_list[i].pins[j].bit1 == -1){
                output_file << endl;
            }else{
                output_file << " " << component_list[i].pins[j].bit1;
                if(component_list[i].pins[j].bit2 == -1){
                    output_file << endl;
                }else{
                    output_file << " " << component_list[i].pins[j].bit2 << endl;
                }
            }
       }
    }


    
    return 0;
}
