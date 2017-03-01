%{

#include <stdio.h>
#include <string.h>
#include "bilquad.h"
#include "environ.h"

char *etiquette;
int operateur;
char *arg1, *arg2, *dest;

%}

%option noyywrap


%s OP ARG1 ARG2 DEST

%%

<INITIAL>[A-Za-z_][A-Za-z0-9_]* {
                                    BEGIN(OP);
                                    free(etiquette);
                                    etiquette = malloc(sizeof(char)*yylen);
                                    strcpy(etiquette, yytext);
                                    ECHO;
                                }

<OP>:[A-Za-z]+ {
                                    BEGIN(ARG1);
                                    if(strcmp(yytext+1, "Pl"))
                                        operateur = Pl;
                                    else if(strcmp(yytext+1, "Mo"))
                                        operateur = Mo;
                                    else if(strcmp(yytext+1, "Mu"))
                                        operateur = Mu;
                                    else if(strcmp(yytext+1, "Af"))
                                        operateur = Af;
                                    else if(strcmp(yytext+1, "Afc"))
                                        operateur = Afc;
                                    else if(strcmp(yytext+1, "Sk"))
                                        operateur = Sk;
                                    else if(strcmp(yytext+1, "Jp"))
                                        operateur = Jp;
                                    else if(strcmp(yytext+1, "Jz"))
                                        operateur = Jz;
                                    else if(strcmp(yytext+1, "St"))
                                        operateur = St;
                                    else if(strcmp(yytext+1, "If"))
                                        operateur = If;
                                    else if(strcmp(yytext+1, "Th"))
                                        operateur = Th;
                                    else if(strcmp(yytext+1, "El"))
                                        operateur = El;
                                    else if(strcmp(yytext+1, "Wh"))
                                        operateur = Wh;
                                    else if(strcmp(yytext+1, "Do"))
                                        operateur = Do;
                                    else if(strcmp(yytext+1, "Se"))
                                        operateur = Se;
                                    ECHO;
               }

<ARG1>:[A-Za-z][A-Za-z0-9]* {
                                    BEGIN(ARG2);

                                    ECHO;
                            }
                            

<ARG2>:[A-Za-z][A-Za-z0-9]* {
                                    BEGIN(DEST);

                                    ECHO;
                            }


<DEST>:[A-Za-z][A-Za-z0-9]* {
                                    BEGIN(INITIAL);

                                    ECHO;
                            }



[ \t] {}
. {printf("\n An error as been thrown\n"); BEGIN(INITIAL);}

%%

int main(int ac, char** av)
{
    etiquette = malloc(sizeof(char));
    dest = malloc(sizeof(char));
    arg1 = malloc(sizeof(char));
    arg2 = malloc(sizeof(char));
    yylex();
    free(etiquette);
    free(dest);
    free(arg1);
    free(arg2);
    return 0;
}
