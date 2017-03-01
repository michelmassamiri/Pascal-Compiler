CC=gcc
CFLAGS:= -std=gnu99
LDFLAGS:= -lfl
SRCS = $(wildcard *.l)
SOURCES = $(wildcard *.c)
OBJ = $(patsubst %.c,%.o,$(SOURCES))
OBJL = interpC3A.o#$(patsubst %.l,%.o,$(SRCS))

PROGS = $(patsubst %.l,%,$(SRCS))

all: $(PROGS)

interC3A : $(OBJ) $(OBJL)
	$(CC) $(CFLAGS) $? -o $@
	rm *.o

%: %.l
	flex -o $@.yy.c $<
	$(CC) $(CFLAGS) -o $@ $@.yy.c $(LDFLAGS)

clean :
	rm *.yy.c $(PROGS) interC3A *.o
