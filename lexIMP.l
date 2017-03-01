%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"

  #include "YaccIMP.tab.h"
  void yyerror(char*);
%}

%option noyywrap

/* Declare tokens */
%%
Skip                              {return Sk;}
if                                {return If;}
then                              {return Th;}
else                              {return El;}
while                             {return Wh;}
do                                {return Do;}
[0-9]+                            {yylval.iValue = atoi(yytext); return CONSTANT;}
[A-Z][A-Za-z0-9]*                 {yylval.id = *yytext; return VARIABLE;}
"+"                               {return Pl;}
"-"                               {return Mo;}
"*"                               {return Mu;}
":="                              {return Af;}
";"                               {return Se;}
[ \t]                             {}
.                                 yyerror("Unknown character");

%%
