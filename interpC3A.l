%{

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#include "bilquad.h"
#include "environ.h"
#include "enum_operation.h"


#define STACKSIZE 64

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
                                    else if(strcmp(yytext+1, "Ind") == 0)
                                        operateur = Ind;
                                    else if(strcmp(yytext+1, "And") == 0)
                                        operateur = And;
                                    else if(strcmp(yytext+1, "Or") == 0)
                                        operateur = Or;
                                    else if(strcmp(yytext+1, "Not") == 0)
                                        operateur = Not;
                                    else if(strcmp(yytext+1, "Lt") == 0)
                                        operateur = Lt;
                                    else if(strcmp(yytext+1, "Param") == 0)
                                        operateur = Param;
                                    else if(strcmp(yytext+1, "Param") == 0)
                                        operateur = Param;
                                    else if(strcmp(yytext+1, "Ret") == 0)
                                        operateur = Ret;
                                    else if(strcmp(yytext+1, "AfInd") == 0)
                                        operateur = AfInd;
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

int isNumber(char *chaine)
{
    int l = strlen(chaine);
    for (int i = 0; i < l; ++i)
    {
        if (!isdigit(chaine[i]))
            return 0;
    }
    return 1;
}

int main(int ac, char **av)
{
    etiquette = malloc(sizeof(char));
    dest = malloc(sizeof(char));
    arg1 = malloc(sizeof(char));
    arg2 = malloc(sizeof(char));

    yylex();

    ENV stack[STACKSIZE];
    for (int i = 0; i < STACKSIZE; ++i)
    {
        stack[i] = NULL;
    }
    ENV environnement = stack[0];
    QUAD stackQuad[STACKSIZE];
    QUAD q = bq.debut;

    int stackLayer = 0; //taille actuelle de la pile d'appel

    while (q != NULL)
    {
        if (q->OP == Jp)
        {
            q = rechbq(q->RES, bq);
            continue;
        }
        else if (q->OP == St)
            break;
        else if (q->OP == Jz)
        {
            if (valch(environnement, stack[0], q->ARG1) == 0)
            {
                q = rechbq(q->RES, bq);
                continue;
            }
        }
        else if (q->OP == Af)
        {
            if (rech(q->ARG1, stack[0]) == NULL)
            {
                if (rech(q->ARG1, environnement) == NULL)
                    initenv(&environnement, q->ARG1);
                affect(environnement, q->ARG1, valch(environnement, stack[0], q->ARG2));
            }
            else
            {
                affect(stack[0], q->ARG1, valch(environnement, stack[0], q->ARG2));
            }
        }
        else if (q->OP == Afc)
        {
            if (rech(q->RES, stack[0]) == NULL)
            {
                if (rech(q->RES, environnement) == NULL)
                    initenv(&environnement, q->RES);
                affect(environnement, q->RES, atoi(q->ARG1));
            }
            else
            {
                affect(stack[0], q->RES, atoi(q->ARG1));
            }
        }
        else if (q->OP == Pl || q->OP == Mu || q->OP == Mo || q->OP == And || q->OP == Or)
        {
            if (rech(q->RES, stack[0]) == NULL)
            {
                if (rech(q->RES, environnement) == NULL)
                    initenv(&environnement, q->RES);
                affect(environnement, q->RES, eval(q->OP, valch(environnement, stack[0], q->ARG1), valch(environnement, stack[0], q->ARG2)));
            }
            else
            {
                affect(environnement, q->RES, eval(q->OP, valch(environnement, stack[0], q->ARG1), valch(environnement, stack[0], q->ARG2)));
            }
        }
        else if (q->OP == Sk)
        {
            ;
        }
        else if (q->OP == Lt)
        {
            if (rech(q->RES, stack[0]) == NULL)
            {
                if (rech(q->RES, environnement) == NULL)
                    initenv(&environnement, q->RES);
                if (valch(environnement, stack[0], q->ARG1) < valch(environnement, stack[0], q->ARG2))
                    affect(environnement, q->RES, 1);
                else
                    affect(environnement, q->RES, 0);
            }
            else
            {
                if (valch(environnement, stack[0], q->ARG1) < valch(environnement, stack[0], q->ARG2))
                    affect(stack[0], q->RES, 1);
                else
                    affect(stack[0], q->RES, 0);
            }
        }
        else if (q->OP == Ind)
        {
            char *varName = malloc((2 + strlen(q->ARG1) + strlen(q->ARG2)) * sizeof(char));
            strcat(varName, q->ARG1);
            strcat(varName, "[");

            if (rech(q->ARG2, environnement) != NULL || rech(q->ARG2, stack[0]) != NULL)
            {
                int index = valch(environnement, stack[0], q->ARG2);
                char *arg2 = malloc((floor(log10(abs(index))) + 1) * sizeof(char));
                sprintf(arg2, "%d", index);
                strcat(varName, arg2);
            }
            else if (isNumber(q->ARG2))
                strcat(varName, q->ARG2);
            else
            {
                fprintf(stderr, "Variable %s does not exist\n", q->ARG2);
                return -1;
            }
            strcat(varName, "]");
            if (rech(q->RES, stack[0]) == NULL)
            {
                if (rech(q->RES, environnement) == NULL)
                    initenv(&environnement, q->RES);
                affect(environnement, q->RES, valch(environnement, stack[0], varName));
            }
            else
            {
                affect(stack[0], q->RES, valch(environnement, stack[0], varName));
            }
        }
        else if (q->OP == AfInd)
        {
            char *varName = malloc((2 + strlen(q->ARG1) + strlen(q->ARG2)) * sizeof(char));
            strcat(varName, q->ARG1);
            strcat(varName, "[");
            if (rech(q->ARG2, environnement) != NULL || rech(q->ARG2, stack[0]) != NULL)
            {
                int index = valch(environnement, stack[0], q->ARG2);
                char *arg2 = malloc((floor(log10(abs(index))) + 1) * sizeof(char));
                sprintf(arg2, "%d", index);
                strcat(varName, arg2);
            }
            else if (isNumber(q->ARG2))
                strcat(varName, q->ARG2);
            else
            {
                fprintf(stderr, "Variable %s does not exist\n", q->ARG2);
                return -1;
            }
            strcat(varName, "]");
            if (rech(varName, stack[0]) == NULL)
            {
                if (rech(varName, environnement) == NULL)
                    initenv(&environnement, varName);
                affect(environnement, varName, valch(environnement, stack[0], q->RES));
            }
            else
            {
                affect(stack[0], varName, valch(environnement, stack[0], q->RES));
            }
        }
        else if (q->OP == Not)
        {
            if (rech(q->RES, stack[0]) == NULL)
            {
                if (rech(q->RES, environnement) == NULL)
                    initenv(&environnement, q->RES);
                affect(environnement, q->RES, !valch(environnement, stack[0], q->ARG1));
            }
            else
            {
                affect(stack[0], q->RES, !valch(environnement, stack[0], q->ARG1));
            }
        }
        else if (q->OP == Param)
        {
            if (rech(q->ARG1, stack[stackLayer + 1]) == NULL)
                initenv(&stack[stackLayer + 1], q->ARG1);
            affect(stack[stackLayer + 1], q->ARG1, atoi(q->ARG2));
        }
        else if (q->OP == Call)
        {
            stackQuad[stackLayer] = q->SUIV;
            if (++stackLayer >= STACKSIZE)
            {
                printf("Stack Overflow.\n");
                return EXIT_FAILURE;
            }
            environnement = stack[stackLayer];
            q = rechbq(q->ARG1, bq);
        }
        else if (q->OP == Ret)
        {
            if (stackLayer == 0)
                return 0;
            environnement = stack[--stackLayer];
            q = stackQuad[stackLayer];
        }
        else
        {
            printf("error\n");
            return EXIT_FAILURE;
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
