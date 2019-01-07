# Hirtz Hubert - Schnell Camille

library(class);
library(e1071);
library(foreign);
library(ggplot2);
library(purrr);
library(randomForest);
library(rsample);
library(tibble);

rm(list=ls());
graphics.off();

n = 80;

#### Read and store data ####
caesarians = readARFF("caesarian.csv.arff")
names(caesarians) = c("Age", "DN", "DT", "BP", "HP", "Caesarian");

# change Age and Delivery number columns to numeric values
caesarians$Age = as.numeric(as.character(caesarians$Age))
caesarians$DN = as.numeric(as.character(caesarians$DN))
str(caesarians)

# separate data into 2 : one set to train the model, one used to test it
indexes = sample(80, 60)
data_train = caesarians[indexes,]
data_test = caesarians[-indexes,]


#### CART tree ####
caesarianTree <- rpart(Caesarian~., data = data_train,control=rpart.control(minsplit=10, cp=0))

# optimize tree
#plotcp(caesarianTree)
#caesarianTreeOpti <- prune(caesarianTree,cp=caesarianTree$cptable[which.min(caesarianTree$cptable[,4]),1])
prp(caesarianTree)

predTree <- predict(caesarianTree, newdata = data_test, type = "class")
# confusion matrix and performance
table(data_test$Caesarian, predTree)
Tree_perf <- mean(predTree == data_test$Caesarian)


#### Random Forest ####
rf = randomForest(Caesarian~., data = data_train)
rfpred_test <- predict(rf, newdata = data_test, type = "class")
Rf_test <- mean(rfpred_test == data_test$Caesarian)

# check confusion matrix and OOB
table(data_test$Caesarian, rfpred_test)
print(rf)
# most important variables --> age, and then blood pressure
varImpPlot(rf)


#### Fold to compare models ####
folds = vfold_cv(caesarians, v=5);
performance = map_dfr(folds$splits, function (x) {
  x.train = as_tibble(x, data = "analysis");
  x.test = as_tibble(x, data = "assessment");
  
  perf_of_bayes = function (m) {
    y_pred = predict(m, newdata = x.test);
    mean(y_pred == x.test$Caesarian)
  };
  
  perf_of_knn = function (k) {
    model = knn(x.train, x.test, cl = x.train$Caesarian, k = k);
    mean(x.test$Caesarian == model)
  };
  
  perf_of = function (m) {
    y_pred = predict(m, newdata = x.test, type = "class");
    mean(y_pred == x.test$Caesarian)
  };
  
  bayes = perf_of_bayes(naiveBayes(x.train$Caesarian~., data = x.train));
  tree_ = perf_of(tree(x.train$Caesarian~., data = x.train));
  cart = perf_of(rpart(x.train$Caesarian~., data = x.train,control=rpart.control(minsplit=10, cp=0)));
  randomForest = perf_of(randomForest(x.train$Caesarian~., data = x.train));
  bagging = perf_of(bagging(x.train$Caesarian~., data = x.train));
  knn01 = perf_of_knn(1);
  knn05 = perf_of_knn(5);
  knn10 = perf_of_knn(10);
  knn = max(max(knn01, knn05), knn10);
  
  tibble( bayes = bayes
          , tree = tree_
          , cart = cart
          , randomForest = randomForest
          , bagging = bagging
          , knn = knn)
});

performance = gather(performance, key="Algorithm", value="Precision");
ggplot(data = performance,aes(x=Algorithm, y=Precision,col=Algorithm)) + geom_boxplot();
