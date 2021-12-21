library(stopwords)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)
gas<-read.csv("gastext.csv",stringsAsFactors = FALSE)
View(gas)
ac_corpus<-corpus(gas$Comment)
summary(ac_corpus)
ac_dfm<- dfm(tokens(ac_corpus,remove_punct=T,remove_numbers = T))


tstat_freq <- textstat_frequency(ac_dfm)
head(tstat_freq, 20)

stop_words1<-c(".",",","/","@","?","(",")","-","_","!","*")
ac_dfm<-dfm_remove(ac_dfm,stop_words1)
ac_dfm@Dimnames
ac_dfm1<-dfm_remove(ac_dfm,stopwords("english"))
ac_dfm1@Dimnames
ac_dfm1<-dfm_wordstem(ac_dfm1)
ac_dfm1@Dimnames

library(ggplot2)
ac_dfm1 %>% 
  textstat_frequency(n = 20) %>% 
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()
# Wordcloud
textplot_wordcloud(ac_dfm1,max_words=200)


#Similarity

term_sim <- textstat_simil(ac_dfm1,select="price",margin="feature",method="correlation" )
head(as.matrix(term_sim),17)

term_sim1<-textstat_simil(ac_dfm1,select="servic",margin="feature",method="correlation")
head(as.matrix(term_sim1),17)

#Topic modelling
common_words<-c("shower","point","per","cent")
ac_dfm2<-dfm_remove(ac_dfm1,common_words)

ac_tfidf <- dfm_tfidf(ac_dfm2)
head(ac_tfidf)

ac_dfm2<- as.matrix(ac_dfm2)
ac_dfm2 <-ac_dfm2[which(rowSums(ac_dfm2)>0),]
ac_dfm2 <- as.dfm(ac_dfm2)

library(topicmodels)
library(tidytext)

ac_Lda <- LDA(ac_dfm2,k=4,control=list(seed=101))
ac_Lda
# Term-topic probabilities
ac_Lda_td <- tidy(ac_Lda)
ac_Lda_td

#topic modelling plot

library(ggplot2)
library(dplyr)
top_terms <- ac_Lda_td %>%
  group_by(topic) %>%
  top_n(6, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

ac_Lda_term<-as.matrix(terms(ac_Lda,4))
View(ac_Lda_term)
# Document-topic probabilities
ap_documents <- tidy(ac_Lda, matrix = "gamma")
ap_documents
# View document-topic probabilities in a table
Lda_document<-as.data.frame(ac_Lda@gamma)
View(Lda_document)


#Decision tree models
library(dplyr)
library(tidyverse)
library(rpart.plot)
library(rpart)
library(caret)
library(e1071)
library(pROC)

#model without text comment

summary(gas)
str(gas)
gas1<-gas %>% select(-c('Comment','Cust_ID'))
str(gas1)
gas1[,1:13]<-lapply(gas1[,1:13],factor)
str(gas1)
sum(is.na(gas1))

#Model

trainIndex<- createDataPartition(gas1$Target,p=0.7,list=FALSE,times=1)
AC_trainD<-gas1[trainIndex,]
AC_validD<-gas1[-trainIndex,]
str(AC_trainD)
AC_tree.model <-rpart(Target~.,data=AC_trainD,method="class",na.action=na.pass)
rpart.plot(AC_tree.model,extra=106)
prediction <- predict(AC_tree.model,AC_validD,type="class")
confusionMatrix(prediction,AC_validD$Target)
tree.probabilities <- predict(AC_tree.model,AC_validD,type='prob')


#Model_withtext

ac_tfidf <- dfm_tfidf(ac_dfm2)
dim(ac_tfidf)
# Perform SVD for dimension reduction
# Choose the number of reduced dimensions as 8
ac_Svd <- textmodel_lsa(ac_tfidf, nd=8)
head(ac_Svd$docs)
gas3<-gas %>% select(-c('Comment','Cust_ID'))

gas4 <-cbind(gas3,as.data.frame(ac_Svd$docs))
gas4[,1:13]<-lapply(gas4[,1:13],factor)
str(gas4)
head(gas4)


trainIndex1<- createDataPartition(gas4$Target,p=0.7,list=FALSE,times=1)
AC_trainD1<-gas1[trainIndex1,]
AC_validD1<-gas1[-trainIndex1,]
str(AC_trainD1)
AC_tree.model2 <-rpart(Target~.,data=AC_trainD1,method="class")
rpart.plot(AC_tree.model2,extra=106)
prediction1 <- predict(AC_tree.model2,AC_validD1,type="class")
confusionMatrix(prediction1,AC_validD1$Target)

