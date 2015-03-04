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
pairs(~ lcp + lcavol + svi, data = pro)

# x = (question 2.c)
qt(0.999, 86) # 3.187722

X <- mylm$residuals
# sum(X*X)
# 41.81094

# 4)a)
# overfitting, plus on rajoute de données, plus on fit les points mais ce n'est pas satisfaisant car on prédit mal de nouvelles données
lm(lpsa~1,data=pro) # approxime par la moyenne

lm(lpsa~.,data=pro[,c(1,4,9)]) # équivalent à lm(lpsa~lcavol + lbph,data=pro) => approxime en fonction de lcavol et lbph 

lm(lpsa~.,data=pro[,c(2,7,9)]) # équivalent à lm(lpsa~lweight + gleason,data=pro) => approxime en fonction de lweigth et gleason

X <- mylm$residuals
# sum(X*X)

A <- combn(8, 2)
for(i in 1:length(A[1,])) {
    mylm <- lm(lpsa~., data = pro[,c(A[1,i], A[2,i], 9)])
    res <- mylm$residuals
#   print(sum(res*res))
}

best.rss <- function(k){
  if(k == 0){
    reg= lm(lpsa~1,data=pro)
    res = reg$residuals
    rss = sum(res*res)
    return(c(rss,c()))
  }
  
  min.rss = -1
  pred.id = combn(1:8,k)
  n = length(pred.id[1,])
  for(i in 1:n){
    var.id = 9
    reg = lm(lpsa~.,data=pro[,c(pred.id[,i],var.id)])
    res = reg$residuals
    rss = sum(res*res)
    if(i == 1){
      min.rss = rss
      best.pred = pred.id[,i]
    } else {
      if(rss < min.rss){
        min.rss = rss
        best.pred = pred.id[,i]
      }
    }
  }
  return(c(min.rss, c(best.pred)))
}

disp.best.rss <- function(){
  rss <- seq(0,0,length.out=9)
  for(k in 0:8){
    rss[k+1] = best.rss(k)[1]
  }
    plot(0:8,rss,type="h")
}

disp.names <- function(){
  for(k in 1:8){
    print(names(pro)[best.rss(k)[2:(k+1)]])
  }
}

get.names <- function(){
  best.subsets = matrix("", 8, 8)
  for(k in 1:8)
  best.subsets[k,1:k] = names(pro[best.rss(k)[2:(k+1)]])
  return(best.subsets)
}

# 5)a) 
# garder des donnees pour valider le modele (pour eviter l'overfitting)

# 5)b)
valid <- seq(from = 1, to = length(pro[,1]), by = 2) 

# 5)c)
i = 1
j = 2
lm2 = lm(lpsa~.,data=pro[-valid,c(i,j,9)]) # utilise les colonnes i et j pour predire lpsa en retirant les lignes dont les indices donc dans valid   
res = lm2$residuals
training.error = mean(res * res)

split.validation <- function(valid){
  best.subsets = get.names()
  err.tab = seq(0,0,length.out = 9)
  for(k in 0:8){
    if(k == 0){
      preds = c()
      my.lm = lm(lpsa~1, data=pro[-valid,])
    } else {
      preds = best.subsets[k,1:k]
      my.lm = lm(lpsa~.,data=pro[-valid,c(preds,"lpsa")])
    }
    y.pred = predict.lm(my.lm,pro[valid,])
    err.pred = y.pred - pro[valid,"lpsa"]
    err.pred.moy = mean(err.pred*err.pred)
    err.tab[k+1] = err.pred.moy
  }
  return(err.tab)
}

best.rss.moy <- function(k, valid){
  if(k == 0){
    reg= lm(lpsa~1,data=pro[-valid,])
    res = reg$residuals
    rss = mean(res*res)
    return(c(rss,c()))
  }
  
  #   min.rss = -1
  #   pred.id = combn(1:8,k)
  #   n = length(pred.id[1,])
  #   for(i in 1:n){
  #     var.id = 9
  #     reg = lm(lpsa~.,data=pro[-valid,c(pred.id[,i],var.id)])
  #     res = reg$residuals
  #     rss = mean(res*res)
  #     if(i == 1){
  #       min.rss = rss
  #       best.pred = pred.id[,i]
  #     } else {
  #       if(rss < min.rss){
  #         min.rss = rss
  #         best.pred = pred.id[,i]
  #       }
  #     }
  #   }
  best = best.rss(k)
  best.preds = best[2:(k+1)]
  reg = lm(lpsa~.,data=pro[-valid,c(best.preds,var.id)])
  res = reg$residuals
  err.app.moy = mean(res*res)
  
  return(c(err.app.moy, c(best.preds)))
}


err.app = seq(0,0,length.out=9)
for(k in 0:8){
  err.app[k+1] = best.rss.moy(k,valid)[1]
}
err.pred = split.validation(valid)
dev.off()
plot(0:8,err.app,col="blue",xlab="Nombre de prédicteurs", ylab="RSS")
#points(0:8,err.pred,col="red")

n=length(pro[,1])
valid1 = sample(1:n,n/2)
err.pred1 = split.validation(valid1)
#print(err.pred1)
#plot(0:8,err.pred1,col="red")

m=30
err.pred.mat = matrix(0,m,9)
for(i in 1:m){
  valid = sample(1:n,n/2)
  err.pred.mat[i,] = split.validation(valid)
}
err.pred.moy = seq(0,0,length.out = 9)
for(k in 0:8){
  err.pred.moy[k+1] = mean(err.pred.mat[,k+1])
}
plot(0:8,err.pred.moy,col="red")