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

best.rss <- function(k){
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