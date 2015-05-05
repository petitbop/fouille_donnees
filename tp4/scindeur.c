#include <stdio.h>
#include <stdlib.h>

// ratio idealement voulu
double ratio = (double)52500/(double)70703;

// structure de liste chainee
struct list
{
    int val;
    struct list *next;
};
typedef struct list List; 

// ajouter un element en debut de chaine
List *cons(int valeur, List *liste)
{
    List *elem = malloc(sizeof(List));
    if (NULL == elem)
        exit(EXIT_FAILURE);
    elem->val = valeur;
    elem->next = liste;
    return elem;
} 

// liberer une liste
void free_list(List *list)
{
    while (list != NULL) { /* tant que la liste n'est pas vide */
        List *cell = list;
        list = list->next;
        free(cell);
    }
} 

// affiche les elements d'une chaine
void print(List *list)
{   
    int compteur = 0;
    while (list != NULL) { /* tant que la liste n'est pas vide */
        List *cell = list;
        printf("%i ", list->val);
        list = list->next;
        compteur++;
    }
    
    printf("\nCette liste a %i elements\n", compteur);
} 

// renvoie un double aleatoire compris entre 0 et 1
double r2()
{
    return (double)rand() / (double)RAND_MAX ;
}

int main(int argc, char *argv[]) {
    List *base_apprentissage = NULL;
    List *base_test = NULL;    
    time_t t;
    double r;
      
    /* Intializes random number generator */
    srand((unsigned) time(&t));

    int i;
    /* on scinde aleatoire la collection suivant deux ensembles ; 
    base d'entraînement (environ 52500 documents) et base de test (environ 18203 documents). 
    */
    for (i = 70703; i > 0; i--) { // on part de la fin car on ajoute en debut de chaine
        r = r2();
        if (r < ratio) {
            base_apprentissage = cons(i, base_apprentissage);
        } else {
            base_test = cons(i, base_test);
        }
    }
    
    print(base_test);
    
    free_list(base_test);
    free_list(base_apprentissage);
    
    return(0);
}
