#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre.h"
#include "ppascal.tab.h"
#include "interp.h"
#include "anasem.h"

/*-------------------------------------------------------------------*/
/* ----------------------------types---------------------------------*/
/*  nodeType*,ENVTY,BILENVTY  : definis dans arbre.h                       */
/*-------------------------------------------------------------------*/


/* ------------------VARIABLES GLOBALES ------------------------------*/
/* le tas; (NIL=0); "vraies" adresses >=1                             */
int TAS[TAILLEMEM];
/* ADR[i]=adresse dans le tas du tab i                                */
int ADR[TAILLEADR];
/* TAL[i]=taille du tab i                                             */
int TAL[TAILLEADR];
int ptasl=1; /* premiere place libre dans TAS[]                       */
int padrl=1; /* premiere place libre dans ADR[]                       */
/*--------------------------------------------------------------------*/
/* ----------------------traitement--memoire--------------------------*/
void init_memoire()
{int i=0;
while (i < TAILLEMEM)
  TAS[i++]=0;
i=0;
while (i < TAILLEADR)
  {ADR[i++]=0;
   TAL[i]=0;
  }
}
/* decrit la memoire: */
/* ADR[i]: adresse du tableau i dans le TAS */
/* TAL[i]: taille du tableau i; de ADR[i] a ADR[i] + TAL[i] */
/* TAS: tableau (statique) contenant tous les tableaux (dynamiques) */
void ecrire_memoire(int maxadr, int maxtal, int maxtas)
{int i;
 printf("Le tableau ADR:\n");
 printf("------------------------:\n");
 for(i=0; i < maxadr;i++)
   printf("%d:",ADR[i]);
 printf("\n");
 printf("Le tableau TAL:\n");
 printf("------------------------:\n");
 for(i=0; i < maxadr;i++)
   printf("%d:",TAL[i]);
 printf("\n");
 printf("Le tableau TAS:\n");
 printf("------------------------:\n");
 for(i=0; i < maxtas;i++)
   printf("%d:",TAS[i]);
 printf("\n");
 return;
}
/*--------------------------------------------------------------------*/
/*---------------semantique-------------------------------------------*/
/* N.B.allocation dynamique de tableaux; mais pas de ramasse-miettes! */

static int interpreter_recursive(BILENVTY benvty, BILFON bfon, nodeType* n) {
  if(n == NULL)
    return 0;

  if(n->type == typeCon)
    return n->con.value;

  if(n->type == typeId){
    ENVTY pos = rechty(n->id.v, benvty.debut);
    if(pos == NULL) {
      BILENVTY all_vars = allvars(bfon);
      pos = rechty(n->id.v, all_vars.debut);
    }

    return pos->VAL;
  }

  if(n->type == typeOpr) {
    char *lhs; int rhs;
    int res, taille ;

    switch(n->opr.oper) {
      case Mp : interpreter_recursive(benvty, bfon, n->opr.op[0]); break;
      case Wh :
                while(interpreter_recursive(benvty, bfon, n->opr.op[0])) interpreter_recursive(benvty, bfon, n->opr.op[1]); return 0;
      case If :
                if(n->opr.op[2] != NULL) {
                    if(interpreter_recursive(benvty, bfon, n->opr.op[0])) interpreter_recursive(benvty, bfon, n->opr.op[1]);
                    else {
                       interpreter_recursive(benvty, bfon, n->opr.op[2]);
                    }
                }
                else {
                  if(interpreter_recursive(benvty, bfon, n->opr.op[0])) interpreter_recursive(benvty, bfon, n->opr.op[1]);
                }
                return 0;
      case Sk :
                return 0 ;
      case Se :
                interpreter_recursive(benvty, bfon, n->opr.op[0]) ; interpreter_recursive(benvty, bfon, n->opr.op[1]); return 0;
      case Pl :
                return interpreter_recursive(benvty, bfon, n->opr.op[0]) + interpreter_recursive(benvty, bfon, n->opr.op[1]);
      case Mo :
                return interpreter_recursive(benvty, bfon, n->opr.op[0]) - interpreter_recursive(benvty, bfon, n->opr.op[1]);
      case Mu :
                return interpreter_recursive(benvty, bfon, n->opr.op[0]) * interpreter_recursive(benvty, bfon, n->opr.op[1]);
      case And :
                return interpreter_recursive(benvty, bfon, n->opr.op[0]) && interpreter_recursive(benvty, bfon, n->opr.op[1]);
      case Or :
                return interpreter_recursive(benvty, bfon, n->opr.op[0]) || interpreter_recursive(benvty, bfon, n->opr.op[1]);
      case Lt :
                return (interpreter_recursive(benvty, bfon, n->opr.op[0]) < interpreter_recursive(benvty, bfon, n->opr.op[1])) ;
      case Eq :
                return (interpreter_recursive(benvty, bfon, n->opr.op[0]) == interpreter_recursive(benvty, bfon, n->opr.op[1]));
      case Not :
                return !(interpreter_recursive(benvty, bfon, n->opr.op[0]));
      case Ind :
                {
                  int tab = interpreter_recursive(benvty, bfon, n->opr.op[0]);        /* adresse du tableau    */
             	    int ind = interpreter_recursive(benvty, bfon, n->opr.op[1]);         /* index dans le tableau */
             	    return(TAS[ADR[tab]+ind]);
                }
      case NewAr:  /* creation tableau                */
            	  {
                  taille = interpreter_recursive(benvty ,bfon, n->opr.op[0]); /* taille du tableau */
            	    res = padrl;
            	    ADR[res] = ptasl;
            	    TAL[res] = taille;
            	    padrl++;ptasl+=taille; /* mise a jour allocateur  memoire              */
            	    return(res);
            	  }
      case Af :
                if (n->opr.op[0]->type == typeId)        /* affectation a une variable */
                {
                  lhs = n->opr.op[0]->id.v;
                  printf("lhs vaut %s \n",lhs);
                  rhs = interpreter_recursive(benvty, bfon, n->opr.op[1]);
                  printf("rhs vaut %d \n",rhs);
                  affectb(benvty, bfon, lhs, rhs);
                }
                else
                {
                  nodeType* FG = n->opr.op[0];
                  if(FG->type == typeOpr) {
                    assert(FG->opr.oper == Ind);      /* affectation a un tableau */
                    int tabl= interpreter_recursive(benvty, bfon, FG->opr.op[0]);
                    int index=interpreter_recursive(benvty, bfon, FG->opr.op[1]);
                    rhs = interpreter_recursive(benvty, bfon, n->opr.op[1]);
                    TAS[ADR[tabl]+index]=rhs;
                    /*TODO: tester que index < taille */
                  }
                }
                return 0;

      default : break;
    }
  }
  return 0;
}

int interpreter(BILENVTY benvty, BILFON bfon, nodeType* n) {
  //if(e == NULL)
    //yyerror("error environt e is NULL in interpreter");

  interpreter_recursive(benvty, bfon, n);
  //ecrire_env(e);
  return 0;
}
