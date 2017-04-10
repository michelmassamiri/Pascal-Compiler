#include <stdio.h>
#include "ppascal.tab.h"
#include "environ.h"

static int currentC = 0, current = 0;

void print(int etq, const char *op, const char *arg, const char *buf2, const char *des)
{
    printf("ET%d\t:%s\t:%s\t:%s\t:%s\n", etq, op, arg ? arg : "", buf2 ? buf2 : "", des ? des : "");
}
static int lbJMP = 0;

int ex_bis(ENV *e, nodeType *p)
{
    int lbJMP1, lbJMP2, leftCurrent = 0;
    char buf1[20];
    char buf2[20];
    char buf3[20];
    char dest[20];
    if (!p)
        return 0;
    switch (p->type)
    {
    case typeCon:
    case Afc:
        ex_bis(e, p->opr.op[0]);
        snprintf(buf1f, 20, "%d", p->con.value);
        snprintf(buf1f2, 20, "CT%d", p->opr.op[0]->id.id);
        print(current++, "Afc", buf1, NULL, buf1f2);
        break;
    case typeId:
        snprintf(buf1, 20, "CT%d", ++currentC);
        print(current++, "Af", buf1, p->id.id, NULL);
        break;
    case typeOpr:
        switch (p->opr.oper)
        {
        case Wh:
            snprintf(buf1, 20, "JMP%d", lbJMP1 = lbJMP++);
            printf("%s\t:%s\t:%s\t:%s\t:%s\n", buf1, "Sk", "", "", "");
            ex_bis(e, p->opr.op[0]);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(buf3, 20, "JMP%d", lbJMP2 = lbJMP++);
            print(current++, "Jz", buf2, NULL, buf3);
            ex_bis(e, p->opr.op[1]);
            print(current++, "Jp", NULL, NULL, buf1);
            printf("%s\t:%s\t:%s\t:%s\t:%s\n", buf3, "Sk", "", "", "");

            return 0;
        case If:
            ex_bis(e, p->opr.op[0]);
            snprintf(buf1, 20, "CT%d", currentC);
            snprintf(buf2, 20, "JMP%d", lbJMP1 = lbJMP++);
            print(current++, "Jz", buf1, NULL, buf2);
            ex_bis(e, p->opr.op[1]);
            snprintf(buf3, 20, "JMP%d", lbJMP2 = lbJMP++);
            print(current++, "Jp", NULL, NULL, buf3);
            printf("%s\t:%s\t:%s\t:%s\t:%s\n", buf2, "Sk", "", "", "");
            ex_bis(e, p->opr.op[2]);
            printf("%s\t:%s\t:%s\t:%s\t:%s\n", buf3, "Sk", "", "", "");
            return 0;
        case Af:
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", currentC);
            print(current++, "Af", p->opr.op[0]->id.id, buf1, NULL);
            break;

        case St:
            print(current++, "St", NULL, NULL, NULL);
            break;

        case Sk:
            print(current++, "Sk", NULL, NULL, NULL);
            break;

        case Se:
            ex_bis(e, p->opr.op[0]);
            return ex_bis(e, p->opr.op[1]);

        case And:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "And", buf1, buf2, dest);
            break;

        case Or:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Or", buf1, buf2, dest);
            break;

        case Lt: // Lower than
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Lt", buf1, buf2, dest);
            break;

        case Ind:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Ind", buf1, buf2, dest);
            break;

        case Param:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            print(current++, "Param", buf1, buf2, NULL);
            break;


        case Call:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            print(current++, "Call", buf1, buf2,NULL);
            break;

        case Ret:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            print(current++, "Ret", buf1, buf2, NULL);
            break;
            
        case Pl:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Pl", buf1, buf2, dest);
            break;

        case Mo:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Mo", buf1, buf2, dest);
            break;

        case Mu:
            ex_bis(e, p->opr.op[0]);
            leftCurrent = currentC;
            ex_bis(e, p->opr.op[1]);
            snprintf(buf1, 20, "CT%d", leftCurrent);
            snprintf(buf2, 20, "CT%d", currentC);
            snprintf(dest, 20, "CT%d", ++currentC);
            print(current++, "Mu", buf1, buf2, dest);
            break;
        }
    }
    return 0;
}

int ex(ENV *e, nodeType *p)
{
    int res = ex_bis(e, p);
    print(current++, "St", NULL, NULL, NULL);
    return res;
}
