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

    char ** vars = malloc(64*sizeof(char*));
    int sizeofvars = 64, current = 1;
    vars[0] = "Variables\t\t:nop\n";

    printf("                  .pos      0\nINIT      :irmovl Data,     %%edx\n           irmovl 256,      %%eax\n           addl   %%edx,     %%eax\n"
    printf("           rrmovl %%eax,     %%esp\n           rrmovl %%eax,     %%ebp\n");

    while(q != NULL)
    {
        if(q.OP == Jp)
        {
            printf("%s\t\t:jmp\t%s\n", q.ETIQ, q.DEST);
        }
        else if(q.OP == St)
        {
            printf("%s\t\t:halt\n", q.ETIQ);
        }
        else if(q.OP == Jz)
        {
            printf("%s\t\t:irmovl\t%s,\t%%eax\n", q.ETIQ, q.ARG1);
            printf("\t\tje\t%s\n", q.DEST);
        }
        else if(q.OP == Af)
        {
            ENV e2 = rech(q.ARG2, environnement);
            ENV e1 = rech(q.ARG1, environnement);

            if(e2 == NULL)
            {
                e2 = Envalloc();
                initenv(e2, 0);
                envFin.SUIV = e2;
                envFin = e2;

                if(current == sizeofvars)
                {
                    vars = realloc(vars, 2*sizeofvars *sizeof(char*));
                    sizeofvars*= 2;
                }

                vars[current++] = q.ARG2 + "\t\t: .long 0";
            }
            if(e1 != NULL)
            {
                printf("%s\t\t:mrmovl\t%%eax,\t(%s)\n", q.ETIQ ,q.ARG1);
                printf("\t\trmmovl\t%%eax,\t0(%s)\n", q.ARG2);
            }
        }
        else if(q.OP == Afc)
        {
            ENV e = rech(q.DEST, environnement);
            if(e == NULL)
            {
                e = Envalloc();
                initenv(e, 0);
                envFin.SUIV = e;
                envFin = e;

                if(current == sizeofvars)
                {
                    vars = realloc(vars, 2*sizeofvars *sizeof(char*));
                    sizeofvars*= 2;
                }

                vars[current++] = q.DEST + "\t\t: .long " + q.ARG1;
            }
            else
            {
                printf("%s\t\t:irmovl\t%s,\t%%eax\n", q.ETIQ, q.ARG1);
                printf("\t\trmmovl\t%%eax,\t0(%s)\n", q.DEST);
            }
        }
        else if(q.OP == Pl || q.OP == Mu || q.OP == Mo)
        {
            ENV e = rech(q.DEST, environnement);
            if(e == NULL)
            {
                e = Envalloc();
                envFin.SUIV = e;
                envFin = e;
                initenv(e, eval(q.OP, atoi(q.ARG1), atoi(q.ARG2)));

                if(current == sizeofvars)
                {
                    vars = realloc(vars, 2*sizeofvars *sizeof(char*));
                    sizeofvars*= 2;
                }

                vars[current++] = q.ARG2 + "\t\t: .long " + e->VAL;
            }
            e->VAl = eval(q->OP, atoi(q->ARG1), atoi(q->ARG2);
            printf("%s\t\t:irmovl\t%s,\t%%eax\n", q.ETIQ, q.ARG1);
            printf("\t\tirmovl\t%s,\t%%ebx\n", q.ARG2);
            if(q.OP == pl)
            {
                printf("\t\taddl\t%%eax,\t%%ebx\n");
            }
            else if(q.op == Mo)
            {
                printf("\t\tsubl\t%%eax,\t%%ebx\n");
            }
            else
            {

            }
            printf("\t\trmmovl\t%%ebx,\t0(%s)\n", q.DEST);
        }
        else if(q.OP == Sk)
        {
            printf("%s\t\t:nop\n", q.ETIQ);
        }

        q = q.SUIV;
    \n}


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
        printf("%s\n", vars[i]);
    }
    printf("Data\t\t:\n");
    printf("           .align 8");

    free(vars);
    free(etiquette);
    free(dest);
    free(arg1);
    free(arg2);
    return 0;
}


        rmmovl %eax, eti

eti     : .long 5
