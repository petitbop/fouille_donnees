#include "bernouilli.h"
#include "stdbool.h"

// calcule la taille du vocabulaire et le nombre de documents par catégorie
// requiert que nb_docs ait ses élements initialisés à 0

#define TAILLE_MAX 10000 
int question1(uint16_t nb_docs[NB_CAT]) {

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

    return max;
}

void question2 (uint32_t *nb_docs_app, uint32_t* nb_docs_test) {
    char ligne[TAILLE_MAX] = "";
    FILE* fichier_lecture = fopen("BaseReuters-29", "r");
    FILE* fichier_ecriture_app = fopen("base_apprentissage", "w");
    FILE* fichier_ecritre_test = fopen("base_test", "w");

    uint32_t nb_base_app = 0;
    uint32_t nb_base_test = 0;

        time_t t;
        double r;

        /* Intializes random number generator */
        srand((unsigned) time(&t));

        // ratio idealement voulu
        const double ratio = (double) TAILLE_APPRENTISSAGE_VOULUE / (double) NB_TOTAL_DOCUMENTS;
        /* on scinde aleatoire la collection suivant deux ensembles ; 
        base d'entraînement (environ 52500 documents) et base de test (environ 18203 documents). 
         */
        while (fgets(ligne, TAILLE_MAX, fichier_lecture) != NULL) { // on part de la fin car on ajoute en debut de chaine
            r = r2();
            if (r < ratio) {
                nb_base_app++;
                fputs(ligne, fichier_ecriture_app);
            } else {
                nb_base_test++;
                fputs(ligne, fichier_ecritre_test);
            }
        }

        *nb_docs_app = nb_base_app;
        *nb_docs_test = nb_base_test;

        fclose(fichier_lecture);
        fclose(fichier_ecritre_test);
        fclose(fichier_ecriture_app);

    }

    void apprentissageBernouilli(uint32_t **df, uint32_t N[NB_CAT]){
        FILE* fichier_apprentissage = fopen("base_apprentissage", "r");

        int num_cat, num_mot, nb_occur;
        int fscanf_value;
        int fin_de_fichier = 0;
        int fin_de_ligne = 0;
        uint32_t num_ligne = 1;

        fscanf(fichier_apprentissage, "%d", &num_cat);
        while (!fin_de_fichier) {  
            N[num_cat-1]++;  
            fin_de_ligne = 0;
            while (!fin_de_ligne) {
                fscanf_value = fscanf(fichier_apprentissage, " %d:%d", &num_mot, &nb_occur);
                if (fscanf_value == 2) {
                    df[num_cat-1][num_mot-1]++;
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

        fclose(fichier_apprentissage);

    }    

    void CalculeParam(uint32_t **teta, uint32_t *pi, int taille_voca, uint32_t **df, uint32_t N[NB_CAT]){
        for(int i=0; i<NB_CAT; i++){
            pi[i]=N[i]/NB_TOTAL_DOCUMENTS;
            for(int j=0; j<taille_voca; j++){
                teta[i][j]=(df[i][j]+1)/(N[i]+2);
            }
        }
    }

    void MotPresentAbsent(bool **MotPresentAbsent){
        FILE* fichier_test = fopen("base_test", "r");
        
        int num_cat, num_mot, nb_occur;
        int fscanf_value;
        int fin_de_fichier = 0;
        int fin_de_ligne = 0;
        uint32_t num_ligne = 0;

        fscanf(fichier_test, "%d", &num_cat);
        while (!fin_de_fichier) {   
            fin_de_ligne = 0;
            while (!fin_de_ligne) {
                fscanf_value = fscanf(fichier_test, " %d:%d", &num_mot, &nb_occur);
                if (fscanf_value == 2) {
                    MotPresentAbsent[num_ligne][num_mot-1] = true;
                } else if (fscanf_value == -1) {
                    fin_de_ligne = 1;
                    fin_de_fichier = 1;
                } else { // on a lu la categorie de la prochaine ligne
                    fin_de_ligne = 1;
                    num_ligne++;
                }
            }
        }

        fclose(fichier_test);   
    }

    void Vraisemblance( double **VraisemblanceTab, 
                        uint32_t **teta, uint32_t *pi, bool **MotPresentAbsent, 
                        uint32_t nb_docs_test, 
                        int taille_voca){

        for (uint32_t i=0; i<nb_docs_test; i++){
            printf("%i\n", i);
            for(int k=0; k<NB_CAT; k++){
                VraisemblanceTab[k][i]+=log(pi[k]);
                for(int j=0; j<taille_voca; j++){
                    if(MotPresentAbsent[i][j]==true){
                        VraisemblanceTab[k][i]+=log(teta[k][j]);
                    }else{
                        VraisemblanceTab[k][i]+=log(1-teta[k][j]);
                    }
                }
            }
        }
    }

    void MaxVraisemblance(double **Vraisemblance, int *ClassePredite, uint32_t nb_docs_test){
        double max;
        int k_max; //classe max
        for(uint32_t i=0; i<nb_docs_test; i++){
            max = -DBL_MAX;
            for (int k=0; k<NB_CAT; k++){
                if (Vraisemblance[k][i]>max){
                    max = Vraisemblance[k][i];
                    k_max = k;
                }
            }
            ClassePredite[i]=k_max;
        }

    }

int main() {

    /* Question 1 */

    printf("\nQuestion 1 :\n");
    uint16_t nb_docs[NB_CAT];
    taille_voca = question1(nb_docs);

    printf("La taille du vocabulaire est : %d\n", taille_voca);
    int somme_verif = 0;
    int i;
    for (i = 0; i < NB_CAT; i++) {
        printf("La classe %d contient %d documents\n", i + 1, nb_docs[i]);
        somme_verif += nb_docs[i];
    }
    assert(somme_verif == NB_TOTAL_DOCUMENTS);

    
    
    /* Question 2 */
    uint32_t nb_docs_app, nb_docs_test = 0;
    question2(&nb_docs_app, &nb_docs_test);
    assert(nb_docs_app+nb_docs_test==NB_TOTAL_DOCUMENTS);
    printf("\nQuestion 2 :\n");
    printf("\nIl y a %d documents dans la base d'apprentissage.\n", nb_docs_app);
    printf("\nIl y a %d documents dans la base de test.\n", nb_docs_test);

    /* Question 3 */
    printf("\nQuestion 3 :\n");
    uint32_t * df[NB_CAT];
    for (int i=0; i<NB_CAT; i++){
        df[i]=malloc(taille_voca*sizeof(uint32_t));
    }

     for (int i=0; i<NB_CAT; i++){
        for(int j=0; j<taille_voca; j++){
            df[i][j]=0;
        }
        
    }


    uint32_t N[NB_CAT];
    for(int i=0; i<NB_CAT; i++){
        N[i]=0;
    } 

    apprentissageBernouilli(df, N);

    uint32_t * teta[NB_CAT];
    for (int i=0; i<NB_CAT; i++){
        teta[i]=malloc(taille_voca*sizeof(uint32_t));
    }

    uint32_t pi[NB_CAT];

    CalculeParam(teta, pi, taille_voca, df, N);

    /* Question 4 */
    printf("\nQuestion 4 :\n");

    bool **MotPresentAbsentTab;
    MotPresentAbsentTab=malloc(nb_docs_test*sizeof(*MotPresentAbsentTab));
    for(uint32_t i=0; i<nb_docs_test; i++){
        MotPresentAbsentTab[i]=malloc(taille_voca*sizeof(**MotPresentAbsentTab));
    }

    for(uint32_t i=0; i<nb_docs_test; i++){
        for(int j=0; j<taille_voca; j++){
            MotPresentAbsentTab[i][j]=false;
        }
    }

    MotPresentAbsent(MotPresentAbsentTab);

    printf("fin MotPresentAbsent\n");
    double *VraisemblanceTab[NB_CAT];
    for (int i=0; i<NB_CAT; i++){
        VraisemblanceTab[i]=malloc(nb_docs_test*sizeof(double));
    }

    for (int i=0; i<NB_CAT; i++){
        for(uint32_t j=0; j<nb_docs_test; j++){
            VraisemblanceTab[i][j]=0;
        } 
    }

    int *ClassePredite = malloc(nb_docs_test*sizeof(int));

    Vraisemblance(VraisemblanceTab, teta, pi, MotPresentAbsentTab, nb_docs_test, taille_voca);
    printf("fin Vraisemblance\n");
    MaxVraisemblance(VraisemblanceTab, ClassePredite, nb_docs_test);
    printf("fin MaxVraisemblance\n");

    return (0);
}