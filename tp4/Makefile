CC=gcc
CFLAGS=-W -Wall 
LDFLAGS=
EXEC=scindeur lirefichier

all: $(EXEC)

scindeur.o: scindeur.c
	$(CC) -o $@ -c $< $(CFLAGS)

lirefichier.o: lirefichier.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -rf *.o

mrproper: clean
	rm -rf $(EXEC)
