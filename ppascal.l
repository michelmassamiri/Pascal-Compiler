%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"

  #include "ppascal.tab.h"

%}

%option noyywrap
%s DEFUN DEFPRO FONC PROC

/* Declare tokens */
%%

"+" { return Pl; }
"-" { return Mo; }
"*" { return Mu; }
"OR" | "or" { return Or; }
"AND" | "and" { return And; }
"not" { return Not; }
":=" { return Af; }
"<" { return Lt ;}
"=" { return Eq; }
";" { return Se; }


"if" { return If; }
"then" { return Th; }
"else" { return El; }
"while" { return Wh; }
"do" { return Do; }
"skip" { return Sk; }
"boolean" { return T_bool; }
"integer" { return T_int; }
"new array of" { return NewAr; }
"array of" { return T_ar; }
"var" { return Var; }



"true" { return True; }
"false" { return False; }

<DEFUN>defun {BEGIN(FONC); return Def;}
<DEFPRO>defpro {BEGIN(PROC); return Dep;}
<FONC>[A-Za-z][A-Za-z0-9]* {BEGIN(INITIAL); yylval.id = strdup(yytext); return NFon; }
<PROC>[A-Za-z][A-Za-z0-9]* {BEGIN(INITIAL); yylval.id = strdup(yytext); return NPro; }
0|[1-9][0-9]* { yylval.iValue = atoi(yytext); return I; }
[A-Za-z][A-Za-z0-9]* { yylval.id = strdup(yytext); return V; }




[ \t\n] {;}
. { return *yytext; }
%%
