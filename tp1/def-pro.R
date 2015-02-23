prostateCancer = read.table("./prostate.data",header=T)
pro1 = prostateCancer[,-ncol(prostateCancer)] # retire la dernière colonne du jeu
pro = as.data.frame(cbind(scale(pro1[,1:8]),pro1[,9]))
# centre et réduit les colonnes correspondant aux 8 prédicteurs
# crée un objet de type data.frame avec les 8 colonnes de prédicteurs et la colonne «output» lpsa
names(pro) = names(pro1) # conserve les noms des colonnes
