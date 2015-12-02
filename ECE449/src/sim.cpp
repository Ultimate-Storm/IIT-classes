#include "sim.h"
#include <map>
#include <vector>
#include <iterator>
using namespace std;
int simulate_output(vector<Component> &component_list, map<string, int> &array_pins, string filename){
    
    ofstream outfile;
    map<string, vector<int> > pin_lookup;    
    vector<Component> dffs;
    //initialize values and put all pins in hash table
    //also create file outputs
    for(size_t i=0; i < component_list.size(); ++i){
        if(!component_list[i].name.compare("evl_dff"))
            dffs.push_back(component_list[i]);

        for(size_t j=0; j< component_list[i].pins.size(); ++j){
            if(pin_lookup.find(component_list[i].pins[j].name) == pin_lookup.end())
                pin_lookup.insert(pair<string, vector<int> > (component_list[i].pins[j].name, vector<int>(array_pins.at(component_list[i].pins[j].name))));
            
        }

    }
    
    cout << "Simulation begin!" << endl;
    string str = "evl_output";
    size_t found;
    for(int i=0; i<1000; ++i){
        for(size_t j=0; j< component_list.size(); ++j){
            //not using switch because string
            int result = 0;
            int dff_count=0;
            if(!component_list[j].name.compare("evl_clock"))
                continue;

            if(!component_list[j].name.compare("evl_one")){
                for(size_t k=0; k< component_list[j].pins.size(); ++k){
                    if(component_list[j].pins[k].bit1!= -1){
                        pin_lookup[component_list[j].pins[k].name][component_list[j].pins[k].bit1] = 1;
                    }else
                        for(int l=0; l < array_pins.at(component_list[j].pins[k].name); ++l)
                            pin_lookup[component_list[j].pins[k].name][l] = 1;
               }
            continue;
        }
            if(!component_list[j].name.compare("evl_zero")){
                for(size_t k=0; k< component_list[j].pins.size(); ++k){
                    if(component_list[j].pins[k].bit1!= -1){
                        pin_lookup[component_list[j].pins[k].name][component_list[j].pins[k].bit1] = 0;
                    }else
                        for(int l=0; l < array_pins.at(component_list[j].pins[k].name); ++l)
                            pin_lookup[component_list[j].pins[k].name][l] = 0;

                }
                continue;
        }

            if(!component_list[j].name.compare("evl_dff"))
                continue;
            

            if(!component_list[j].name.compare("and")){
                for(size_t k=1; k< component_list[j].pins.size(); ++k){
                    if(component_list[j].pins[k].bit1!= -1){
                        if(pin_lookup.at(component_list[j].pins[k].name)[component_list[j].pins[k].bit1] == 0)
                        pin_lookup[component_list[j].pins[0].name][0] = 0;
                    }else{
                        if(pin_lookup.at(component_list[j].pins[k].name)[k] == 0)
                        pin_lookup[component_list[j].pins[0].name][0] = 0;
    
                    }
                }
                continue;
            }

            if(!component_list[j].name.compare("or")){
                for(size_t k=1; k< component_list[j].pins.size(); ++k){
                    if(component_list[j].pins[k].bit1!= -1){

                        if(pin_lookup.at(component_list[j].pins[k].name)[component_list[j].pins[k].bit1] == 1)
                        pin_lookup[component_list[j].pins[0].name][0] = 1;
                    }else{
                        if(pin_lookup.at(component_list[j].pins[k].name)[k] == 0)
                        pin_lookup[component_list[j].pins[0].name][0] = 0;
    
                    }
                            
                }
                continue;
            }

            if(!component_list[j].name.compare("xor")){
                    int test = 0;
                for(size_t k=1; k< component_list[j].pins.size(); ++k){
                    if(component_list[j].pins[k].bit1!= -1){
                        if(pin_lookup.at(component_list[j].pins[k].name)[component_list[j].pins[k].bit1] == 1)
                            ++test;
                    }else
                        if(pin_lookup.at(component_list[j].pins[k].name)[k] == 1)
                            ++test;

                   
                }
                if(test % 2 == 0){
                    result = 0;
                }else{
                    result = 1;
                }
                        pin_lookup[component_list[j].pins[0].name][0] = result;
                continue;
            }

            if(!component_list[j].name.compare("not")){
                if(pin_lookup.at(component_list[j].pins[1].name)[0] == 0){
                    result = 1;
                }else result = 0;
                        pin_lookup[component_list[j].pins[0].name][0] = result;
                continue;
            }
                

            if(!component_list[j].name.compare("buf")){
                if(pin_lookup.at(component_list[j].pins[1].name)[0] == 0){
                    result = 0;
                }else result = 1;
                        pin_lookup[component_list[j].pins[0].name][0] = result;
                continue;
            }

            found = component_list[j].name.find(str); 
            if(found !=std::string::npos){
                if(i == 0){
                    //start of file
                    outfile.open(string(filename+"."+component_list[j].name.substr(11,component_list[j].name.size())+".evl_output").c_str(), ios_base::app);
                    outfile << component_list[j].pins.size() << endl;
                    for(size_t l =0; l < component_list[j].pins.size(); ++l){
                        if(component_list[j].pins[l].bit1 != -1)
                         outfile << std::dec << 1 << endl;
                        else

                        outfile << std::dec <<array_pins.at(component_list[j].pins[l].name) << endl;
                    }
                    outfile.close();
                    

                }
                //write results
                outfile.open(string(filename+"."+component_list[j].name.substr(11,component_list[j].name.size())+".evl_output").c_str(), ios_base::app);
                for(size_t k=0; k< component_list[j].pins.size(); ++k){
                    int hexvalue = 0;
                    if(component_list[j].pins[k].bit1 == -1){    
                    for(size_t l=((pin_lookup.at(component_list[j].pins[k].name)).size()); l > 0; --l){
                        hexvalue <<= 1;
                        hexvalue += (pin_lookup.at(component_list[j].pins[k].name))[l-1];
                    }
                    outfile << std::hex << hexvalue << " ";
                    }
                    else outfile << pin_lookup.at(component_list[j].pins[k].name)[component_list[j].pins[k].bit1] << " ";
                }

                outfile << endl;
                outfile.close();
            }
                //update d flip flops
                for(size_t k=0; k < dffs.size(); ++k){
                if(dffs[k].pins[0].bit1 !=-1 && dffs[k].pins[1].bit1 !=-1)
                        pin_lookup[dffs[k].pins[0].name][dffs[k].pins[0].bit1] = pin_lookup.at(dffs[k].pins[1].name)[dffs[k].pins[1].bit1];

                else if(dffs[k].pins[0].bit1 !=-1 )
                        pin_lookup[dffs[k].pins[0].name][dffs[k].pins[0].bit1] = pin_lookup.at(dffs[k].pins[1].name)[0];
                    else if(dffs[k].pins[1].bit1 != -1)
                        pin_lookup[dffs[k].pins[0].name][0] = pin_lookup.at(dffs[k].pins[1].name)[dffs[k].pins[1].bit1];

                else
                        pin_lookup[dffs[k].pins[0].name][0] = pin_lookup.at(dffs[k].pins[1].name)[0];


                }
            }

        }
        
    
    
    return 0;
}
