%{
  #include <stdio.h>
  #include <string.h>
  #include "environ_IMP.h"
  #include "environ.h"

  #include "iimp.tab.h"
  ENV e;
%}

%option noyywrap

/* Declare tokens */
%%
skip                              {return Sk;}
if                                {return If;}
then                              {return Th;}
else                              {return El;}
while                             {return Wh;}
do                                {return Do;}
"+"                               {return Pl;}
"-"                               {return Mo;}
"*"                               {return Mu;}
0|[1-9][0-9]*                     {yylval.iValue = atoi(yytext); return CONSTANT;}
[A-Za-z][A-Za-z0-9]*              {yylval.id = strdup(yytext); initenv(&e, yylval.id); return VARIABLE;}
":="                              {return Af;}
";"                               {return Se;}
[ \t\n]                           {;}
.                                 {return *yytext;}

%%
