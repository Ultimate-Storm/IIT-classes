#include <fstream>
#include <iostream>
#include <vector>
#include "lex.h"

using namespace std;

typedef struct Wire{

    string name;
    int width;
    
    Wire(string n, int w):
        name(n),
        width(w){}
};


typedef struct Pin{

    string name;
    int bit1;
    int bit2;

    Pin(string n, int b1, int b2):
        name(n), 
        bit1(b1),
        bit2(b2){}
};

typedef struct Component{
  
    string name;
    vector<Pin> pins;

    Component(string n, vector<Pin> p):
        name(n),
        pins(p){}
};


int syntactic_analysis(std::vector<Token> &token_list, string filename);
