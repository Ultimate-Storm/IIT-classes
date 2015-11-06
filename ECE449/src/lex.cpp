#include <iostream>
#include <fstream>
#include <string>
#include<vector>
#include <cctype>
#include "net.h"

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cerr << "You should provide a file name." << std::endl;
        return -1;
    }

    std::ifstream input_file(argv[1]);
    if (!input_file)
    {
        std::cerr << "I can't read " << argv[1] << "." << std::endl;
        return -1;
    }

    std::string output_file_name = std::string(argv[1])+".tokens";
    std::ofstream output_file(output_file_name.c_str());
    if (!output_file)
    {
        std::cerr << "I can't write " << argv[1] << ".tokens ." << std::endl;
        return -1;
    }

    std::string line;
    for (int line_no = 1; std::getline(input_file, line); ++line_no)
    {
        for (size_t i = 0; i < line.size();)
        {
            //Numbers
            if(isdigit(line[i])){
                output_file << "NUMBER " << line[i];
                ++i;
                while(isdigit(line[i])){
                    output_file << line[i];
                    ++i;
                }
                output_file << std::endl;       
                continue;
            }
            // comments
            if (line[i] == '/')
            {
                ++i;
                if ((i == line.size()) || (line[i] != '/'))
                {
                    std::cerr << "LINE " << line_no
                        << ": a single / is not allowed" << std::endl;
                    return -1;
                }
                break; // skip the rest of the line by exiting the loop
            }

            // spaces
            if ((line[i] == ' ') || (line[i] == '\t')
                || (line[i] == '\r') || (line[i] == '\n'))
            {
                ++i; // skip this space character
                continue; // skip the rest of the iteration
            }

            // SINGLE
            if ((line[i] == '(') || (line[i] == ')')
                || (line[i] == '[') || (line[i] == ']')
                || (line[i] == ':') || (line[i] == ';')
                || (line[i] == ','))
            {
                output_file << "SINGLE " << line[i] << std::endl;
                ++i; // we consumed this character
                continue; // skip the rest of the iteration
            }

            // NAME
            if (((line[i] >= 'a') && (line[i] <= 'z'))       // a to z
                || ((line[i] >= 'A') && (line[i] <= 'Z'))    // A to Z
                || (line[i] == '_'))
            {
                size_t name_begin = i;
                for (++i; i < line.size(); ++i)
                {
                    if (!(((line[i] >= 'a') && (line[i] <= 'z'))
                        || ((line[i] >= 'A') && (line[i] <= 'Z'))
                        || ((line[i] >= '0') && (line[i] <= '9'))
                        || (line[i] == '_') || (line[i] == '$')))
                    {
                        break; // [name_begin, i) is the range for the token
                    }
                }
                output_file << "NAME "
                    << line.substr(name_begin, i-name_begin) << std::endl;
            }
            else
            {
                std::cerr << "LINE " << line_no
                    << ": invalid character" << std::endl;
                return -1;
            }
        }
    }

    std::ifstream syntactic_input_file(output_file_name.c_str());
    //output file from lex.cpp is input to syn.cpp
   /* if(syntactic_analysis(syntactic_input_file, argv[1])){
        return -1; 
    }*/
    syntactic_analysis(syntactic_input_file, argv[1]);
    //std::ifstream netlist_input_file(output_file_name.c_str());
    //netlist_input_file.clear();
    //netlist_input_file.seekg(0,netlist_input_file.beg);
   // netlist_creation(component_list, argv[1], netlist_input_file);
  /*  std::ofstream netlist_input_file((std::string(argv[1])+".netlist").c_str()); 
    netlist_input_file << "module top" << std::endl;
    netlist_input_file << "endmodule";*/
    return 0;
}
