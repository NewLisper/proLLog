/************************************************************************************************************
CODE_FORMAT:
OP(ENCODE IN INT)
(FUNCTOR_NAME  FUNCTOR_ARG_NUM)(OPTIONAL)
(STACK_VARIBLE_INDEX  ARG_REGISTER_INDEX)(OPTIONAL)

 A_INDEX : register index
 S_INDEX : stack variable index
 
 PUT_STR NAME NUM A_INDEX
 PUT_VIA_REG A_INDEX A_INDEX
 SET_VAR S_INDEX
 SET_VAL S_INDEX
 SET_REG A_INDEX
 GET_STR NAME NUM A_INDEX
 GET_VIA_REG A_INDEX A_INDEX
 UNY_VAR S_INDEX
 UNY_VAL S_INDEX
 UNY_REG A_INDEX
 PUT_VAR S_INDEX  A_INDEX
 PUT_VAL S_INDEX  A_INDEX
 GET_VAR S_INDEX  A_INDEX
 GET_VAL S_INDEX  A_INDEX
 PUT_CONST NAME A_INDEX
 GET_CONST NAME A_INDEX
 SET_CONST NAME
 UNY_CONST NAME
 PUT_LIST A_INDEX
 GET_LIST A_INDEX
 CALL ADDRESS NUM
 PROCEED
 ALLOC NUM
 DEALLOC
 TRY ADDRESS
 RETRY ADDRESS
 TRUST
 FIND_ANSWER
 CUT
 END
************************************************************************************************************/
#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void eat_space(FILE *fp)
{
    char c;
    while ((c = getc(fp)) == ' ' || c == '\n');
    ungetc(c, fp);
}

int readNum(FILE *fp)
{
    int res = 0;
    char c;
    while ((c = getc(fp)) != ' ' && c != '\n' && c != EOF) {
        res = res*10 + c - '0';
    }
    ungetc(c, fp);
    return res;
}

char* readString(FILE *fp)
{
    int i = 0;
    char* res = malloc(sizeof(char)*15);
    char c;
    while ((c = getc(fp)) != ' ' && c != '\n' && c != EOF) {
        res[i++] = c;
    }
    if (i > 14){
        printf("string too long. Max length is %d\n",15);
        exit(-1);
    }
    res[i] = '\0';
    ungetc(c, fp);
    return res;
}

OP readOp(FILE *fp)
{
    char* opstr = readString(fp);
    // c doesn't support string in switch,so...
    if (strcmp(opstr,"put_struct") == 0) {
        return PUT_STR;
    } else if (strcmp(opstr,"put_via_reg") == 0){
        return PUT_VIA_REG;
    } else if (strcmp(opstr,"get_struct") == 0){
        return GET_STR;
    } else if (strcmp(opstr,"get_via_reg") == 0){
        return GET_VIA_REG;
    } else if (strcmp(opstr,"set_variable") == 0){
        return SET_VAR;
    } else if (strcmp(opstr,"set_value") == 0){
        return SET_VAL;
    } else if (strcmp(opstr,"set_reg") == 0){
        return SET_REG;
    } else if (strcmp(opstr,"unify_variable") == 0){
        return UNY_VAR;
    } else if (strcmp(opstr,"unify_value") == 0){
        return UNY_VAL;
    } else if (strcmp(opstr,"unify_reg") == 0){
        return UNY_REG;
    } else if (strcmp(opstr,"put_variable") == 0){
        return PUT_VAR;
    } else if (strcmp(opstr,"put_value") == 0){
        return PUT_VAL;
    } else if (strcmp(opstr,"get_variable") == 0){
        return GET_VAR;
    } else if (strcmp(opstr,"get_value") == 0){
        return GET_VAL;
    } else if (strcmp(opstr,"put_const") == 0){
        return PUT_CONST;
    } else if (strcmp(opstr,"get_const") == 0){
        return GET_CONST;
    } else if (strcmp(opstr,"set_const") == 0){
        return SET_CONST;
    } else if (strcmp(opstr,"unify_const") == 0){
        return UNY_CONST;
    } else if (strcmp(opstr,"put_list") == 0){
        return PUT_LIST;
    } else if (strcmp(opstr,"get_list") == 0){
        return GET_LIST;
    } else if (strcmp(opstr,"call") == 0){
        return CALL;
    } else if (strcmp(opstr,"proceed") == 0){
        return PROCEED;
    } else if (strcmp(opstr,"dealloc") == 0){
        return DEALLOC;
    } else if (strcmp(opstr,"alloc") == 0){
        return ALLOC;
    } else if (strcmp(opstr,"try_me_else") == 0){
        return TRY;
    } else if (strcmp(opstr,"retry_me_else") == 0){
        return RETRY;
    } else if (strcmp(opstr,"trust_me") == 0){
        return TRUST;
    } else if (strcmp(opstr,"find_answer") == 0){
        return FIND_ANSWER;
    } else if (strcmp(opstr,"cut") == 0){
        return CUT;
    } else if (strcmp(opstr,"fail") == 0){
        return FAIL;
    } else {
        printf("invalid op code");
        exit(1);
    }
}


//return the entry
int load(Instruction* codes,const char* fname)
{
    int i = 0;//code line
    int op;
    char c;
    FILE *fp;
    Instruction ins;
    if((fp = fopen(fname,"r")) == NULL)
    {
        printf("code file open error");
        exit(1);
    }
    while ((c = getc(fp)) != EOF) {
        ungetc(c,fp);
        eat_space(fp);
        // load OP
        op = readOp(fp);
        ins.op = op;
        eat_space(fp);
        switch (op) {
            case PUT_STR:
            case GET_STR:
                ins.three_args.name = readString(fp);
                eat_space(fp);
                ins.three_args.arity = readNum(fp);
                eat_space(fp);
                ins.three_args.a = readNum(fp);
                break;
            case SET_VAR:
            case SET_VAL:
            case SET_REG:
            case UNY_VAR:
            case UNY_VAL:
            case UNY_REG:
            case PUT_LIST:
            case GET_LIST:
                ins.s = readNum(fp);
                break;
            case PUT_VAR:
            case PUT_VAL:
            case PUT_VIA_REG:
            case GET_VAR:
            case GET_VAL:
            case GET_VIA_REG:
                ins.two_args.s = readNum(fp);
                eat_space(fp);
                ins.two_args.a = readNum(fp);
                break;
            case PUT_CONST:
            case GET_CONST:
                ins.const_args.name = readString(fp);
                eat_space(fp);
                ins.const_args.a = readNum(fp);
                break;
            case SET_CONST:
            case UNY_CONST:
                ins.const_args.name = readString(fp);
                ins.const_args.a = 0;
                break;
            case CALL:
                ins.label.addr = readNum(fp);
                eat_space(fp);
                ins.label.arg_num = readNum(fp);
                break;
            case PROCEED:
            case DEALLOC:
            case TRUST:
            case FIND_ANSWER:
            case CUT:
            case FAIL:
                break;
            case ALLOC:
                ins.num = readNum(fp);
                break;
            case TRY:
            case RETRY:
                ins.addr = readNum(fp);
                break;
            default:
                printf("error");
                exit(-1);
                break;
        }
        codes[i++] = ins;
    }
    ins.op = END;
    codes[i++] = ins;
    return 0;
}
