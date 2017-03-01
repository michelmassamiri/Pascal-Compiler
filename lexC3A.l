%{

#include <stdio.h>
#include "bilquad.h"

%}

%option noyywrap


%s OP ARG1 ARG2 DEST

%%

<INITIAL>[A-Za-z_][A-Za-z0-9_]* {BEGIN(OP); ECHO;}

<OP>:[A-Za-z]+ {printf(" op ");BEGIN(ARG1); ECHO;}

<ARG1>:[A-Za-z][A-Za-z0-9]* {BEGIN(ARG2); ECHO;}

<ARG2>:[A-Za-z][A-Za-z0-9]* {BEGIN(DEST); ECHO;}

<DEST>:[A-Za-z][A-Za-z0-9]* {BEGIN(INITIAL); ECHO;}


[ \t] {}
. {printf("\n An error as been thrown\n"); BEGIN(INITIAL);}

%%

int main(int ac, char** av)
{
    yylex();
}
