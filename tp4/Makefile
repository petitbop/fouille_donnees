CC=gcc
CFLAGS=-W -Wall -g
LDFLAGS=-lm
EXEC=scindeur

all: $(EXEC)

scindeur: scindeur.o
	$(CC) -o $@ $< $(LDFLAGS)


scindeur.o: scindeur.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -rf *.o

mrproper: clean
	rm -rf $(EXEC)
