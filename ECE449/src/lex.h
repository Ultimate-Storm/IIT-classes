enum Type { NAME, SINGLE, NUMBER};


typedef struct Token{
    Type type;
    std::string value;
    int number;

};
