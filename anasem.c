/* anasem.c */
#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre.h"
#include "ppascal.tab.h"
/*------------------FONCTIONS ---------------------------------------------------*/
/*------------------types--------------------------------------------------------*/

void typ_error(char *mess,int ligne)
{
  fprintf(stderr, "TYPERROR: %s: ligne %d \n", mess, ligne);
  return;
}

/* renvoie le type de e : TYPEF \in T_int, T_boo, T_com, T_err, T_bot          */
/* affecte ce type a la racine                                                 */
/* suppose corrects les types des fils                                         */
/* envoie message d'erreur si mal type a la racine et fils bien types          */
/* renvoie T_err si l'arbre est mal-type                                       */
type calcul_type(BILENVTY rho_gb, ENTFON ent_fon, BILENVTY varloc, nodeType* e, int ligne)
{
  type tp;
  tp= creer_type(0,T_bot);/* type par defaut */
  if(e != NULL)
  {
    ENVTY pos, pos_param, pos_varloc;
    pos = NULL ;
    pos_param = NULL ;
    pos_varloc = NULL ;

    type tint, tboo, tcom ;
    type tbot, tthen;
    type tfg,tfd;                /* type  du fils gauche, fils droit */
    type terr=creer_type(0,T_err);   /* type  erreur                 */
    /* un des noeuds est mal-type */
    if(e->type == typeOpr && e->opr.oper != Not) {
      if ((e->opr.op[0] && type_eq(get_type(e->opr.op[0]->o_type),terr)) || (e->opr.op[1] && type_eq(get_type(e->opr.op[1]->o_type), terr)) || (e->opr.op[2] && type_eq(get_type(e->opr.op[2]->o_type), terr)))
      {
        type_copy(&tp,terr);/* valeur du  type                              */
        type_copy(e->o_type, terr); /* affecte type  erreur                */
        return(tp);
      }
    }

    switch (e->type) {
      case typeCon:
          tp = get_type(e->o_type);
          return tp;

      case typeId:
          pos = rechty(e->id.v, rho_gb.debut);

          if(ent_fon != NULL)
            pos_param = rechty(e->id.v, ent_fon->PARAM.debut);

          if(varloc.debut != NULL && varloc.fin != NULL)
            pos_varloc = rechty(e->id.v, varloc.debut);

          /* pos var dans rho (environnement global) */
          if (pos!=NULL)
          {
            type_copy(&tp, pos->TYPE);        /* valeur du  type := rho(var)      */
            type_copy((e->o_type), pos->TYPE);/* affecte le type                  */
            return tp;
          }
          /* variable trouve dans la liste de parametres */
          else if (pos_param != NULL)
          {
            type_copy(&tp, pos_param->TYPE);
            type_copy(e->o_type, pos_param->TYPE);
            return tp;
          }
          /* variable trouve dans la liste de variable locales de la fonction */
          else if(pos_varloc != NULL)
          {
            type_copy(&tp, pos_varloc->TYPE);
            type_copy(e->o_type, pos_varloc->TYPE);
            return tp;
          }
          else
          {
            type_copy(&tp, terr);       /* tp := erreur                             */
            type_copy(e->o_type,tp); /* affecte type                             */
            typ_error("variable inconnue ",ligne);/* message erreur                */
          }
          return(tp);                           /* renvoie le type                  */

      case typeOpr:
          switch (e->opr.oper) {
            case Ind:
                tint=creer_type(0,T_int);
                tfg=get_type(e->opr.op[0]->o_type);/* type  des fils  */
                tfd=get_type(e->opr.op[1]->o_type);
                if ((tfg.DIM > 0) && type_eq(tfd,tint))
                {
                  type_copy(&tp,tfg);                 /* type  du tableau fils gauche    */
                  (tp.DIM)--;              /* calcule le type */
                  type_copy(e->o_type, tp); /* affecte le type */
                }
                else if (tfg.DIM == 0)
                {
                  type_copy(&tp,terr);     /* calcule le type */
                  type_copy(e->o_type, tp); /* affecte le type */
                  typ_error("index dans un tab de dim 0",ligne);   /* envoi message erreur*/
                }
                else
                {
                  type_copy(&tp, terr);    /* calcule le type */
                  type_copy(e->o_type,tp); /* affecte le type */
                  typ_error("index non entier dans un tableau",ligne);/*env message erreur*/
                };
                return(tp);

            case Pl: case Mo: case Mu:
                tint=creer_type(0,T_int);
                tfg=get_type(e->opr.op[0]->o_type);
                tfd=get_type(e->opr.op[1]->o_type);
                if (type_eq(tfg,tint) && type_eq(tfd,tint))
                {
                  type_copy(&tp,tfg);        /* calcule le type */
                  type_copy((e->o_type),tfg);/* affecte le type */
                }
                else
                {
                  type_copy(&tp,terr);/* calcule le type                               */
                  type_copy((e->o_type),terr); /* affecte type                         */
                  typ_error("op entier sur args non-entiers",ligne);/* message erreur  */
                }
                return(tp);

            case Lt: case Eq:
                tint=creer_type(0,T_int);
                tboo=creer_type(0,T_boo);
                tfg=get_type(e->opr.op[0]->o_type);
                tfd=get_type(e->opr.op[1]->o_type);
                if (type_eq(tfg,tint) && type_eq(tfd,tint))
                {
                  type_copy(&tp,tboo);         /* valeur du  type */
                  type_copy((e->o_type),tboo); /* affecte le type */
                }
                else
                {
                  type_copy(&tp,terr);/* valeur du  type                               */
                  type_copy((e->o_type),terr); /* affecte type                         */
                  typ_error("op de comparaison sur args non-entiers",ligne);/* message */
                }
                return(tp);
            case And: case Or:
                tboo=creer_type(0,T_boo);
                tfg=get_type(e->opr.op[0]->o_type);
                tfd=get_type(e->opr.op[1]->o_type);
                if (type_eq(tfg,tboo) && type_eq(tfd,tboo))
                {
                  type_copy(&tp,tboo);         /* valeur du  type */
                  type_copy((e->o_type),tboo); /* affecte le type */
                }
                else
                {
                  type_copy(&tp,terr);/* valeur du  type                              */
                  type_copy((e->o_type),terr); /* affecte type                        */
                  typ_error("op booleen sur args non-booleens",ligne);/*message erreur*/
                }
                return(tp);

            case Not:
                tboo=creer_type(0,T_boo);
                tfg=get_type(e->opr.op[0]->o_type);
                if (type_eq(tfg,tboo))
                {
                  type_copy(&tp,tboo);         /* valeur du  type */
                  type_copy((e->o_type),tboo); /* affecte le type */
                }
                else
                {
                  type_copy((e->o_type),terr); /* affecte type                         */
                  type_copy(&tp,terr);/* valeur du  type                               */
                  typ_error("op booleen sur arg non-booleen",ligne);/* message erreur  */
                }
                return(tp);

            case NewAr:
                type_copy(&tp, get_type(e->o_type));
                return(tp);

            case Af:

                if (type_eq(get_type(e->opr.op[0]->o_type), get_type(e->opr.op[1]->o_type))==0)/* type(lhs) <> type(rhs)    */
                {
                  type_copy((e->o_type),terr); /* affecte type                        */
                  typ_error("affectation de types incoherents ", ligne);
                  return(terr);
                }
                else
                {
                  tcom = creer_type(0, T_com);                                  /* type(lhs) == type(rhs)      */
                  type_copy((e->o_type), tcom);
                  return(tp);
                }

            case Se:
                tcom= creer_type(0,T_com);         /* type  commande               */
                type_copy((e->o_type),tcom);
                type_copy(&tp,tcom);
                return(tp);

            case If:
                tcom = creer_type(0,T_com);         /* type  commande               */
                tboo = creer_type(0,T_boo);          /* type  booleen                */
                tfg = get_type(e->opr.op[0]->o_type);                       /* type  des  3 fils            */
                tthen = get_type(e->opr.op[1]->o_type);


                if (type_eq(tfg,tboo)==0)              /* type arg0  <> booleen         */
                {
                  type_copy((e->o_type),terr);        /* affecte type                  */
                  type_copy(&tp,terr);
                  typ_error("condition non booleenne dans un IfThEl", ligne);
                }

                if(e->opr.op[2] != NULL) {
                   type telse = get_type(e->opr.op[2]->o_type);
                   if(!type_eq(telse, tcom)) {
                     type_copy((e->o_type), terr);                        /* affecte type  */
                     type_copy(&tp,terr);
                   }
                }
                else if (!type_eq(tthen,tcom))  /* arg <> tcom   */
                {
                  type_copy((e->o_type),terr);                        /* affecte type  */
                  type_copy(&tp,terr);
                }
                else
                {
                  type_copy((e->o_type),tcom);                         /* affecte type */
                  type_copy(&tp,tcom);
                }
                return(tp);

            case Wh:
                tcom = creer_type(0, T_com);
                tboo = creer_type(0, T_boo);
                tfg = get_type(e->opr.op[0]->o_type);
                tfd = get_type(e->opr.op[1]->o_type);
                if(type_eq(tfg, tboo) == 0) {
                  type_copy((e->o_type), terr);
                  type_copy(&tp, terr);
                  typ_error("condition non booleenne dans un While", ligne);
                }
                else {
                  type_copy((e->o_type), tcom);
                  type_copy(&tp, tcom);
                }
                return tp;

            default: return tp;
          } /* Fin switch operator */
      default: return tp;
    } /* Fin switch principal */

  }/* fin if (e!=NULL)         */
  else
    return(tp);                                     /* e==NULL, arbre vide, type T_bot */
}
