/* la référence de ce code est le site web suivant : http://epaperpress.com/lexandyacc/calcy.html */

#ifndef ENVIRON_IMP_H
#define ENVIRON_IMP_H


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

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

extern char* sym[128];

extern int yyerror(char* s);
nodeType* con(int value);
nodeType* id(char* v);
nodeType* opr(int oper, int nops, ...);

#endif
