%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>

  #include "environ_IMP.h"
  #include "environ.h"
  void yyerror(char*);
  int yylex();

%}

%union{
    int iValue; // the value of the constant
    char* id; // the variable string
    nodeType* p; // the node type
};

%token <iValue> CONSTANT
%token <id> VARIABLE
%token Sk If Wh Do Pl Mo Mu Af Se
%noassoc Th El

%type <p> C c E T F

%%

C3A : C                         {ENV e = Envalloc(); execute(&e, $1); }
    ;

C   : C Se c                    {$$ = opr(Se, 2, $1, $3);}
    | c                         {$$ = $1 ;}
    ;

c   : Se                        { $$ = opr(Se, 2, NULL, NULL);}
    | VARIABLE Af E             { nodeType* n = id($1); $$ = opr(Af, 2, n, $3); }
    | Sk                        { $$ = opr(Sk, 2, NULL, NULL); }
    | '(' C ')'                 { $$ = $2; }
    | If E Th C                 { $$ = opr(If, 2, $2, $4); }
    | If E Th C El C            { $$ = opr(If, 3, $2, $4, $6); }
    | Wh E Do C                 { $$ = opr(Wh, 2, $2, $4); }
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
    | VARIABLE                  { $$ = id($1); }
    ;

%%

void yyerror(char* s){
  fprintf(stdout, "%s\n", s);
}

int main(int argc, char** argv) {
  yyparse();
  return 0;
}
