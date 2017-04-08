
#ifndef ARBRE_H
#define ARBRE_H

/* type: tableau */
typedef struct {
  int DIM;   /* dimension ; vaut 0 ssi type de base                           */
  int TYPEF; /* type des cellules de plus petite dim: T_int ou T_boo ou T_com */
}type;

/* environnement_type := liste de var ou param (identificateur, type, valeur)  */
typedef struct cellenvty{
  char *ID;
  type TYPE;
  int  VAL;
  struct cellenvty *SUIV;} *ENVTY;

/* biliste de var ou param */
typedef struct{
  ENVTY debut;
  ENVTY fin;}BILENVTY;

typedef enum {
  typeCon,
  typeId,
  typeOpr
} nodeEnum ;

/* constants (Numbers) */
typedef struct {
    int value;                  /* value of constant */
} conNodeType;

/* identifiers (Variables) */
typedef struct {
    char* v;                      /* string that will be added to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];  /* operands, extended at runtime */
} oprNodeType;

/* Tree node */
typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node  : I, V, operator */

    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };

    type o_type ;               /* type of the non-terminal or terminal like : integer, boolean, ... */
} nodeType;


extern int yyerror(char* s);
nodeType* con(int value, type type_con);
nodeType* id(char* v, type type_id);
nodeType* opr(int oper, int nops, type type_opr, ...);

/*------------------FONCTIONS ---------------------------------------------------*/

/*---------------------allocation memoire----------------------------------------*/
extern char *Idalloc();      /* retourne un tableau de MAXIDENT char             */
extern ENVTY Envtalloc();    /* retourne un ENVTY                                */
extern type *talloc();       /* retourne un pointeur sur type *                  */
/*---------------------------------arbres----------------------------------------*/

/*---------------------environnements--------------------------------------------*/
extern int  type_eq(type t1, type t2);/* 1 si t1 ==t2 , 0 sinon                  */
extern void type_copy(type *tcop, type torig);/* copie torig vers tcop           */
extern void type_affect(ENVTY rho, type tvar);/* affecte le type  de   *rho      */
extern type creer_type(int dm, int tf);/* retourne le type                       */
extern type type_res_op(int op);/* retourne le type resultat de op               */
extern ENVTY creer_envty(char *etiq, type tau,int val);/*pointe vers cette var typee*/
extern ENVTY copier_envty(ENVTY env);/*pointe vers une copie                     */
extern char *nomop(int codop);/* traduit entier vers chaine (= nom operation)    */
extern void ecrire_type(type tp);      /* ecrit le type                          */
extern int ecrire_envty(ENVTY rho);/* affiche l'environnement type               */
extern ENVTY rechty(char *chaine, ENVTY listident);/* retourne la position de chaine*/
/* retourne la position de chaine */
extern int affectty(ENVTY rho, char *var, type tpvar, int val);/*   affecte var  */
extern int valchty(ENVTY rho, char *var); /* valeur de var dans envirnt-type rho */
/*---------------------bilistes-de-var-typees------------------------------------*/
extern void inbilenvty(BILENVTY *prho,char *var,type tvar);   /* initialise var  */
extern BILENVTY bilenvty_vide() ;                  /* retourne une biliste vide  */
extern BILENVTY creer_bilenvty(ENVTY varty);/* retourne une biliste a un element */
extern BILENVTY copier_bilenvty(BILENVTY bty);/*pointe vers copie                */
extern BILENVTY concatty(BILENVTY bty1, BILENVTY bty2);/* retourne la concatenation*/
extern void ecrire_bilenvty(BILENVTY bty); /* affiche la biliste de quadruplets  */
/*---------------------programmes -----------------------------------------------*/
void ecrire_prog(BILENVTY argby,nodeType* argno);             /* affiche le programme  */
/* --------------------CONSTANTES -----------------------------------------------*/
#define MAXIDENT 16          /* long max d'un identificateur de variable         */
/*---------------------VARIABLES globales ---------------------------------------*/
//extern NOE syntree;          /* arbre syntaxique  (y.tab.c)                      */
#endif
