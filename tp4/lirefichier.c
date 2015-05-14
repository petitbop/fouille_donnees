#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main() {
    FILE* fichier = fopen("BaseReuters-29", "r");
    int b, c;
    int fin_de_ligne = 1;
    int fin_de_fichier = 1;
    int fscanf_value;
    int taille_voca = 0;
    int nb_docs[29] = {0};

    fscanf(fichier, "%d", &b);
    while (fin_de_fichier) {
        fin_de_ligne = 1;
        nb_docs[b - 1]++;
        //printf("La categorie est : %d\n", b);
        while (fin_de_ligne) {
            fscanf_value = fscanf(fichier, " %d:%d", &b, &c);
            if (b > taille_voca) taille_voca = b;
            if (fscanf_value == 2) {
                //printf("Le mot %d est present %d fois dans ce document\n", b, c);
            } else if (fscanf_value == -1) {
                fin_de_ligne = 0;
                fin_de_fichier = 0;
            } else {
                fin_de_ligne = 0;
            }
        }
    }
    printf("La taille du vocabulaire est : %d\n", taille_voca);
    int i;
    int somme_verif = 0;
    for (i = 0; i < 29; i++) {
        printf("La classe %d contient %d documents\n", i + 1, nb_docs[i]);
        somme_verif += nb_docs[i];
    }
    assert(somme_verif == 70703);

    fclose(fichier);
    return 0;
}
