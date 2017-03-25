%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"

  #include "interpPP.tab.h"

  int value = V;
%}

%option noyywrap

/* Declare tokens */
%%

"+" { return Pl; }
"-" { return Mo; }
"*" { return Mu; }
"OR" | "or" { return Or; }
"AND" | "and" { return And; }
"!" { return Not; }
":=" { return Af; }
"<" { return Lt ;}
"=" { return Eq; }


"(" | ")" | "[" | "]" | "{" | "}" | "," { return *yytext; }
";" { return Se; }


"if" { return If; }
"then" { return Th; }
"else" { return El; }
"while" { return Wh; }
"do" { return Do; }
"skip" { return Sk; }
"bool" { return T_bool; }
"int" { return T_int; }
"new array of" { return NewAr; }
"array of" { return T_array; }
"defun" { value = NFon; return Def; }
"depro" { value = NPro; return Dep; }
"var" { return Var; }



"true" { return True; }
"false" { return False; }
[1-9][0-9]* { yylval.iValue = atoi(yytext); return I; }
[A-Za-z_][A-Za-z0-9_]* { yylval.id = strdup(yytext); int v = value; value = V; return v; }




[ \t\n] {;}
. { return *yytext; }
%%
