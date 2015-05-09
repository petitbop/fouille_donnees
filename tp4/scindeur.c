#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

const int TAILLE_APPRENTISSAGE_VOULUE = 52500;
const int NB_TOTAL_DOCUMENTS = 70703;
const int NB_CAT = 29;

// structure de liste chainee

struct list {
    int val;
    struct list *next;
};
typedef struct list List;

// ajouter un element en debut de chaine

List *cons(int valeur, List *liste) {
    List *elem = malloc(sizeof (List));
    if (NULL == elem)
        exit(EXIT_FAILURE);
    elem->val = valeur;
    elem->next = liste;
    return elem;
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

void print(List *list) {
    int compteur = 0;
    while (list != NULL) { /* tant que la liste n'est pas vide */
        //printf("%i ", list->val);
        list = list->next;
        compteur++;
    }

    printf("Cette liste a %i elements\n", compteur);
}

// renvoie un double aleatoire compris entre 0 et 1

double r2() {
    return (double) rand() / (double) RAND_MAX;
}

// calcule la taille du vocabulaire et le nombre de documents par catégorie
// requiert que nb_docs ait ses élements initialisés à 0

void question1(int *taille_voca, int nb_docs[NB_CAT]) {

    int i;
    for (i = 0; i < NB_CAT; i++) {
        nb_docs[i] = 0; // on intialise tous les éléments à 0
    }

    FILE* fichier = fopen("BaseReuters-29", "r");
    int num_mot, nb_occur;
    int fin_de_ligne = 0;
    int fin_de_fichier = 0;
    int fscanf_value;
    int max = 0;
    int num_cat;

    fscanf(fichier, "%d", &num_cat);
    while (!fin_de_fichier) {
        fin_de_ligne = 0;
        nb_docs[num_cat - 1]++;
        //printf("La categorie est : %d\n", num_cat);
        while (!fin_de_ligne) {
            fscanf_value = fscanf(fichier, " %d:%d", &num_mot, &nb_occur);
            if (num_mot > max) max = num_mot;
            if (fscanf_value == 2) {
                //printf("Le mot %d est present %d fois dans ce document\n", num_mot, nb_occur);
            } else if (fscanf_value == -1) {
                fin_de_ligne = 1;
                fin_de_fichier = 1;
            } else { // on a lu la categorie de la prochaine ligne
                fin_de_ligne = 1;
                num_cat = num_mot;
            }
        }
    }
    fclose(fichier);

    *taille_voca = max;
}


// Algorithm 5: Modèle multivarié de Barnoulli, phase d'apprentissage

void apprentissageBernoulli(List *base_app, int taille_voca, double Pi[NB_CAT], double PC[NB_CAT][taille_voca]) {

    int k; 
    for (k = 0; k < NB_CAT; k++) {
        Pi[k] = 0; // pour l'instant Pi[] = N[]    
        int i;
        for (i = 0; i < taille_voca; i++) {
            PC[k][i] = 0; // pour l'instant PC[] = df[] 
        }
    }
    
    FILE* fichier = fopen("BaseReuters-29", "r");
    int num_mot, nb_occur;
    int fin_de_ligne = 0;
    int fin_de_fichier = 0;
    int est_app; //fait partie ou non de la base d'apprentissage
    int fscanf_value;
    int num_ligne = 1;
    int num_cat;
    int m = 0;

    fscanf(fichier, "%d", &num_cat);
    while (!fin_de_fichier) {
        fin_de_ligne = 0;
        if (num_ligne == base_app->val) {
            est_app = 1;
            List *cell = base_app;
            base_app = base_app->next; // on avance dans la base d'apprentissage
            free(cell);
            m++;
            Pi[num_cat - 1]++;     
        } else {
            est_app = 0;
        }

        while (!fin_de_ligne) {
            fscanf_value = fscanf(fichier, " %d:%d", &num_mot, &nb_occur);
            if (fscanf_value == 2) {
                if (est_app) {
                    PC[num_cat-1][num_mot-1]++; 
                }
            } else if (fscanf_value == -1) {
                fin_de_ligne = 1;
                fin_de_fichier = 1;
            } else { // on a lu la categorie de la prochaine ligne
                fin_de_ligne = 1;
                num_ligne++;
                num_cat = num_mot;
            }


        }
    }
    fclose(fichier);

    for (k = 0; k < NB_CAT; k++) {
        int i;
        for (i = 0; i < taille_voca; i++) {
            PC[k][i] = (PC[k][i] + 1) / (Pi[k] + 2); 
        }        
        Pi[k] /= m;   
    }
    
    assert(base_app == NULL);
}

int main() {

    /* Question 1 */

    printf("\nQuestion 1 :\n");
    int nb_docs[NB_CAT];
    int taille_voca;
    {
        question1(&taille_voca, nb_docs);

        printf("La taille du vocabulaire est : %d\n", taille_voca);
        int somme_verif = 0;
        int i;
        for (i = 0; i < NB_CAT; i++) {
            printf("La classe %d contient %d documents\n", i + 1, nb_docs[i]);
            somme_verif += nb_docs[i];
        }
        assert(somme_verif == NB_TOTAL_DOCUMENTS);
    }

    /* Question 2 */

    printf("\nQuestion 2 :\n");
    List *base_apprentissage = NULL;
    List *base_test = NULL;
    {
        time_t t;
        double r;

        /* Intializes random number generator */
        srand((unsigned) time(&t));

        // ratio idealement voulu
        const double ratio = (double) TAILLE_APPRENTISSAGE_VOULUE / (double) NB_TOTAL_DOCUMENTS;
        /* on scinde aleatoire la collection suivant deux ensembles ; 
        base d'entraînement (environ 52500 documents) et base de test (environ 18203 documents). 
         */
        int i;
        for (i = NB_TOTAL_DOCUMENTS; i > 0; i--) { // on part de la fin car on ajoute en debut de chaine
            r = r2();
            if (r < ratio) {
                base_apprentissage = cons(i, base_apprentissage);
            } else {
                base_test = cons(i, base_test);
            }
        }
        printf("Base d'apprentissage :\n");
        print(base_apprentissage);
        printf("Base de test :\n");
        print(base_test);
    }


    /* Question 3 */

    printf("\nQuestion 3 :\n");
    double Pi[NB_CAT];
    printf("DECLARATION 1 OK\n");
    double PC[NB_CAT][taille_voca];
    printf("DECLARATION 2 OK\n");

    apprentissageBernoulli(base_apprentissage, taille_voca, Pi, PC);
    
    
    


    free_list(base_test);
    free_list(base_apprentissage);

    return (0);
}
