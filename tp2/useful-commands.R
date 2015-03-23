################################ 1.a)
# chargement des données
NAm2 <- read.table("NAm2.txt", header=T)

# vérifier le nom des colonnes
names(NAm2[,1:10])

################################ 1.b)
names=unique(NAm2$Pop)
npop=length(names)
coord=unique(NAm2[,c("Pop","long","lat")]) #coordinates for each pop
colPalette=rep(c("black","red","cyan","orange","brown","blue","pink","purple",
"darkgreen"),3)
pch=rep(c(16,15,25),each=9)
plot(coord[,c("long","lat")],pch=pch,col=colPalette,asp=1)
# asp permet d'avoir le rapport correct entre les axes longitude et latitude
# ainsi la carte n'est pas déformée
legend("bottomleft",legend=names,col=colPalette,lty=-
1,pch=pch,cex=.75,ncol=2,lwd=2)
library(maps);map("world",add=T)

# sauvegarder l'image avec Rstudio

################################ 2)
NAaux <- NAm2[,-(1:7)]
mylm <- lm(formula = long ~., data = NAaux)
summary(mylm)

################################ 3.b)
NAgen <- NAm2[,-(1:8)]
pcaNAm2 <- prcomp(NAgen) # normalisation intrinsèque

# ACP avec axes 1 et 2
caxes=c(1,2)
plot(pcaNAm2$x[,caxes],col="white")
for (i in 1:npop) {
print(names[i])
lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i])
}
legend("top",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=3,lwd=2)

# ACP avec 5 et 6
caxes=c(5,6)
plot(pcaNAm2$x[,caxes],col="white")
for (i in 1:npop) {
print(names[i])
lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i])
}
legend("top",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=3,lwd=2)

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
print(compteur) # donne n=494 le nombre de marqueurs génétiques
erreurmoy = erreur / compteur;
# on obtient une erreur moyenne de 641.1188 km ; cohérent ???? (faire la division à la fin est il cohérent ? ou faut il diviser pour chaque population ?)
# Rappel : Les dimensions des États-Unis continentaux sont gigantesques : 2 500 km du nord au sud, 4 500 km d’est en ouest.


