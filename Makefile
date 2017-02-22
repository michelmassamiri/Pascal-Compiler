SRC = $(wildcard *.c)
FLEX = $(wildcard *.l)
OBJS = $(SRC:.c=.o)
OBJET = $(FLEX:.l=.o)
PRJ = exo

.PHONY : clean

all : $(OBJET) $(OBJS)
	$(CC) $(OBJET) $(OBJS) -o $(PRJ)
	rm $(OBJS) $(OBJET)


l :
	make all
	./exo


clean :
	rm $(PRJ)
