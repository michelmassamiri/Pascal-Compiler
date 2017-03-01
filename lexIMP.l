%{
  #include <stdio.h>
  #include "environ.h"
  int yylval;
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
[0-9]+                            {yylval = atoi(yytext); return NUMBER;}
[A-Z][A-Za-z0-9]*                 {printf("%s ", yytext);}
"+"                               {return Pl;}
"-"                               {return Mo;}
"*"                               {return Mu;}
":="                              {return Af;}
";"                               {return Se;}
[ \t]                             {}
.                                 {printf("mot non reconnu\n");}

%%
int main(int argc, char** argv) {
  yylex();
  return 0;
}
