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
    int i;                      /* subscript to sym array */
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

extern int sym[26];

#endif
