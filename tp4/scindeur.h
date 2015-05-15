#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <time.h>

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

void free_list(List *list) {
    while (list != NULL) { /* tant que la liste n'est pas vide */
        List *cell = list;
        list = list->next;
        free(cell);
    }
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

// structure de liste chainee pour mots d'une classe

struct list2 {
    uint32_t numMot;
    uint8_t nbDocsClasse;
    struct list2 *next;
};
typedef struct list2 ListeMotsClasse;

// ajouter un element entre prec et cour, renvoie cour

void cons2(uint32_t num, ListeMotsClasse *prec, ListeMotsClasse *cour) {
    ListeMotsClasse *elem = malloc(sizeof (ListeMotsClasse));
    if (NULL == elem)
        exit(EXIT_FAILURE);
    elem->numMot = num;
    elem-> nbDocsClasse = 1;
    prec->next = elem;
    elem->next = cour;
}

// compte le nombre d'éléments
int count(ListeMotsClasse *list) {
    int compteur = 0;
    while (list != NULL) { /* tant que la liste n'est pas vide */
        list = list->next;
        compteur++;
    }

    return compteur;
}

// liberer une liste

void free_list2(ListeMotsClasse *list) {
    while (list != NULL) { /* tant que la liste n'est pas vide */
        ListeMotsClasse *cell = list;
        list = list->next;
        free(cell);
    }
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

#endif	/* SCINDEUR_H */

