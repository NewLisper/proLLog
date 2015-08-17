typedef enum {STR,REF,FUN,LIS,CON} Tag;
typedef enum {PUT_STR,PUT_VIA_REG,SET_VAR,SET_VAL,
              SET_REG,GET_STR,GET_VIA_REG,UNY_VAR,UNY_VAL,
              UNY_REG,PUT_VAR,PUT_VAL,GET_VAR,GET_VAL,
              PUT_CONST,GET_CONST,SET_CONST,UNY_CONST,
              PUT_LIST,GET_LIST,
              CALL,PROCEED,ALLOC,DEALLOC,
              TRY,RETRY,TRUST,FIND_ANSWER,CUT,FAIL,END} OP;

typedef struct{
    Tag tag;
    union{
        int address;
        struct{
            char* cname;
            int address;
        }constant; //different from wam book ,record heap address for get_addr
        struct{
            char* name;
            int arity;
        }functor;
    };
}Cell;

typedef struct{
    OP op;
    union{
        int addr;
        int num;
        int s;
        struct{
            int addr;
            int arg_num;
        }label;
        struct{
            int s;
            int a;
        }two_args;
        struct{
            char* name;
            int a;
        }const_args;
        struct{
            char* name;
            int arity;
            int a;
        }three_args;
    };
}Instruction;

int load(Instruction* codes,const char* fname);
