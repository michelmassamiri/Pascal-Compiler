%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>

  #include "environ_IMP.h"
  #include "environ.h"

  extern int yyerror(char*);
  extern int yylex();

  int line = 1;

%}


%union{
    int iValue; // the value of the constant
    char* id; // the variable string
    nodeType* p; // the node type
};


/* tokens definissant des operateurs */
%token Pl Mo Mu Or Lt Eq And Not Af

/* tokens definissant des symboles */
%token Se

/* Token definissant des mots cles */
%token If Th El Wh Do Sk T_bool T_int T_ar Def Dep NewAr Var

/* Token definissant les symboles et chaines utilisateur */
%token<iValue> I True False
%token<id> V NFon NPro

/* Les règles pour les tokens */
%nonassoc Th El Eq Lt

%left Pl Mo Or
%left Mu

/* Definir les non-terminals */





%%

MP          : L_vart LD C                           {printf("la Syntax est vraie\n"); YYACCEPT;}
            ;

E           : E Pl T
            | E Mo T
            | E Mu T
            | E Or T
            | E Lt T
            | E Eq T
            | T
            ;

T           : T And F
            | Not F
            | F
            ;

F           : '(' E ')'
            | I
            | V
            | True
            | False
            | V '(' L_args ')'
            | NewAr TP '[' E ']'
            | Et
            ;

Et          : V '[' E ']'
            | Et '[' E ']'
            ;

C           : C Se c
            | c
            ;

c           : Et Af E
            | V Af E
            | Sk
            | '{' C '}'
            | If E Th C El c
            | Wh E Do c
            | V '(' L_args ')'
            ;

L_args      : %empty
            | L_argsnn
            ;

L_argsnn    : E
            | E ',' L_argsnn
            ;

L_argt      : %empty
            | L_argtnn
            ;

L_argtnn    : Argt
            | L_argtnn ',' Argt
            ;

Argt        : V ':' TP
            ;

TP          : T_bool
            | T_int
            | T_ar TP
            ;

L_vart      : %empty
            | L_vartnn
            ;

L_vartnn    : Var Argt
            | L_vartnn ',' Var Argt
            ;

D_entp      : Dep NPro '(' L_argt ')'
            ;

D_entf      : Def NFon '(' L_argt ')' ':' TP
            ;

D           : D_entp L_vart C
            | D_entf L_vart C
            ;

LD          : %empty
            | LD D
            ;

%%

int yyerror(char* s){
  fprintf(stdout, "%s\n", s);
  return 0;
}

int main() {
  return yyparse();
}
