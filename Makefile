CC=gcc
YACC = bison
LEX = flex
CFLAGS:= -std=c99 -Wall
LDFLAGS:= -lfl
PROGS = compilerIMP compilerC3A iimp

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

compilerIMP : environ_IMP.o bilquad.o iimp.tab.o iimp.yy.o environ.o iimp.tab.c
						$(CC) $(CFLAGS) -o $@ $^

compilC3A.yy.c : compilC3A.l
								$(LEX) -o $@ $<

compilerC3A : compilC3A.yy.c bilquad.o environ.o
						$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

iimp : compilerIMP compilerC3A iimp.c
					$(CC) $(CFLAGS) -o $@ iimp.c



clean :
			rm -f *.tab.* *.o *.yy.c $(PROGS)
