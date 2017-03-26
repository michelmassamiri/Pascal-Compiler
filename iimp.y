%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>

  #include "environ_IMP.h"
  #include "environ.h"
  extern int yyerror(char*);
  extern int yylex();

  int interpreter(ENV p, nodeType*n);
  int compiler(ENV p, nodeType* n);
  ENV e;
  nodeType* arbre;
  /*
  noms : MASSAMIRI MICHEL
         DEMOULINS LOUIS

   Pour la question 1 : La fonction s'apelle "interpreter".
                       Elle se retrouve dans ce fichier.


   Pour la question 2 : Le module contenant cette question se retrouve dans le fichier "interpC3A.l"

   Pour la question 3 : La fonction s'apelle "compiler".
                        Elle se retrouve dans ce fichier.

   Pour la question 4 : le module contenant cette question se retrouve dans le fichier "compilC3A.l"
  */


%}

%union{
    int iValue; // the value of the constant
    char *id; // the variable string
    nodeType* p; // the node type
};

%token<iValue> CONSTANT
%token<id> VARIABLE
%token Sk If Wh Do Pl Mo Mu Af Se Mp
%nonassoc Th El

%type<p> C3A C c E T F
%start C3A

%%

C3A : C                         {$$ = opr(Mp, 1, $1); arbre = $$; YYACCEPT;}
    ;

C   : C Se c                    {$$ = opr(Se, 2, $1, $3);}
    | c                         {$$ = $1 ;}
    ;

c   : VARIABLE Af E             { nodeType* n = id($1); $$ = opr(Af, 2, n, $3); }
    | Sk                        { $$ = opr(Sk, 2, NULL, NULL); }
    | '(' C ')'                 { $$ = $2; }
    | If E Th C El c            { $$ = opr(If, 3, $2, $4, $6); }
    | Wh E Do c                 { $$ = opr(Wh, 2, $2, $4); }
    ;

E   : E Pl T                    { $$ = opr(Pl, 2, $1, $3); }
    | E Mo T                    { $$ = opr(Mo, 2, $1, $3); }
    | T                         { $$ = $1; }
    ;

T   : T Mu F                    { $$ = opr(Mu, 2, $1, $3); }
    | F                         { $$ = $1; }
    ;

F   : '(' E ')'                 { $$ = $2 ;}
    | CONSTANT                  { $$ = con($1); }
    | VARIABLE                  { $$ = id($1);  }
    ;

%%

int yyerror(char* s){
  fprintf(stdout, "%s\n", s);
  return 0;
}

static int interpreter_recursive(ENV e, nodeType* n) {
  if(n == NULL)
    return 0;

  if(n->type == typeCon)
    return n->con.value;

  if(n->type == typeId){
    return valch(e, n->id.v);
  }


  if(n->type == typeOpr) {
    switch(n->opr.oper) {
      case Mp : interpreter_recursive(e, n->opr.op[0]); break;
      case Wh :
                while(interpreter_recursive(e, n->opr.op[0])) interpreter_recursive(e, n->opr.op[1]); return 0;
      case If :
                if(n->opr.op[2] != NULL) {
                    if(interpreter_recursive(e, n->opr.op[0])) interpreter_recursive(e, n->opr.op[1]);
                    else {
                       interpreter_recursive(e, n->opr.op[2]);
                    }
                }
                else {
                  if(interpreter_recursive(e, n->opr.op[0])) interpreter_recursive(e, n->opr.op[1]);
                }
                return 0;
      case Sk :
                return 0 ;
      case Se :
                interpreter_recursive(e, n->opr.op[0]) ; interpreter_recursive(e, n->opr.op[1]); return 0;
      case Pl :
                return interpreter_recursive(e, n->opr.op[0]) + interpreter_recursive(e, n->opr.op[1]);
      case Mo :
                return interpreter_recursive(e, n->opr.op[0]) - interpreter_recursive(e, n->opr.op[1]);
      case Mu :
                return interpreter_recursive(e, n->opr.op[0]) * interpreter_recursive(e, n->opr.op[1]);
      case Af :
                initenv(&e, n->opr.op[0]->id.v); return affect(e, n->opr.op[0]->id.v, interpreter_recursive(e, n->opr.op[1]));
    }
  }
  return 0;
}

int interpreter(ENV e, nodeType* n) {
  //if(e == NULL)
    //yyerror("error environt e is NULL in interpreter");

  interpreter_recursive(e, n);
  //ecrire_env(e);
  return 0;
}

static int print_line(int id, char* op,  char* arg1, char* arg2, char* dest) {
  printf("ET%d\t:%s\t:%s\t:%s\t:%s\n", id, op, arg1, arg2, dest);
  return 0;
}

int compiler(ENV e, nodeType* n){
  int et, mem, tmp_mem, jmp, jmp_1, jmp_2;
  char arg1[16];
  char arg2[16];
  char dest[16];
  char dest_2[16];

  if(n == NULL)
    return 0;

  if(n->type == typeCon) {
    sprintf(arg1, "%d", n->con.value);
    sprintf(dest, "CT%d", ++mem);
    print_line(et, "Afc", arg1, "", dest);
  }

  if(n->type == typeId) {
    sprintf(arg1, "CT%d", ++mem);
    print_line(et++, "Af", arg1, n->id.v,  "");
  }

  else if(n->type == typeOpr) {
    switch(n->opr.oper) {
      case If :
                compiler(e, n->opr.op[0]);
                sprintf(arg1, "CT%d", mem);
                sprintf(dest, "ET%d", ++et);
                print_line(et++, "Jz", arg1, "", dest);
                compiler(e, n->opr.op[1]);
                sprintf(dest_2, "ET%d", ++et);
                print_line(++et, "Jp", "", "", dest_2);
                printf("%s\t:%s\t:%s\t:%s\t:%s\n",dest,"Sk","","","");
                compiler(e, n->opr.op[2]);
                printf("%s\t:%s\t:%s\t:%s\t:%s\n",dest_2,"Sk","","","");
                return 0;

      case Af :
                compiler(e, n->opr.op[1]);
                sprintf(arg2, "CT%d", mem);
                print_line(++et, "Af", n->opr.op[0]->id.v, arg2, "");
                break;

      case Se :
                compiler(e, n->opr.op[0]); return compiler(e, n->opr.op[1]);

      case Wh :
                sprintf(dest, "ET%d", ++et);
                printf("%s\t:%s\t:%s\t:%s\t:%s\n",dest,"Sk","","","");
                compiler(e, n->opr.op[0]);
                sprintf(arg1, "CT%d", mem);
                sprintf(dest_2, "ET%d", ++et);
                print_line(et++, "Jz", arg1, "", dest_2);
                compiler(e, n->opr.op[1]);
                print_line(++et, "Jp", "", "", dest);
                printf("%s\t:%s\t:%s\t:%s\t:%s\n",dest_2,"Sk","","","");
                return 0;

      case Pl :
                compiler(e, n->opr.op[0]);
                tmp_mem = mem;
                compiler(e, n->opr.op[1]);
                sprintf(arg1, "CT%d", tmp_mem);
                sprintf(arg2, "CT%d", mem);
                sprintf(dest, "CT%d", ++mem);
                print_line(++et, "Pl", arg1, arg2,dest);
                break;

      case Mu :
                compiler(e, n->opr.op[0]);
                tmp_mem = mem;
                compiler(e, n->opr.op[1]);
                sprintf(arg1, "CT%d", tmp_mem);
                sprintf(arg2, "CT%d", mem);
                sprintf(dest, "CT%d", ++mem);
                print_line(++et, "Mu", arg1, arg2,dest);
                break;

      case Mo :
                compiler(e, n->opr.op[0]);
                tmp_mem = mem;
                compiler(e, n->opr.op[1]);
                sprintf(arg1, "CT%d", tmp_mem);
                sprintf(arg2, "CT%d", mem);
                sprintf(dest, "CT%d", ++mem);
                print_line(++et, "Mo", arg1, arg2,dest);
                break;
    }
  }
  return 0;
}

int main() {
  //e = Envalloc();
  //if(e == NULL)
    //fprintf(stderr, "ERROR ALLOC environ e\n");
  yyparse();
  interpreter(e, arbre);
  ecrire_env(e);
  return 0;
}
