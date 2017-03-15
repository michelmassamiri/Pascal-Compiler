%{

#include <stdio.h>
#include <string.h>
#include "bilquad.h"
#include "environ.h"
#include "enum_operation.h"

char *etiquette;
int operateur;
char *arg1, *arg2, *dest;

BILQUAD bq;

%}

%option noyywrap


%s OP ARG1 ARG2 DEST

%%

<INITIAL>ET[0-9]* {
                                    BEGIN(OP);
                                    free(etiquette);
                                    etiquette = malloc(sizeof(char)*yyleng);
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
                                    else
                                    {
                                        printf("\n An error as been thrown\n");
                                        return -1;
                                    }
                                    ECHO;
               }

<ARG1>:[A-Za-z0-9]* {
                                    BEGIN(ARG2);
                                    free(arg1);
                                    arg1 = malloc(sizeof(char)*(yyleng-1));
                                    strcpy(arg1, yytext+1);
                                    ECHO;
                    }


<ARG2>:[A-Za-z0-9]* {
                                    BEGIN(DEST);
                                    free(arg2);
                                    arg2 = malloc(sizeof(char)*(yyleng-1));
                                    strcpy(arg2, yytext+1);
                                    ECHO;
                    }


<DEST>:[A-Za-z0-9]* {
                                    BEGIN(INITIAL);
                                    free(dest);
                                    dest = malloc(sizeof(char)*(yyleng-1));
                                    strcpy(dest, yytext+1);

                                    BILQUAD b = creer_bilquad(creer_quad(etiquette, operateur, arg1, arg2, dest));
                                    bq = concatq(bq, b);

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

    ENV environnement = Envalloc(), envFin = environnement;
    QUAD q = bq.debut, tmpQuad;
    int tmp1, tmp2;

    while(q != NULL)
    {
        if(q->OP == Jp)
        {
            q = rechbq(q->RES, bq);
            continue;
        }
        else if(q->OP == St)
            break;
        else if(q->OP == Jz)
        {
            tmp1 = atoi(q->ARG1);
            if(arg1 == 0)
            {
                q = rechbq(q->RES, bq);
                continue;
            }
        }
        else if(q->OP == Af)
        {
            ENV e2 = rech(q->ARG2, environnement);
            ENV e1 = rech(q->ARG1, environnement);

            if(e2 == NULL)
            {
                e2 = Envalloc();
                initenv(e2, 0);
                envFin->SUIV = e2;
                envFin = e2;
            }
            if(e1 != NULL)
                e1->VAL = e1->VAL;
        }
        else if(q->OP == Afc)
        {
            ENV e = rech(q->RES, environnement);
            if(e == NULL)
            {
                e = Envalloc();
                initenv(e, 0);
                envFin->SUIV = e;
                envFin = e;
            }

            e->VAL = atoi(q->ARG1);

        }
        else if(q->OP == Pl || q->OP == Mu || q->OP == Mo)
        {
            ENV e = rech(q->RES, environnement);
            if(e == NULL)
            {
                e = Envalloc();
                envFin->SUIV = e;
                envFin = e;
            }
            initenv(e, eval(q->OP, atoi(q->ARG1), atoi(q->ARG2)));
        }
        else if(q->OP == Sk) {;}

        q = q->SUIV;
    }


    free(etiquette);
    free(dest);
    free(arg1);
    free(arg2);
    return 0;
}
