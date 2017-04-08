%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>

  #include "arbre.h"
  #include "anasem.h"
  // #include "environ.h"

  extern int yyerror(char*);
  extern int yylex();

  int line = 1;          /* Current line */
  nodeType* syntree;     /* Tree node */
  BILENVTY benvty;     /* Global environnement */
  char ident[MAXIDENT]; /* Current ID */
  ENVTY vtycour;        /* Current typed var */
  BILFON bfon;          /* Table de symobole des fonctions */
  LFON ftcour;          /* Fonction actuelle */

%}


%union{
    int iValue; // the value of the constant
    char* id; // the variable string
    nodeType* NODE; // the node type. Ex : I, V, operator
    type TYP; // the expression type of the node. Ex : integer, boolean, Commande...
    BILENVTY LARGT; // the symobole table ;
    LFON FonCel; // La cellule de la fonction
    BILFON FonTable; // La table de symboles des fonctions
};

%start MP
/* tokens definissant des operateurs */
%token Pl Mo Mu Or Lt Eq And Not Af

/* tokens definissant des symboles */
%token Se

/* Token definissant des mots cles */
%token If Th El Wh Do Sk Def Dep NewAr Var T_ar T_com Ind
%token<TYP> T_int T_boo T_err T_bot

/* Token definissant les symboles et chaines utilisateur */
%token<iValue> I True False
%token<NODE> V
%token<id> NFon NPro

/* Les règles pour les tokens */
%nonassoc Th El Eq Lt

%left Pl Mo
%left Mu

/* Definir les non-terminals */
%type<NODE> MP c C E T F Et
%type<TYP> TP
%type<LARGT> Argt L_vart L_vartnn L_argt L_argtnn
%type<FonCel> D_entp D_entf
%type<FonTable> LD D




%%

MP          : L_vart {benvty = $1;} LD C                           { syntree = $4; /* printf("la Syntax est vraie\n") ;*/ YYACCEPT;}
            ;

E           : E Pl T                                               { $$ = opr(Pl, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | E Mo T                                               { $$ = opr(Mo, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | E Mu T                                               { $$ = opr(Mu, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | E Or T                                               { $$ = opr(Or, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | E Lt T                                               { $$ = opr(Lt, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | E Eq T                                               { $$ = opr(Eq, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | T                                                    { $$ = $1; }
            ;

T           : T And F                                              { $$ = opr(And, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | Not F                                                { $$ = opr(Not, 2, creer_type(0, T_bot), $2, NULL); calcul_type(benvty, $$, line); }
            | F                                                    { $$ = $1; }
            ;

F           : '(' E ')'                                            { $$ = $2; }
            | I                                                    { $$ = con($1, creer_type(0, T_int)); }
            | V                                                    { $$ = $1; calcul_type(benvty, $$, line); }
            | True                                                 { $$ = con(1, creer_type(0, T_boo)); }
            | False                                                { $$ = con(0, creer_type(0, T_boo)) ;}
            | V '(' L_args ')'                                     {;}
            | NewAr TP '[' E ']'                                   { $$ = opr(NewAr, 2, $2, $4, NULL); type_copy(&($$->o_type), $2); ($$->o_type).DIM++; }
            | Et                                                   { $$ = $1 ; }
            ;

Et          : V '[' E ']'                                          { $$ = opr(Ind, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $1, line); calcul_type(benvty, $$, line); }
            | Et '[' E ']'                                         { $$ = opr(Ind, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            ;

C           : C Se c                                               { $$ = opr(Se, 2, creer_type(0, T_bot), $1, $3);  calcul_type(benvty, $$, line); }
            | c                                                    { $$ = $1; }
            ;

c           : Et Af E                                              { $$ = opr(Af, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $$, line); }
            | V Af E                                               { $$ = opr(Af, 2, creer_type(0, T_bot), $1, $3); calcul_type(benvty, $1, line); calcul_type(benvty, $$, line);}
            | Sk                                                   { $$ = opr(Sk, 2, creer_type(0, T_com), NULL, NULL); }
            | '{' C '}'                                            { $$ = $2 ; }
            | If E Th C El c                                       { $$ = opr(If, 3, creer_type(0, T_bot), $2, $4, $6); calcul_type(benvty, $$, line); }
            | Wh E Do c                                            { $$ = opr(Wh, 2, creer_type(0, T_bot), $2, $4); calcul_type(benvty, $$, line); }
            | V '(' L_args ')'                                     {;}
            ;

L_args      : %empty                                               {;}
            | L_argsnn                                             {;}
            ;

L_argsnn    : E                                                    {;}
            | E ',' L_argsnn                                       {;}
            ;

L_argt      : %empty                                               { $$ = bilenvty_vide(); }
            | L_argtnn                                             { $$ = $1; }
            ;

L_argtnn    : Argt                                                 { $$ = $1; }
            | L_argtnn ',' Argt                                    { $$ = concatty($1, $3);}
            ;

Argt        : V ':' TP                                            { vtycour=creer_envty($1->id.v, $3, 0); $$ = creer_bilenvty(vtycour);}
            ;

TP          : T_boo                                               { $$ = creer_type(0, T_boo); }
            | T_int                                               { $$ = creer_type(0, T_int); }
            | T_ar TP                                             { type_copy(&($$), $2); $$.DIM++;}
            ;

L_vart      : %empty                                              { $$ = bilenvty_vide(); }
            | L_vartnn                                            { $$ = $1 ;}
            ;

L_vartnn    : Var Argt                                            { $$ = $2 ;}
            | L_vartnn ',' Var Argt                               { $$ = concatty($1,$4); }
            ;

D_entp      : Dep NPro '(' L_argt ')'                             { $$ = creer_entproc($2, $4); }
            ;

D_entf      : Def NFon '(' L_argt ')' ':' TP                      { $$ = creer_entfon($2, $4, $7); }
            ;

D           : D_entp L_vart C                                     { ftcour = creer_proc($1->ID, $1->PARAM, $2, $3); $$ = creer_bilfon(ftcour);}
            | D_entf L_vart C                                     { ftcour = creer_fon($1->ID, $1->PARAM, $2, $3, $1->TYPE); $$ = creer_bilfon(ftcour); }
            ;

LD          : %empty                                              { $$ = bilfon_vide(); }
            | LD D                                                { $$ = concatfn($1, $2); }
            ;

%%

int yyerror(char* s){
  fprintf(stdout, "%s\n", s);
  return 0;
}

int main() {
   yyparse();

   ecrire_prog(benvty, syntree);
   type terr=creer_type(0,T_err);
   type tcom= creer_type(0,T_com);

   if (type_eq(syntree->o_type,terr))
      printf("erreur de typage\n");
   else if (type_eq(syntree->o_type,tcom))
      printf("programme bien type\n");
   else
      printf("attention: typage incomplet\n");

   return 0;
}
