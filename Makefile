CC=gcc
YACC = bison
LEX = flex
CFLAGS:= -std=gnu99 -g
LDFLAGS:= -lm
PROGS = compilerIMP compilerC3A interpC3A interpIMP interpPP

.PHONY : clean

all : $(PROGS)

%.o : %.c %.h
		$(CC) $(CFLAGS) -c -o $@ $<

iimp.tab.c iimp.tab.h : iimp.y
											$(YACC) -t -v -d $<

iimp.yy.c : iimp.l iimp.tab.h
					$(LEX) -o $@ $<

interpC3A.yy.c : interpC3A.l
								$(LEX) -o $@ $<

interpC3A : interpC3A.yy.o bilquad.o environ.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

interpIMP : environ_IMP.o bilquad.o iimp.tab.o iimp.yy.o environ.o
						$(CC) $(CFLAGS) -o $@ $^

compilerIMP : environ_IMP.o bilquad.o iimp.tab.o iimp.yy.o environ.o
						$(CC) $(CFLAGS) -o $@ $^

compilC3A.yy.c : compilC3A.l
								$(LEX) -o $@ $<

compilerC3A : compilC3A.yy.c bilquad.o environ.o
						$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

iimp : compilerIMP compilerC3A iimp.c
					$(CC) $(CFLAGS) -o $@ iimp.c


#interpreter pour le pseudo pascal

#ppascal.tab.c ppascal.tab.h : ppascal.y
			#$(YACC) -t -v -d $<

ppascal.yy.c : ppascal.l ppascal.tab.h
						$(LEX) -o $@ $<

ppascal.tab.c ppascal.tab.h : ppascal.y arbre.h anasem.h
						$(YACC) -t -v -d $<

arbre.o : arbre.c arbre.h ppascal.tab.h
anasem.o : anasem.c anasem.h ppascal.tab.h

interpPP : ppascal.tab.o ppascal.yy.o arbre.o anasem.o
			$(CC) $(CFLAGS) -o $@ $^

rapport : rapport/rapport.tex
		cd rapport/
		pdflatex rapport/rapport.tex
		pdflatex rapport/rapport.tex
		cd ../

clean :
			rm -f *.tab.* *.o *.yy.c $(PROGS) *.output rapport/*.aux rapport/*.log rapport/*.pdf rapport.*
