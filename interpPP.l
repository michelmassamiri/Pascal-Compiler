%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"

  #include "interpPP.tab.h"
%}

%option noyywrap

/* Declare tokens */
%%

//operateurs
"+" { return Pl; }
"-" { return Mo; }
"*" { return Mu; }
"OR" | "or" { return Or; }
"AND" | "and" { return And; }
"!" { return Not; }
":=" { return Af; }
"<" { return Lt ;}
"=" { return Eq; }

//symboles
"(" | ")" | "[" | "]" | "{" | "}" | "," { return *yytext; }
";" { return Se; }

//Mots Cles
"if" { return If; }
"then" { return Th; }
"else" { return El; }
"while" { return Wh; }
"do" { return Do; }
"skip" { return Sk; }
"bool" { return T_bool; }
"int" { return T_int; }
"array of" { return T_array; }

//utilisateur
[1-9][0-9]* { yylval.iValue = atoi(yytext); return I; }
[A-Za-z_][A-Za-z0-9_]* { yylval.id = strdup(yytext); return V; }

//autres
[ \t\n] {;}
. { return *yytext; }
%%
