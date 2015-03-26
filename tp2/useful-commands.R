setwd("~/tps//data_mining//tp2")
################################ 1.a)
# chargement des données
NAm2 <- read.table("NAm2.txt", header=T)

# vérifier le nom des colonnes
names(NAm2[,1:10])

################################ 1.b)
names=unique(NAm2$Pop)
npop=length(names)
coord=unique(NAm2[,c("Pop","long","lat")]) #coordinates for each pop
colPalette=rep(c("black","red","cyan","orange","brown","blue","pink","purple","darkgreen"),3)
pch=rep(c(16,15,25),each=9)
plot(coord[,c("long","lat")],pch=pch,col=colPalette,asp=1)
# asp permet d'avoir le rapport correct entre les axes longitude et latitude
# ainsi la carte n'est pas déformée
legend("bottomleft",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=2,lwd=2)
library(maps);map("world",add=T)

################################ 2)
NAaux <- NAm2[,-(1:7)]
mylm <- lm(formula = long ~., data = NAaux)
summary(mylm)

################################ 3.b)
NAgen <- NAm2[,-(1:8)]
pcaNAm2 <- prcomp(NAgen) # normalisation intrinsèque

# ACP avec axes 1 et 2
pdf("acp12.pdf")
caxes=c(1,2)
plot(pcaNAm2$x[,caxes],col="white")
for (i in 1:npop) {
  print(names[i])
  lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i],cex=0.7)
}
legend("bottomleft",legend=names,col=colPalette,lty=-1,pch=pch,cex=.60,ncol=3,lwd=2)
dev.off()

# ACP avec 5 et 6
pdf("acp56.pdf")
caxes=c(5,6)
plot(pcaNAm2$x[,caxes],col="white")
for (i in 1:npop) {
  print(names[i])
  lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i],cex=0.7)
}
legend("topright",legend=names,col=colPalette,lty=-1,pch=pch,cex=.60,ncol=3,lwd=2)
dev.off()

# ACP juste pour un 
caxes=c(1,2)
plot(pcaNAm2$x[,caxes],col="white")
i = 3 # i peut aller de 1 à npop=27
print(names[i])
lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i])
legend("top",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=3,lwd=2)

################################ 3.c)
summary(pcaNAm2) # donne pour tous => les deux premières composantes principales expliquent 3,57% de la variance totale

# aide pour l'ACP sous R : http://eric.univ-lyon2.fr/~ricco/cours/didacticiels/R/acp_avec_r.pdf

################################ 4.a)
caxes=1:250
firstACP = pcaNAm2$x[,caxes]
NAlonglat = NAm2[,7:8]
lmlong <- lm(formula = long ~ firstACP, data = NAlonglat)
lmlat <- lm(formula = lat ~ firstACP, data = NAlonglat)
summary(lmlong)
summary(lmlat) # la premiere composante principale "n'est pas bien représenté" dans les deux regressions
# ce qui peut être normal si la diversité dans le génome des espèces ne représente pas bien
# la diversité de localisation (de plus la variance représentée par la 1ere ACP est faible)
# Apparemment d'après le prof, grace aux deux premieres CP on differencie bien  les Surui des Ache (en bas)
# mais comme ils n'ont pas une latitude ou longtitude très éloignée, ca ne diferencie pas bien au niveau localisation      


################################ 4.b)
plot(lmlong$fitted.values,lmlat$fitted.values,col="white",xlim = c(-140,-20),ylim=c(-50,70)) # bornes rajoutées
for (i in 1:npop) {
  print(names[i])
  lines(lmlong$fitted.values[which(NAm2[,3]==names[i])],lmlat$fitted.values[which(NAm2[,3]==names[i])],type="p",col=colPalette[i],pch=pch[i])
}
legend("bottomleft",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=3,lwd=2)
map("world",add=T)

# comparer avec la question 1.b)
dev.new() # pour ouvrir une nouvelle fenetre courante
names=unique(NAm2$Pop)
npop=length(names)
coord=unique(NAm2[,c("Pop","long","lat")]) #coordinates for each pop
colPalette=rep(c("black","red","cyan","orange","brown","blue","pink","purple","darkgreen"),3)
pch=rep(c(16,15,25),each=9)
plot(coord[,c("long","lat")],pch=pch,col=colPalette,asp=1,xlim = c(-140,-20),ylim=c(-50,70)) # bornes rajoutées
# asp permet d'avoir le rapport correct entre les axes longitude et latitude
# ainsi la carte n'est pas déformée
legend("bottomleft",legend=names,col=colPalette,lty=-
         1,pch=pch,cex=.75,ncol=2,lwd=2)
library(maps);map("world",add=T)

dev.off() # pour fermer la fenêtre courante
# j'ai l'impression qu'en faisant une sorte de barycentre, on arrive à retrouver la position géographique à partir des marqueurs génétiques

################################ 4.c)
# Description : Given two sets of longitude/latitude locations computes the Great circle (geographic) distance matrix among all pairings
# Usage : rdist.earth(x1, x2, miles = TRUE, R = NULL)
# Value : The great circle distance matrix if nrow(x1)=m and nrow(x2)=n then the returned matrix will be mXn
erreur = 0;
compteur = 0;
for (i in 1:npop) {
  print(names[i])
  # on regroupe les coordonnées prédites dans un tableau pour toute une population
  coordpred = cbind(lmlong$fitted.values[which(NAm2[,3]==names[i])],lmlat$fitted.values[which(NAm2[,3]==names[i])])
  # on récupère les vraies coordonnées pour cette population
  vraiescoord = NAm2[which(NAm2[,3]==names[i]),8:7][1,]
  # calcule les distances entre les coordonées prédites et la vraie
  library("fields")
  erreurs = rdist.earth(coordpred, vraiescoord, miles=F)
  erreur = erreur + sum(erreurs)
  compteur = compteur + length(erreurs)
}
print(compteur) # donne n=494 le nombre de d'individus
erreurmoy = erreur / compteur;
# on obtient une erreur moyenne de 641.1188 km ; cohérent ???? (faire la division à la fin est il cohérent ? ou faut il diviser pour chaque population ?)
# Rappel : Les dimensions des États-Unis continentaux sont gigantesques : 2 500 km du nord au sud, 4 500 km d’est en ouest.

################################ 5.a)
# Wikipedia : Dans la k-fold cross-validation, on divise l'échantillon original en k échantillons, puis on sélectionne un des k échantillons comme ensemble de validation et les (k-1) autres échantillons constitueront l'ensemble d'apprentissage. On calcule comme dans la première méthode l'erreur quadratique moyenne. Puis on répète l'opération en sélectionnant un autre échantillon de validation parmi les (k-1) échantillons qui n'ont pas encore été utilisés pour la validation du modèle. L'opération se répète ainsi k fois pour qu'en fin de compte chaque sous-échantillon ait été utilisé exactement une fois comme ensemble de validation. La moyenne des k erreurs quadratiques moyennes est enfin calculée pour estimer l'erreur de prédiction.

# Rappel : n = 494 le nombre d'individus
labels = rep(1:10,each=50)
set = sample(labels,494)

################################ 5.b)i.
predictedCoord = matrix(nrow = 494, ncol = 2, dimnames = list(c(),c("longitude", "latitude")))

################################ 5.b)ii.
naxes = 4 # ATTENTION : pas sur d'avoir compris ce qu'était reellemnt naxes
caxes=1:naxes
k = 1 # le numéro du jeu de validation à écarter pour l'apprentissage
pcalong=data.frame(cbind(long=NAm2[,c("long")],pcaNAm2$x[,caxes]))
# on enlève donc de pcalong les données qui vont servir à la validation
pcalonglearn = subset(pcalong, set[row(pcalong)[,1]] != k)
lmlong4ACP <- lm(formula = long ~., data = pcalonglearn)
summary(lmlong4ACP)
# pareil pour la latitude
pcalat=data.frame(cbind(lat=NAm2[,c("lat")],pcaNAm2$x[,caxes]))
# on enlève donc de pcalat les données qui vont servir à la validation
pcalatlearn = subset(pcalat, set[row(pcalat)[,1]] != k)
lmlat4ACP <- lm(formula = lat ~., data = pcalatlearn)
summary(lmlat4ACP)

################################ 5.b)iii.
# on prédit d'abord toutes les valeurs
coordpredall = cbind(predict.lm(lmlong4ACP, pcalong),predict.lm(lmlat4ACP, pcalat))
# on utilise ensuite que le jeu de validation numéro 1 pour commencer à remplir predictedCoord
validationSet = which(set[row(pcalat)[,1]] == k)
predictedCoord[validationSet,] = coordpredall[validationSet,]

################################ 5.b)iv.
# on complète avec les jeux de validation manquants
for (k in 2:10) { # on fait maintenant varier le jeu de validation
  # pcalong reste le meme
  # on enlève donc de pcalong les données qui vont servir à la validation
  pcalonglearn = subset(pcalong, set[row(pcalong)[,1]] != k)
  lmlong4ACP <- lm(formula = long ~., data = pcalonglearn)
  #summary(lmlong4ACP)
  # pareil pour la latitude
  pcalat=data.frame(cbind(lat=NAm2[,c("lat")],pcaNAm2$x[,caxes]))
  # on enlève donc de pcalat les données qui vont servir à la validation
  pcalatlearn = subset(pcalat, set[row(pcalat)[,1]] != k)
  lmlat4ACP <- lm(formula = lat ~., data = pcalatlearn)
  #summary(lmlat4ACP)
  # on prédit d'abord toutes les valeurs
  coordpredall = cbind(predict.lm(lmlong4ACP, pcalong),predict.lm(lmlat4ACP, pcalat))
  # on utilise ensuite que le jeu de validation numéro 1 pour commencer à remplir predictedCoord
  validationSet = which(set[row(pcalat)[,1]] == k)
  predictedCoord[validationSet,] = coordpredall[validationSet,]
}

# regroupe les vraies coordonnées
vraiescoord = NAm2[,8:7]
# calcule les distances entre les coordonées prédites et la vraie
library("fields")
erreurs = matrix(nrow = 494, ncol = 1, dimnames = list(c(),c("erreur (distance)")))
for (i in 1:494) {
  onePredictedCoord = subset(predictedCoord, row(predictedCoord)[,1] == i) # au lieu d'utiliser simplement predictedCoord[i,]
  erreurs[i,1] = rdist.earth(onePredictedCoord, vraiescoord[i,], miles=F) # sinon ne marche pas car nrow(predictedCoord[i,]) == NULL (wtf?)
}
print(sum(erreurs)) # il faut surement renvoyer autre chose que la somme brute

