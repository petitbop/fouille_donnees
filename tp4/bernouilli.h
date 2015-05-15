#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <float.h>

#ifndef BERNOUILLI_H
#define	BERNOUILLI_H

const int TAILLE_APPRENTISSAGE_VOULUE = 52500;
const int NB_TOTAL_DOCUMENTS = 70703;
const int NB_CAT = 29;
int taille_voca;

double r2() {
    return (double) rand() / (double) RAND_MAX;
}

#endif