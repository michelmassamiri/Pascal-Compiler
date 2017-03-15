%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"

  #include "iimp.tab.h"
%}

%option noyywrap

/* Declare tokens */
%%
[sS]kip                           {return Sk;}
if                                {return If;}
then                              {return Th;}
else                              {return El;}
while                             {return Wh;}
do                                {return Do;}
[0-9]+                            {yylval.iValue = atoi(yytext); return CONSTANT;}
[A-Z][A-Za-z0-9]*                 {yylval.id = strdup(yytext); return VARIABLE;}
"+"                               {return Pl;}
"-"                               {return Mo;}
"*"                               {return Mu;}
":="                              {return Af;}
";"                               {return Se;}
[ \t\n]                             {;}
.                                 {return *yytext;}

%%
