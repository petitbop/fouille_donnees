CC=gcc
CFLAGS=-W -Wall -lm
LDFLAGS=
EXEC=scindeur 

all: $(EXEC)

scindeur: scindeur.o 
	$(CC) scindeur.o -o $(EXEC) 
	
scindeur.o: scindeur.c scindeur.h
	$(CC) -c $(CFLAGS) scindeur.c 

clean:
	rm -rf *.o

mrproper: clean
	rm -rf $(EXEC)
