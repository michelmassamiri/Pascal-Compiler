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


%s OPE ARGU1 ARGU2 DEST

%%

"exit" { return 0; }

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

void checkVar(int current, int sizeofvars, char**vars)
{
    if(current == sizeofvars)
    {
        vars = realloc(vars, 2*sizeofvars *sizeof(char*));
        sizeofvars*= 2;
    }
}

int main(int ac, char** av)
{
    etiquette = malloc(sizeof(char));
    dest = malloc(sizeof(char));
    arg1 = malloc(sizeof(char));
    arg2 = malloc(sizeof(char));
    yylex();

    ENV environnement = NULL, envFin = environnement;
    QUAD q = bq.debut;
    int tmp1;

    char ** vars = malloc(64*sizeof(char*));
    int sizeofvars = 64, current = 1;
    vars[0] = "Variables\t:nop\n";

    printf("                  .pos      0\nINIT      :irmovl Data,     %%edx\n           irmovl 256,      %%eax\n           addl   %%edx,     %%eax\n");
    printf("           rrmovl %%eax,     %%esp\n           rrmovl %%eax,     %%ebp\n");

    while(q != NULL)
    {
        if(q->OP == Jp)
        {
            printf("%s\t\t:jmp\t%s\n", q->ETIQ, q->RES);
        }
        else if(q->OP == St)
        {
            printf("%s\t\t:halt\n", q->ETIQ);
        }
        else if(q->OP == Jz)
        {
            printf("%s\t\t:irmovl\t%s,\t%%eax\n", q->ETIQ, q->ARG1);
            printf("\t\tje\t%s\n", q->RES);
        }
        else if(q->OP == Af)
        {
            if(rech(q->ARG1, environnement) == NULL)
            {
                initenv(&environnement, q->ARG1);
                checkVar(current, sizeofvars, vars);
                vars[current++] = strncat(q->ARG2, "\t\t: .long 0", 10);
            }
            printf("%s\t\t:mrmovl\t%%eax,\t(%s)\n", q->ETIQ ,q->ARG1);
            printf("\t\trmmovl\t%%eax,\t0(%s)\n", q->ARG2);
        }
        else if(q->OP == Afc)
        {
            if(rech(q->RES, environnement) == NULL)
            {
                initenv(&environnement, q->RES);
                checkVar(current, sizeofvars, vars);
                vars[current++] = strncat(strncat(q->RES, "\t\t: .long ", 10), q->ARG1, 10);
            }
            else
            {
                printf("%s\t\t:irmovl\t%s,\t%%eax\n", q->ETIQ, q->ARG1);
                printf("\t\trmmovl\t%%eax,\t0(%s)\n", q->RES);
            }
        }
        else if(q->OP == Pl || q->OP == Mu || q->OP == Mo)
        {
            if(rech(q->RES, environnement) == NULL)
            {
                initenv(&environnement, q->RES);
                checkVar(current, sizeofvars, vars);
                vars[current++] = strncat(q->ARG2, "\t\t: .long 0", 11);
            }
            printf("%s\t\t:irmovl\t%s,\t%%eax\n", q->ETIQ, q->ARG1);
            printf("\t\tirmovl\t%s,\t%%ebx\n", q->ARG2);
            if(q->OP == Pl)
            {
                printf("\t\taddl\t%%eax,\t%%ebx\n");
            }
            else if(q->OP == Mo)
            {
                printf("\t\tsubl\t%%eax,\t%%ebx\n");
            }
            else
            {
                printf("\t\tpushl\t%%ebx\n");
                printf("\t\tpushl\t%%eax\n");
                printf("\t\tcall\tMUL\n");
                printf("\t\tpopl\t%%eax\n");
                printf("\t\tpopl\t%%ebx\n");
                printf("\t\tmrmovl\t0(%%edx)\t%%ebx\n");
                printf("\t\trmmovl\t%%ebx\t0(%s)\n", q->RES);
            }
            printf("\t\trmmovl\t%%ebx,\t0(%s)\n", q->RES);
        }
        else if(q->OP == Sk)
        {
            printf("%s\t\t:nop\n", q->ETIQ);
        }

        q = q->SUIV;
    }


    printf("MUL       :nop\n");
    printf("           mrmovl 4(%%esp),  %%eax\n");
    printf("           mrmovl 8(%%esp),  %%ebx\n");
    printf("           andl   %%eax,     %%eax\n");
    printf("           je     END\n");
    printf("SIGN      :nop\n");
    printf("           jg     MULPLUS\n");
    printf("           irmovl 0,        %%ecx\n");
    printf("           subl   %%eax,     %%ecx\n");
    printf("           rrmovl %%ecx,     %%eax\n");
    printf("           rmmovl %%eax,     4(%%esp)\n");
    printf("           irmovl 0,        %%ecx\n");
    printf("           subl   %%ebx,     %%ecx\n");
    printf("           rrmovl %%ecx,     %%ebx\n");
    printf("           rmmovl %%ebx,     8(%%esp)\n");
    printf("MULPLUS   :nop\n");
    printf("           mrmovl 4(%%esp),  %%eax\n");
    printf("           andl   %%eax,     %%eax\n");
    printf("           je     END\n");
    printf("           irmovl 1,        %%esi\n");
    printf("           subl   %%esi,     %%eax\n");
    printf("           mrmovl 8(%%esp),  %%ebx\n");
    printf("           pushl  %%ebx\n");
    printf("           pushl  %%eax\n");
    printf("           call   MULPLUS\n");
    printf("           popl   %%eax\n");
    printf("           popl   %%eax\n");
    printf("           mrmovl 0(%%edx),  %%eax\n");
    printf("           mrmovl 8(%%esp),  %%ebx\n");
    printf("           addl   %%ebx,     %%eax\n");
    printf("           rmmovl %%eax,     0(%%edx)\n");
    printf("           ret\n");
    printf("END       :irmovl 0,        %%eax\n");
    printf("           rmmovl %%eax,     0(%%edx)\n");
    printf("           ret\n");
    printf("           .align 8\n");



    for(int i = 0; i < sizeofvars; ++i)
    {
        if(vars[i] == NULL)
            break;
        printf("%s\n", vars[i]);
    }
    printf("Data\t\t:\n");
    printf("\t\t.align 8\n");

    free(vars);
    free(etiquette);
    free(dest);
    free(arg1);
    free(arg2);
    return 0;
}
