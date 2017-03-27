CC=gcc
YACC = bison
LEX = flex
CFLAGS:= -std=gnu99 -g
LDFLAGS:=
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
	$(CC) $(CFLAGS) -o $@ $^

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

interpPP.yy.c : interpPP.l
			$(LEX) -o $@ $<

interpPP.tab.c interpPP.tab.h : interpPP.y
			$(YACC) -t -v -d $<

interpPP : interpPP.tab.o interpPP.yy.o bilquad.o environ.o
			$(CC) $(CFLAGS) -o $@ $^

clean :
			rm -f *.tab.* *.o *.yy.c $(PROGS) *.output
