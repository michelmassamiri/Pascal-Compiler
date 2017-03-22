%{

#include <stdio.h>
#include <string.h>
#include "bilquad.h"
#include "environ.h"
#include "enum_operation.h"

char *etiquette;
int operateur = 0;
char *arg1, *arg2, *dest;

BILQUAD bq;

%}

%option noyywrap


%s OPE ARGU1 ARGU2 DEST

%%

"exit"  { return 0;}

<INITIAL>ET[0-9]* {
                                    BEGIN(OPE);
                                    free(etiquette);
                                    etiquette = malloc(sizeof(char)*yyleng);
                                    strcpy(etiquette, yytext);
                                    ECHO;
                                }

<OPE>:[A-Za-z]+ {
                                    BEGIN(ARGU1);
                                    if(strcmp(yytext+1, "Pl") == 0)
                                        operateur = Pl;
                                    else if(strcmp(yytext+1, "Mo") == 0)
                                        operateur = Mo;
                                    else if(strcmp(yytext+1, "Mu") == 0)
                                        operateur = Mu;
                                    else if(strcmp(yytext+1, "Af") == 0)
                                        operateur = Af;
                                    else if(strcmp(yytext+1, "Afc") == 0)
                                        operateur = Afc;
                                    else if(strcmp(yytext+1, "Sk") == 0)
                                        operateur = Sk;
                                    else if(strcmp(yytext+1, "Jp") == 0)
                                        operateur = Jp;
                                    else if(strcmp(yytext+1, "Jz") == 0)
                                        operateur = Jz;
                                    else if(strcmp(yytext+1, "St") == 0)
                                        operateur = St;
                                    else
                                    {
                                        printf("\n An error as been thrown\n");
                                        return -1;
                                    }
                                    ECHO;
               }

<ARGU1>:[A-Za-z0-9]* {
                                    BEGIN(ARGU2);
                                    free(arg1);
                                    arg1 = malloc(sizeof(char)*(yyleng-1));
                                    strcpy(arg1, yytext+1);
                                    ECHO;
                    }


<ARGU2>:[A-Za-z0-9]* {
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

    ENV environnement = NULL;
    QUAD q = bq.debut;

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
            if(valch(environnement, q->ARG1) == 0)
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
                initenv(&environnement, q->ARG2);
                e2 = rech(q->ARG2, environnement);
            }
            if(e1 != NULL)
                e1->VAL = e2->VAL;
        }
        else if(q->OP == Afc)
        {
            if(rech(q->RES, environnement) == NULL)
                initenv(&environnement, q->RES);
            affect(environnement, q->RES, atoi(q->ARG1));
        }
        else if(q->OP == Pl || q->OP == Mu || q->OP == Mo)
        {
            ENV e = rech(q->RES, environnement);
            if(e == NULL)
            {
                initenv(&environnement, q->RES);
                e = rech(q->RES, environnement);
            }
            e->VAL = eval(q->OP, atoi(q->ARG1), atoi(q->ARG2));
        }
        else if(q->OP == Sk) {;}
        else{
            printf("error\n");
            return 0;
        }
        q = q->SUIV;
    }


    ecrire_env(environnement);


    free(etiquette);
    free(dest);
    free(arg1);
    free(arg2);
    return 0;
}
