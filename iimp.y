%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>

  #include "environ_IMP.h"
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
