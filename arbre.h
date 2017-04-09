
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

/* listefonctions := liste de 4-tuples (ident, BILparametres, BILvarloc, ast) */
typedef struct cellfon{
  char *ID;
  BILENVTY PARAM;    /* pametres formels  */
  BILENVTY VARLOC;   /* variables locales */
  nodeType* CORPS;
  type TYPE;       /* type retour de la fonction */
  struct cellfon *SUIV;} *LFON;

typedef struct entete_fon {
  char* ID;
  BILENVTY PARAM;
  type TYPE;
} *ENTFON;

/* biliste de fonctions */
typedef struct{
  LFON debut;
  LFON fin;}BILFON;


extern int yyerror(char* s);

/*------------------FONCTIONS ---------------------------------------------------*/
extern LFON creer_fon(char *nfon, BILENVTY lparam,BILENVTY lvars,nodeType* com,type tp);
extern LFON creer_proc(char *nproc, BILENVTY lparam,BILENVTY lvars,nodeType* com,type tp);
extern ENTFON creer_entfon(char *nfon, BILENVTY lparam, type tp);
extern ENTFON creer_entproc(char *nproc, BILENVTY lparam, type tp);
/* pointe vers cette fonction */
extern LFON copier_fon(LFON lfn);    /* pointe vers une copie                */
extern void ecrire_fon(LFON bfn);
extern LFON rechfon(char *chaine, LFON listident);/* retourne la position de chaine*/
/*---------------------bilistes-de-fonctions --------------------------------*/
extern BILFON bilfon_vide() ;                  /* retourne une biliste vide  */
extern BILFON creer_bilfon(LFON pfon);  /* retourne une biliste a un element */
extern BILFON copier_bilfon(BILFON bfn);/* pointe vers une copie             */
extern BILFON concatfn(BILFON bfn1, BILFON bfn2);/* retourne la concatenation*/
extern BILENVTY allvars(BILFON bfon);/*les variables de bfon (params puis varloc)*/
extern void ecrire_bilfon(BILFON bfn);   /* affiche la biliste de fonctions  */

/*---------------------allocation memoire----------------------------------------*/
extern char *Idalloc();      /* retourne un tableau de MAXIDENT char             */
extern ENVTY Envtalloc();    /* retourne un ENVTY                                */
extern type *talloc();       /* retourne un pointeur sur type *                  */
extern LFON Lfonalloc();     /* retourne une fonction */
extern ENTFON EntFonalloc(); /* retourne une en-tete de fonction */

/*---------------------------------arbres----------------------------------------*/
nodeType* con(int value, type type_con);
nodeType* id(char* v, type type_id);
nodeType* opr(int oper, int nops, type type_opr, ...);

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
void ecrire_prog(BILENVTY argby,BILFON bilfon,nodeType* argno);             /* affiche le programme  */
/* --------------------CONSTANTES -----------------------------------------------*/
#define MAXIDENT 16          /* long max d'un identificateur de variable         */
/*---------------------VARIABLES globales ---------------------------------------*/
//extern NOE syntree;          /* arbre syntaxique  (y.tab.c)                      */
#endif
