#include "types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {AND_FRM,OR_FRM} Frm;
enum {READ,WRITE} mode;


typedef struct{
    Frm frm;
    union{
        struct{
            int e;
            int cp;
            int num;
            int b0;
            Cell* lvars;
        }and;
        struct{
            int num;
            Cell* args;
            int e;
            int cp;
            int b;
            int next;
            int tr;
            int hb;
            int b0;
        }or;
    };
}Frame;


#define MAX_HEAP_SIZE 10000
#define MAX_PDL_SIZE 1000
#define MAX_CODE_SIZE 1000
#define MAX_STACK_SIZE 1000
#define MAX_TRAIL_SIZE 1000
Cell heap[MAX_HEAP_SIZE];
int PDL[MAX_PDL_SIZE];
Instruction codes[MAX_CODE_SIZE];
Frame call_stack[MAX_STACK_SIZE];
int trail[MAX_TRAIL_SIZE];

int h; //heap register
int s; //subterm register
int p; // program counter
int cp;// continuation register
int e;//frame register;
int b;//choice point register;
int b0;//cut register
int tr;//trail register;
int hb;//heap when latest choice point was created
int pdls;//unify stack pointer

int fail;// unify result
int goal;
int arg_nums;
Cell A[50];//arg register

int solunums;

void push(int addr)
{
    PDL[pdls++] = addr;
}

int pop()
{
    return PDL[--pdls];
}

int empty()
{
    return pdls == 0;
}

void put_struct(char* name,int ari,Cell* X)
{
    Cell c1,c2;
    c1.tag = STR;
    c1.address = h+1;
    heap[h++] = c1;
    c2.tag = FUN;
    c2.functor.name = name;
    c2.functor.arity = ari;
    heap[h++] = c2;
    *X = c1;
}

void set_var(Cell* X)
{
    Cell c;
    c.tag = REF;
    c.address = h;
    heap[h++] = c;
    *X = c;
}

void set_val(Cell* X)
{
    heap[h++] = *X;
}

int derf(int addr)
{
    Cell c = heap[addr];
    if(c.tag == REF && c.address != addr)
        return derf(c.address);
    return addr;
}

void trace_trail(int addr)
{
    if (addr < hb) {
        trail[tr++] = addr;
    }
}

void unwind_trail(int start,int end)
{
    int i;
    for (i = start; i < end; i++) {
        Cell c;
        c.tag = REF;
        c.address = trail[i];
        heap[trail[i]] = c;
    }
}

void backtrack()
{
    if (b == -1) {
        printf("total: %d solutions\n",solunums);
        if(goal)
            printf("success\n");
        else
            printf("fail\n");
        exit(0);
    }else{
        p = call_stack[b].or.next;
        fail = 0;
    }
}

void wam_bind(int a1, int a2)
{
    if(heap[a1].tag == REF && heap[a1].address == a1)
    {
        heap[a1].address = a2;
        trace_trail(a1);
    }else{
        heap[a2].address = a1;
        trace_trail(a2);
    }
}

void wam_unify(int a1,int a2)
{
    push(a1);
    push(a2);
    fail = 0;
    while (!(empty()||fail)) {
        int d1 = derf(pop());
        int d2 = derf(pop());
        if (d1 != d2) {
            Cell c1 = heap[d1];
            Cell c2 = heap[d2];
            if (c1.tag == REF) {
                wam_bind(d1,d2);
            }else{
                if (c2.tag == REF) {
                    wam_bind(d1,d2);
                }else if (c2.tag == CON){
                    if (c1.tag != CON || strcmp(c1.constant.cname,c2.constant.cname) != 0)
                        fail = 1;
                }else if (c2.tag == LIS){
                    if (c1.tag != LIS) {
                        fail = 1;
                    } else {
                        push(c1.address);
                        push(c2.address);
                        push(c1.address+1);
                        push(c2.address+1);
                    }
                }else if (c2.tag == STR){
                    if (c1.tag != STR) {
                        fail = 1;
                    }else{
                        Cell c3 = heap[c1.address];
                        Cell c4 = heap[c2.address];
                        if (strcmp(c3.functor.name,c4.functor.name) == 0 && c3.functor.arity == c4.functor.arity) {
                            for (int i = 1; i <= c3.functor.arity; ++i) {
                                push(c1.address+i);
                                push(c2.address+i);
                            }
                        }else{
                            fail = 1;
                        }
                    }
                }
            }
        }
    }
}

int get_addr(Cell* X)
{
    if (X->tag == REF) {
        return X->address;
    } else if(X->tag == CON){
        return X->constant.address;
    } else {
        return X->address-1;
    }
}

void get_struct(char* name,int ari,Cell* X)
{
    int addr = derf(get_addr(X));
    Cell c = heap[addr];
    if (c.tag == REF) {
        Cell c1,c2;
        c1.tag = STR;
        c1.address = h+1;
        heap[h] = c1;
        c2.tag = FUN;
        c2.functor.name = name;
        c2.functor.arity = ari;
        heap[h+1] = c2;
        wam_bind(addr,h);
        h += 2;
        mode = WRITE;
    }else if(c.tag == STR){
        Cell c1 = heap[c.address];
        if (strcmp(c1.functor.name,name) == 0 && c1.functor.arity == ari) {
            s = c.address + 1;
            mode = READ;
        }else{
            fail = 1;
        }
    }else{
        fail = 1;
    }
    if(fail)
        backtrack();
}

void unify_var(Cell* X)
{
    if (mode == READ) {
        *X = heap[s];
    }else{
        Cell c;
        c.tag = REF;
        c.address = h;
        heap[h] = c;
        *X = c;
        h++;
    }
    s++;
}

void unify_val(Cell* X)
{
    if (mode == READ) {
        wam_unify(get_addr(X),s);
    }else{
        heap[h] = *X;
        h++;
    }
    s++;
    if(fail)
        backtrack();
}

void put_var(Cell* X,Cell* A)
{
    Cell c;
    c.tag = REF;
    c.address = h;
    *X = c;
    *A = c;
    heap[h++] = c;
}

void put_val(Cell* X,Cell* A)
{
    *A = *X;
}

void get_var(Cell* X,Cell* A)
{
    *X = *A;
}

void get_val(Cell* X,Cell* A)
{
    wam_unify(get_addr(X), get_addr(A));
    if(fail)
        backtrack();
}

void call(int addr, int num){
    arg_nums = num;
    cp = p;//p is already decreased
    b0 = b;
    p = addr;
}

void proceed()
{
    p = cp;
}

void allocate(int num)
{
    Frame f;
    f.frm = AND_FRM;
    f.and.e = e;
    f.and.cp = cp;
    f.and.num = num;
    f.and.b0 = b0;
    f.and.lvars = malloc(sizeof(Cell)*num);
    int newe;
    if (b > e)
        newe = b;
    else
        newe = e;
    call_stack[newe+1] = f;
    e = newe + 1;
}

void deallocate()
{
    Frame f = call_stack[e];
   // free(f.and.lvars); we can not free stack varibles during deallocation
   //                    but we can fix it when we are done
    cp = f.and.cp;
    e = f.and.e;
}


void try(int next)
{
    Frame f;
    f.frm = OR_FRM;
    f.or.num = arg_nums;
    f.or.args = malloc(sizeof(Cell)*arg_nums);
    int i;
    for (i = 0; i < arg_nums; i++)
        f.or.args[i] = A[i];
    f.or.e = e;
    f.or.cp = cp;
    f.or.b = b;
    f.or.next = next;
    f.or.tr = tr;
    f.or.hb = h;
    f.or.b0 = b0;
    int newe;
    if (b > e)
        newe = b;
    else
        newe = e;
    b = newe + 1;
    call_stack[b] = f;
    hb = h;
}

void retry(int next)
{
    Frame f = call_stack[b];
    int num = f.or.num;
    int i;
    for (i = 0; i < num; i++)
       A[i] = f.or.args[i];
    e = f.or.e;
    cp = f.or.cp;
    f.or.next = next;
    unwind_trail(f.or.tr,tr);
    tr = f.or.tr;
    h = f.or.hb;
    b0 = f.or.b0;
    call_stack[b] = f;
    hb = h;
}

void trust()
{
    Frame f = call_stack[b];
    int num = f.or.num;
    int i;
    for (i = 0; i < num; i++)
       A[i] = f.or.args[i];
    free(f.or.args);
    e = f.or.e;
    cp = f.or.cp;
    unwind_trail(f.or.tr,tr);
    tr = f.or.tr;
    h = f.or.hb;
    b0 = f.or.b0;
    b = f.or.b;
    hb = call_stack[b].or.hb;
}

// instructions added by me
void put_via_reg(Cell* A1,Cell* A2)
{
    *A2 = *A1;
}

void get_via_reg(Cell* A1,Cell* A2)
{
    *A1 = *A2;
}

void set_reg(Cell* X)
{
    heap[h++] = *X;
}

void unify_reg(Cell* X)
{
    if (mode == READ) {
        *X = heap[s];
    }else{
        Cell c;
        c.tag = REF;
        c.address = h;
        heap[h] = c;
        *X = c;
        h++;
    }
    s++;
}

// const instructions
void put_const(char* name,Cell* X)
{
    //still put const in heap (wam book implementation doesn't do this)
    Cell c;
    c.tag = CON;
    c.constant.cname = name;
    c.constant.address = h;
    *X = c;
    heap[h++] = c;
}

void get_const(char* name,Cell* X)
{
    int addr = derf(get_addr(X));
    Cell c = heap[addr];
    if (c.tag == REF) {
        Cell c;
        c.tag = CON;
        c.constant.cname = name;
        c.constant.address = addr;
        heap[addr] = c;
        trace_trail(addr);
    }else if(c.tag == CON){
        if (strcmp(c.constant.cname, name) != 0)
            fail = 1;
    }else{
        fail = 1;
    }
    if(fail)
        backtrack();
}

void set_const(char* name)
{
    Cell c;
    c.tag = CON;
    c.constant.cname = name;
    c.constant.address = h;
    heap[h++] = c;
}

void unify_const(char* name)
{
    if (mode == READ){
        int addr = derf(s);
        Cell c = heap[addr];
        if (c.tag == REF) {
            Cell c;
            c.tag = CON;
            c.constant.cname = name;
            c.constant.address = addr;
            heap[addr] = c;
            trace_trail(addr);
        }else if(c.tag == CON){
            if (strcmp(c.constant.cname, name) != 0)
                fail = 1;
        }else{
            fail = 1;
        }
        if(fail)
            backtrack();
    }else{
        Cell c;
        c.tag = CON;
        c.constant.cname = name;
        c.constant.address = h;
        heap[h++] = c;
    }
    s++;
}

// list instructions
void put_list(Cell* X)
{
    Cell c;
    c.tag = LIS;
    c.address = h+1;
    *X = c;
    heap[h++] = c;
}

void get_list(Cell* X)
{
    int addr = derf(get_addr(X));
    Cell c = heap[addr];
    if (c.tag == REF) {
        Cell c;
        c.tag = LIS;
        c.address = h+1;
        heap[h] = c;
        wam_bind(addr,h);
        h++;
        mode = WRITE;
    }else if(c.tag == LIS){
        s = c.address;
        mode = READ;
    }else{
        fail = 1;
    }
    if(fail)
        backtrack();
}

void print_helper(int addr);
void print_list(int addr)
{
    int a = derf(addr);
    Cell x = heap[a];
    if (x.tag == LIS) {
        printf(",");
        print_helper(x.address);
        print_list(x.address+1);
    } else if(x.tag == CON){
        if (strcmp(x.constant.cname, "nil") != 0)
            printf("|%s",x.constant.cname);
    } else {
        printf("|");
        print_helper(addr);
    }
}

void print_helper(int addr)
{
    int a = derf(addr);
    int i,num;
    Cell x = heap[a];
    Cell fun;
    switch (x.tag) {
        case REF:
            printf("unbound");
            break;
        case STR:
            fun = heap[x.address];
            num = fun.functor.arity;
            if (num == 0) {
                printf("%s",fun.functor.name);
            } else {
                printf("%s(",fun.functor.name);
                for (i = 0; i < num; i++) {
                    print_helper(x.address+1+i);
                    if(i != num - 1)
                        printf(",");
                }
                printf(")");
            }
            break;
        case LIS:
            printf("[");
            print_helper(x.address);
            print_list(x.address+1);
            printf("]");
            break;
        case CON:
            if (strcmp(x.constant.cname, "nil") == 0) {
                printf("[]");
            } else {
                printf("%s",x.constant.cname);
            }
            break;
        default:
            printf("error\n");
            exit(-1);
    }
}

void print_answer(int num,Cell* vars)
{
    int i;
    printf("solution:\n");
    for (i = 0; i < num; i++) {
        print_helper(get_addr(&vars[i]));
        printf("\n");
    }
    printf("\n");
}

void interpreter(){
    while(codes[p].op != END) {
        Instruction ins = codes[p++];
        Frame cf = call_stack[e];
        switch (ins.op) {
            case PUT_STR:
                put_struct(ins.three_args.name, ins.three_args.arity, &A[ins.three_args.a]);
                break;
            case PUT_VIA_REG:
                put_via_reg(&A[ins.two_args.s], &A[ins.two_args.a]);
                break;
            case SET_VAR:
                set_var(&cf.and.lvars[ins.s]);
                break;
            case SET_VAL:
                set_val(&cf.and.lvars[ins.s]);
                break;
            case SET_REG:
                set_reg(&A[ins.s]);
                break;
            case GET_STR:
                get_struct(ins.three_args.name, ins.three_args.arity, &A[ins.three_args.a]);
                break;
            case GET_VIA_REG:
                get_via_reg(&A[ins.two_args.s], &A[ins.two_args.a]);
                break;
            case UNY_VAR:
                unify_var(&cf.and.lvars[ins.s]);
                break;
            case UNY_VAL:
                unify_val(&cf.and.lvars[ins.s]);
                break;
            case UNY_REG:
                unify_reg(&A[ins.s]);
                break;
            case PUT_VAR:
                put_var(&cf.and.lvars[ins.two_args.s],&A[ins.two_args.a]);
                break;
            case PUT_VAL:
                put_val(&cf.and.lvars[ins.two_args.s],&A[ins.two_args.a]);
                break;
            case GET_VAR:
                get_var(&cf.and.lvars[ins.two_args.s],&A[ins.two_args.a]);
                break;
            case GET_VAL:
                get_val(&cf.and.lvars[ins.two_args.s],&A[ins.two_args.a]);
                break;
            case PUT_CONST:
                put_const(ins.const_args.name,&A[ins.const_args.a]);
                break;
            case GET_CONST:
                get_const(ins.const_args.name,&A[ins.const_args.a]);
                break;
            case SET_CONST:
                set_const(ins.const_args.name);
                break;
            case UNY_CONST:
                unify_const(ins.const_args.name);
                break;
            case PUT_LIST:
                put_list(&A[ins.s]);
                break;
            case GET_LIST:
                get_list(&A[ins.s]);
                break;
            case CALL:
                call(ins.label.addr,ins.label.arg_num);
                break;
            case PROCEED:
                proceed();
                break;
            case ALLOC:
                allocate(ins.num);
                break;
            case DEALLOC:
                deallocate();
                break;
            case TRY:
                try(ins.addr);
                break;
            case RETRY:
                retry(ins.addr);
                break;
            case TRUST:
                trust();
                break;
            case FIND_ANSWER:
                print_answer(cf.and.num,cf.and.lvars);
                solunums++;
                goal = 1;
                backtrack();
                break;
            case CUT:
                b = cf.and.b0;
                break;
            case FAIL:
                backtrack();
                break;
            default:
                printf("error\n");
                exit(-1);
        }
    }
}



int main(int argc, const char * argv[]){
    h = 0;
    s = 0;
    p = 0;
    cp = 0;
    e = 0;
    b = -1;
    tr = 0;
    hb = 0;
    pdls = 0;
    goal = 0;
    
    solunums = 0;

    load(codes, argv[1]);
    interpreter();
    return 0;
}

