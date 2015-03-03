pairs(pro)

mylm <- lm(formula = lpsa ~ lcavol + lweight + age + lbph + svi + lcp + factor(gleason) + pgg45, data = pro)
summary(mylm)

# avec factor(svi)
mylm <- lm(formula = lpsa ~ lcavol + lweight + age + lbph + factor(svi) + lcp + factor(gleason) + pgg45, data = pro)
summary(mylm)

# intervalle de confiance
confint(mylm, level=0.99)
# => lcp                              -0.52254821 0.17406981

# sans lcavol et svi
mylm2 <- lm(formula = lpsa ~ lweight + age + lbph + lcp + factor(gleason) + pgg45, data = pro)

confint(mylm2, level=0.99)
# => lcp                               0.1049965 0.7526673


# correlation entre lcavol, svi, lcp
pairs(~ lcp + lcavol + svi, data = pro, main = "Matrix")

# x = (question 2.c)
qt(0.999, 86) # 3.187722

X <- mylm$residuals
sum(X*X)
# 41.81094


4)a)
# overfitting, plus on rajoute de données, plus on fit les points mais ce n'est pas satisfaisant car on prédit mal de nouvelles données
lm(lpsa~1,data=pro) # approxime par la moyenne

lm(lpsa~.,data=pro[,c(1,4,9)]) # équivalent à lm(lpsa~lcavol + lbph,data=pro) => approxime en fonction de lcavol et lbph 

lm(lpsa~.,data=pro[,c(2,7,9)]) # équivalent à lm(lpsa~lweight + gleason,data=pro) => approxime en fonction de lweigth et gleason

X <- mylm$residuals
sum(X*X)

A <- combn(8, 2)
for(i in 1:length(A[1,])) {
    mylm <- lm(lpsa~., data = pro[,c(A[1,i], A[2,i], 9)])
    res <- mylm$residuals
    print(sum(res*res))
}

5)a) 
# garder des donnees pour valider le modele (pour eviter l'overfitting)

5)b)
valid <- seq(from = 1, to = length(pro[,1]), by = 2) 

5)c)
lm(lpsa~.,data=pro[-valid,c(i,j,9)]) # utilise les colonnes i et j pour predire lpsa en retirant les lignes dont les indices donc dans valid 
RSS

5)d)
