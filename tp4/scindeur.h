#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <float.h>

#ifndef SCINDEUR_H
#define	SCINDEUR_H

const int TAILLE_APPRENTISSAGE_VOULUE = 52500;
const int NB_TOTAL_DOCUMENTS = 70703;
const int NB_CAT = 29;
int taille_voca;

// structure de liste chainee pour indices

struct list {
    uint32_t val;
    struct list *next;
};
typedef struct list List;

// ajouter un element en debut de chaine

List *cons(uint32_t valeur, List *liste) {
    List *elem = malloc(sizeof (List));
    if (NULL == elem)
        exit(EXIT_FAILURE);
    elem->val = valeur;
    elem->next = liste;
    return elem;
}

// inverser l'ordre d'une liste

List *inverser(List *liste) {
    List *liste_inv = NULL;
    while (liste != NULL) {
        List *next = liste->next;
        liste->next = liste_inv;
        liste_inv = liste;
        liste = next;
    }

    return liste_inv;
}

// liberer une liste

List * free_list(List *list) {
    while (list != NULL) { /* tant que la liste n'est pas vide */
        List *cell = list;
        list = list->next;
        free(cell);
    }

    return NULL;
}

// affiche les elements d'une chaine

int print(List *list) {
    int compteur = 0;
    while (list != NULL) { /* tant que la liste n'est pas vide */
        //printf("%i ", list->val);
        list = list->next;
        compteur++;
    }

    printf("Cette liste contient %i elements\n", compteur);

    return compteur;
}


// renvoie un double aleatoire compris entre 0 et 1

double r2() {
    return (double) rand() / (double) RAND_MAX;
}

// initialise N et df 

void init(uint16_t N[NB_CAT], uint16_t df[NB_CAT][taille_voca]) {
    int k;
    for (k = 0; k < NB_CAT; k++) {
        // on initialise N avec des 0
        N[k] = 0;
        int i;
        for (i = 0; i < taille_voca; i++) {
            df[k][i] = 0;
        }
    }
}

// initialise N, D et df 

void init2(uint16_t N[NB_CAT], uint32_t D[NB_CAT], uint16_t tf[NB_CAT][taille_voca]) {
    int k;
    for (k = 0; k < NB_CAT; k++) {
        // on initialise N avec des 0
        N[k] = 0;
        D[k] = 0;
        int i;
        for (i = 0; i < taille_voca; i++) {
            tf[k][i] = 0;
        }
    }
}

void initPiF(double PiF[NB_CAT], uint16_t N[NB_CAT], uint16_t df[NB_CAT][taille_voca], int m) {
    int k;
    for (k = 0; k < NB_CAT; k++) {
        PiF[k] = log((double) N[k] / (double) m);
        uint16_t(*dfk)[taille_voca];
        dfk = &(df[k]);
        uint16_t Nk = N[k];
        int i;
        for (i = 0; i < taille_voca; i++) {
            PiF[k] += log((double) (Nk - (*dfk)[i - 1] + 1));
        }
        PiF[k] -= taille_voca * log((double) (Nk + 2));
    }
}



#endif	/* SCINDEUR_H */

