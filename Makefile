CC=gcc
CFLAGS:= -std=gnu99
LDFLAGS:= -lfl
SRCS = $(wildcard *.l)

PROGS = $(patsubst %.l,%,$(SRCS))

all: $(PROGS)

%: %.l
	flex -o $@.yy.c $<
	$(CC) $(CFLAGS) -o $@ $@.yy.c $(LDFLAGS)

clean :
	rm *.yy.c $(PROGS)
