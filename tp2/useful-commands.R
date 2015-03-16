# 1.a)
# chargement des données
NAm2 <- read.table("NAm2.txt", header=T)

# vérifier le nom des colonnes
names(NAm2[,1:10])

# 1.b)
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

# 2)
NAaux <- NAm2[,-(1:7)]
mylm <- lm(formula = long ~., data = NAaux)
summary(mylm)

# 3.b)
NAgen <- NAm2[,-(1:8)]
pcaNAm2 <- prcomp(NAgen)

caxes=c(1,2)
plot(pcaNAm2$x[,caxes],col="white")
for (i in 1:npop) {
print(names[i])
lines(pcaNAm2$x[which(NAm2[,3]==names[i]),caxes],type="p",col=colPalette[i],pch=pch[i])
}
legend("top",legend=names,col=colPalette,lty=-1,pch=pch,cex=.75,ncol=3,lwd=2)
