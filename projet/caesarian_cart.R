#install.packages("farff")
library(farff)
library(ipred)
library(tree)
library(randomForest)
library(class)

rm(list=ls());
graphics.off();

# read data
dataset = readARFF("caesarian.csv.arff")

str(dataset)

# separate data into 2 : one set to train the model, one used to test it
indexes = sample(80, 60)
data_train = dataset[indexes,]
data_test = dataset[-indexes,]


# knn predict for k = 1 , k = 5 and k = 20

knn.1 = knn(data_train, data_test, cl = dataset$Caesarian[indexes], k = 1)
perf_knn.1 = 100 * sum(dataset$Caesarian[-indexes] == knn.1)/100

knn.5 = knn(data_train, data_test, cl = dataset$Caesarian[indexes], k = 5)
perf_knn.5 = 100 * sum(dataset$Caesarian[-indexes] == knn.5)/100

knn.20 = knn(data_train, data_test, cl = dataset$Caesarian[indexes], k = 20)
perf_knn.20 = 100 * sum(dataset$Caesarian[-indexes] == knn.20)/100
  

# Bagging, LDA, tree, randomforest

modbag = bagging(Caesarian~., data = data_train)
bagpred_test <- predict(modbag, newdata = data_test, type = "class")
Bagging_test <- mean(bagpred_test == data_test$Caesarian)
#bagpred_train <- predict(modbag, newdata = data_train, type = "class")
#Bagging_train <- mean(bagpred_train == data_train$Caesarian)

lda_data = lda(Caesarian~., data = data_train)
ldapred_test <- predict(lda_data, newdata = data_test, type = "class")
LDA_test <- mean(ldapred_test == data_test$Caesarian)

tree_data = tree(Caesarian~., data = data_train)
treepred_test <- predict(tree_data, newdata = data_test, type = "class")
Tree_test <- mean(treepred_test == data_test$Caesarian)

#rf = randomForest(Caesarian~., data = data_train)
#rfpred_test <- predict(rf, newdata = data_test, type = "class")
#Rf_test <- mean(rfpred_test == data_test$Caesarian)


# naive bayes
