#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>

#include "arbre.h"
#include "ppascal.tab.h"

/*-------------------------------------------------------------------*/
/*--------------------------------arbres-----------------------------*/

/* the constant node constructor */
nodeType *con(int value, type type_con) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;
    p->o_type = type_con ;
    return p;
}

/* the variable node constructor */
nodeType *id(char* v, type type_id) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.v = strdup(v);
    p->o_type = type_id;
    return p;
}

/* the operator node constructor */
nodeType *opr(int oper, int nops, type type_opr, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType*))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    p->o_type = type_opr;

    /* since that opr is a function with an unknown types and arguments, va_list is the proper way to implement such a node */
    va_start(ap, type_opr);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

/* Free the memory  */
void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

/*-------------------------------------------------------------------*/
/* ----------------------------types---------------------------------*/
/*  type, nodetype*,ENVTY,LFON,BILENVTY,BILFON : definis dans arbre.h      */
/*-------------------------------------------------------------------*/
/*---------------------allocation memoire----------------------------*/
char *Idalloc()
{
  return((char *)malloc(MAXIDENT*sizeof(char)));
}

ENVTY Envtalloc()
{
  return((ENVTY)malloc(sizeof(struct cellenvty)));
}
type *talloc()
{
  return((type *)malloc(sizeof(type)));
}

LFON Lfonalloc(){
  return ((LFON)malloc(sizeof(struct cellfon)));
}

ENTFON EntFonalloc(){
  return ((ENTFON)malloc(sizeof(struct entete_fon)));
}

/*-------------------------------------------------------------------*/
/*-----------------------------environnements------------------------*/
/* 1 si t1 ==t2 , 0 sinon                   */
int type_eq(type t1, type t2)
{
  return((t1.DIM==t2.DIM) && (t1.TYPEF==t2.TYPEF));
}

/* copie torig vers *tcop  */
void type_copy(type *tcop,type torig)
{
  tcop->DIM=torig.DIM;
  tcop->TYPEF=torig.TYPEF;
  return;
}

/* affecte le type  de *prho      */
void type_affect(ENVTY rho,type tvar)
{
  (rho->TYPE).DIM=tvar.DIM;
  (rho->TYPE).TYPEF=tvar.TYPEF;
  return;
}

/* retourne le type                  */
type creer_type(int dm, int tf)
{
  type TT;
  TT.DIM=dm;
  TT.TYPEF=tf;
  return(TT);
}

/* retourne le type resultat de op               */
extern type type_res_op(int op)
{
  type t;
  switch(op)
  {
    case True:case False:case And:case Or:case Lt:case Eq:case Not:
      t=creer_type(0,T_boo);
    break;
    case Pl:case Mo:case Mu:
      t=creer_type(0,T_int);
    break;
    default:
    break;
  }
  return(t);
}

/* pointe vers cette var typee */
ENVTY creer_envty(char *etiq, type tau, int val)
{
  ENVTY ety;
  ety= Envtalloc();
  if (etiq !=NULL)
    {
      ety->ID=Idalloc();
      strcpy(ety->ID,etiq);
    }
  ety->TYPE=tau;
  ety->VAL=val;
  ety->SUIV=NULL;
  return(ety);
}

/* pointe vers copie  */
ENVTY copier_envty(ENVTY env)
{
  ENVTY ety = NULL;
  if (env != NULL)
  {
    ety= Envtalloc();
    if (env->ID!=NULL)
    {
      ety->ID=Idalloc();
      strcpy(ety->ID,env->ID);
     }
    type_copy(&(ety->TYPE),env->TYPE);
    ety->VAL=env->VAL;
    ety->SUIV= copier_envty(env->SUIV);
  }

  return(ety);
}


/* retourne l'adresse de la cellule contenant chaine. NULL si la chaine est absente */
ENVTY rechty(char *chaine, ENVTY listident)
{
  if (listident!=NULL)
    {
      if (strcmp(listident->ID,chaine)==0)
        {
          return listident;
        }
      else
	     return rechty(chaine,listident->SUIV);
    }
  else
    return NULL;
}


/* affecte val a la variable var, dans rho */
/* NB: le type n'est pas utilise           */
int affectty(ENVTY rho, char *var, type tpvar, int val)
{
  ENVTY pos;
  pos=rechty(var,rho);/* adresse de la cellule contenant var */
  printf("ancienne valeur vaut %d \n",pos->VAL);
  if (pos != NULL)
    {
      (pos->VAL)=val;
      (pos->TYPE)=tpvar;
      return(EXIT_SUCCESS);
    }
  else
    return(EXIT_FAILURE);
}

/* traduit entier (= codop) vers chaine (= nom operation)  */
/* utile pour les fonctions d'ecriture */
char *nomop(int codop)
{
  switch(codop)
    {
      case(I):return("I");
      case(V):return("V");
      //case(MP): return("Mp");
      case(Af): return("Af");
      case(Sk): return("Sk");
      case(NewAr): return("New_array_of ");
      case(T_ar): return("array_of ");
      case(T_int): return("integer");
      case(T_boo): return("boolean");
      case(T_com): return("commande");
      case(T_bot): return("typ_indefini");
      case(T_err): return("typ_erreur");
      case(True): return("true");
      case(False):return("false");
      case(Se): return("Se");
      case(Ind): return("Ind");
      case(If): return("If");
      case(Th): return("Th");
      case(El): return("El");
      case(Wh): return("Wh");
      case(Do): return("Do");
      case(Pl): return("Pl");
      case(Mo): return("Mo");
      case(Mu): return("Mu");
      case(And):return("And");
      case(Or): return("Or");
      case(Not): return("Not");
      case(Lt): return("<");
      case(Eq): return("=");
      case(0): return("");                   /* code 0: directive assembleur y86 */
      default: return(NULL);
    };
}

/* ecrit le type */
void ecrire_type(type tp)
{
  printf("DIM:%d,TYPEF:%d",tp.DIM,tp.TYPEF);
}

/* affiche l'environnement type      */
int ecrire_envty(ENVTY rho)
{
  if (rho==NULL)
    {
      printf("fin d'environnement \n");
      return(EXIT_SUCCESS);
    }
  else
    {
      printf("variable %s ",rho->ID);
      ecrire_type(rho->TYPE);
      printf("valeur %d \n",rho->VAL);
      ecrire_envty(rho->SUIV);
      return(EXIT_SUCCESS);
    };
}

/* valeur de var dans rho  (UTILISEE ??)                     */
/* NB: la valeur d'un tableau est un index du tas            */
int valchty(ENVTY rho, char *var)
{
  ENVTY pos;
  pos=rechty(var,rho);/* adresse de la cellule contenant var */
  if (pos != NULL)
    return(pos->VAL);
  else
    return(0);
}

/* initialise var dans *prho */
/* le couple  (var,tvar)  est copie dans l'environnement */
void inbilenvty(BILENVTY *prho,char *var,type tvar)
{
  ENVTY erho, pos, newcell;
  erho=prho->debut;
  pos=rechty(var,erho);/* adresse de la cellule contenant var */
  if (pos == NULL)
    /*on insere var en tete de envrnt*/
    {
      newcell=Envtalloc();
      newcell->ID=Idalloc();
      strcpy(newcell->ID,var);
      /* newcell->VAL=intalloc(); */
      newcell->VAL=0;
      type_affect(newcell,tvar);
      newcell->SUIV=erho;
      prho->debut=newcell;
    }
  return;
}

/* retourne une biliste vide  */
BILENVTY bilenvty_vide()
{
  BILENVTY bty;
  bty.debut=NULL;bty.fin=NULL;
  return(bty);
}

/* retourne une biliste a un element */
BILENVTY creer_bilenvty(ENVTY varty)
{
  BILENVTY bty;
  bty.debut=varty;bty.fin=varty;
  return(bty);
}

/* pointe vers copie      */
BILENVTY copier_bilenvty(BILENVTY bty)
{
  ENVTY aty,ctycour; BILENVTY bcty;
  aty=copier_envty(bty.debut);
  bcty.debut=aty;
  ctycour=aty;
  while(ctycour && ctycour->SUIV)
      ctycour=ctycour->SUIV;
  bcty.fin=ctycour;
  return(bcty);
}

/* retourne la concatenation                       */
/* copie les deux arguments: pas de factorisation  */
BILENVTY concatty(BILENVTY bty1, BILENVTY bty2)
{
  BILENVTY bty,nbty1,nbty2;
  nbty1=copier_bilenvty(bty1);
  nbty2=copier_bilenvty(bty2);
  if (nbty1.fin!= NULL)
    if (nbty2.debut!=NULL)
       {
          nbty1.fin->SUIV=nbty2.debut;
          bty.debut=nbty1.debut;
          bty.fin=nbty2.fin;
          return(bty);
        }
    else
      return(nbty1);
  else
    return(nbty2);
}

/* affiche la biliste de variables typees */
void ecrire_bilenvty(BILENVTY bty)
{
  ecrire_envty(bty.debut);
}

/* affecte  la valeur rhs a la variable lhs */
void affectb(BILENVTY rho_gb, char *lhs, int rhs)
{
    ENVTY pos;
    pos=rechty(lhs,rho_gb.debut);
    if (pos!=NULL)
       pos->VAL=rhs;                   /* lhs est une var enregistree           */
    else
        printf("erreur: variable %s non declaree", lhs);
}

/* ajoute la variable typee (nomvar,tp) dans rho,en prem position, rho est modifie*/
extern void ajout_var(BILENVTY rho, char *nomvar, type tp)
{
  ENVTY vty=creer_envty(nomvar,tp,0);
  BILENVTY bvty=creer_bilenvty(vty);
  rho= concatty(bvty,rho);
  return;
}

/*-------------------------------------------------------------------------------*/
/*---------------------fonctions -----------------------------------------------*/

/* pointe vers cette fonction */
extern LFON creer_fon(char *nfon, BILENVTY lparam,BILENVTY lvars,nodeType* com,type tp){
  LFON res=Lfonalloc();
    if (nfon !=NULL)
      {
        res->ID=Idalloc();
        strcpy(res->ID,nfon);
      }
    res->PARAM=lparam;
    res->VARLOC=lvars;
    res->CORPS=com;
    res->TYPE=tp;

    return(res);
}

extern LFON creer_proc(char *nproc, BILENVTY lparam,BILENVTY lvars,nodeType* com, type tp){
  LFON res=Lfonalloc();
    if (nproc !=NULL)
      {
        res->ID=Idalloc();
        strcpy(res->ID,nproc);
      }
    res->PARAM=lparam;
    res->VARLOC=lvars;
    res->CORPS=com;
    res->TYPE = tp;

    return(res);
}

extern ENTFON creer_entfon(char *nfon, BILENVTY lparam, type tp) {
  ENTFON res = EntFonalloc();
  if(nfon != NULL) {
    res->ID = Idalloc();
    strcpy(res->ID, nfon);
  }

  res->PARAM = lparam ;
  res->TYPE = tp;

  return res;
}

extern ENTFON creer_entproc(char *nproc, BILENVTY lparam, type tp) {
  ENTFON res = EntFonalloc();
  if(nproc != NULL) {
    res->ID = Idalloc();
    strcpy(res->ID, nproc);
  }

  res->PARAM = lparam ;
  res->TYPE = tp;

  return res;
}

/* pointe vers une copie */
extern LFON copier_fon(LFON lfn){
  LFON lfon = NULL;
  if(lfn != NULL)
  {
    lfon = Lfonalloc();
    if(lfn->ID!=NULL)
    {
      lfon->ID=Idalloc();
      strcpy(lfon->ID,lfn->ID);
    }
    lfon->PARAM=copier_bilenvty(lfn->PARAM);
    lfon->VARLOC=copier_bilenvty(lfn->VARLOC);
    lfon->CORPS=lfn->CORPS;
    type_copy(&(lfon->TYPE), lfn->TYPE);
    lfon->SUIV=copier_fon(lfn->SUIV);
  }
  return(lfon);
}

/* affiche une fonction */
extern void ecrire_fon(LFON bfn){
  if (bfn==NULL)
      printf("fin de la biliste de fonction \n");
  else{
    printf("variable %s ",bfn->ID);
    ecrire_bilenvty(bfn->PARAM);
    ecrire_bilenvty(bfn->VARLOC);
    //prefix(bfn->NOE);
    ecrire_type(bfn->TYPE);
    ecrire_fon(bfn->SUIV);
  }
}

/* retourne la position de chaine*/
extern LFON rechfon(char *chaine, LFON listident){
  if(listident != NULL){
    if(strcmp(listident->ID,chaine)==0)
    {
      return listident;
    }
    else{
      return rechfon(chaine,listident->SUIV);
    }
  }
  else
    return NULL;
}

/*-------------------------------------------------------------------------------*/
/*---------------------bilistes-de-fonctions --------------------------------*/

/* retourne une biliste de fonction vide  */
extern BILFON bilfon_vide(){
  BILFON bfn;
  bfn.debut=NULL;
  bfn.fin=NULL;
  return(bfn);
}

/* retourne une biliste a un element */
extern BILFON creer_bilfon(LFON pfon){
  BILFON bfn;
  bfn.debut=pfon;
  bfn.fin=pfon;
  return(bfn);
}

 /* pointe vers une copie             */
extern BILFON copier_bilfon(BILFON bfn){
  LFON debutlfon, finlfon;
  BILFON cbfn;
  debutlfon=copier_fon(bfn.debut);
  cbfn.debut=debutlfon;
  finlfon=debutlfon;
  while(finlfon && finlfon->SUIV)
    finlfon=finlfon->SUIV;
  cbfn.fin=finlfon;
  return(cbfn);
}

/* retourne la concatenation*/
extern BILFON concatfn(BILFON bfn1, BILFON bfn2){
  BILFON bfn, nbfn1, nbfn2;
  nbfn1 = copier_bilfon(bfn1);
  nbfn2 = copier_bilfon(bfn2);
  if(nbfn1.fin != NULL){
    if(nbfn2.debut != NULL){
      nbfn1.fin->SUIV=nbfn2.debut;
      bfn.debut=nbfn1.debut;
      bfn.fin=nbfn2.fin;
      return(bfn);
    }
    else
      return (nbfn1);
  }
  else
    return (nbfn2);
}

/* les variables de bfon (params puis varloc)*/
extern BILENVTY allvars(BILFON bfon){
  BILENVTY benvty, paramEnvty, varLocal;
  LFON current = copier_fon(bfon.debut);
  paramEnvty = copier_bilenvty(current->PARAM);
  varLocal = copier_bilenvty(current->VARLOC);

  current = current->SUIV;
  while(current != NULL) {
      paramEnvty = concatty(paramEnvty, current->PARAM);
      varLocal = concatty(varLocal, current->VARLOC);
      current = current->SUIV;
  }

  benvty = concatty(paramEnvty, varLocal);
  return benvty;
}

/* affiche la biliste de fonctions  */
extern void ecrire_bilfon(BILFON bfn){
  ecrire_fon(bfn.debut);
}


/*-------------------------------------------------------------------------------*/
/*---------------------programmes -----------------------------------------------*/
void ecrire_prog(BILENVTY argby, BILFON bilfon, nodeType* argno)
{
  printf("Les variables globales:\n");
  printf("------------------------:\n");
  ecrire_bilenvty(argby);printf("\n");
  printf("La Listes des fonctions:\n");
  printf("------------------------:\n");
  ecrire_bilfon(bilfon); printf("\n");
  printf("Le programme principal:\n");
  printf("------------------------:\n");
  //prefix(argno);printf("\n");
  return;
}
