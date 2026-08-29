suppressMessages({library(rjags); library(coda)})
set.seed(123)

train <- read.csv("airline_train_n1200.csv", stringsAsFactors = FALSE)
train$y <- as.integer(train$satisfaction == "satisfied")
std <- function(x) as.numeric(scale(x))

logDepDelay     <- log1p(train$Departure.Delay.in.Minutes)
signedLogArr    <- sign(train$ArrivalDelay.Residual) * log1p(abs(train$ArrivalDelay.Residual))
Age_std         <- std(train$Age)
Seat_std        <- std(train$Seat.comfort)
FlightDist_std  <- std(train$Flight.Distance)
logDepDelay_std <- std(logDepDelay)
obs  <- !is.na(signedLogArr)
mu_a <- mean(signedLogArr[obs]); sd_a <- sd(signedLogArr[obs])
arr_delay_std <- (signedLogArr - mu_a) / sd_a

Class_EcoPlus  <- as.integer(train$Class == "Eco Plus")
Class_Business <- as.integer(train$Class == "Business")
TypeTravel_Personal <- as.integer(train$Type.of.Travel == "Personal Travel")
CustType_disloyal   <- as.integer(train$Customer.Type == "disloyal Customer")

X_dummy <- cbind(Age_std, Seat_std, FlightDist_std, Class_EcoPlus, Class_Business,
                  logDepDelay_std, TypeTravel_Personal, CustType_disloyal)

model_code <- function(prec) sprintf('
model {
  for (i in 1:n) {
    y[i] ~ dbern(p[i])
    logit(p[i]) <- beta0 + inprod(X[i,], beta) + beta_arr * arr_delay[i]
    arr_delay[i] ~ dnorm(0, 1)
  }
  beta0 ~ dnorm(0, %f)
  beta_arr ~ dnorm(0, %f)
  for (j in 1:P) { beta[j] ~ dnorm(0, %f) }
}', prec, prec, prec)

fit_variance <- function(var_beta) {
  prec <- 1 / var_beta
  dataList <- list(y = train$y, X = X_dummy, arr_delay = arr_delay_std,
                    n = nrow(X_dummy), P = ncol(X_dummy))
  m <- jags.model(textConnection(model_code(prec)), data = dataList,
                   n.chains = 3, n.adapt = 500, quiet = TRUE)
  update(m, 1500)
  samples <- coda.samples(m, variable.names = c("beta0","beta","beta_arr"), n.iter = 3000, thin = 2)
  sm <- as.matrix(samples)
  data.frame(mean = colMeans(sm), lo = apply(sm,2,quantile,0.025), hi = apply(sm,2,quantile,0.975))
}

variances <- c(1, 10, 100, 10000)
results <- list()
for (v in variances) {
  cat(format(Sys.time()), "Fitting variance =", v, "\n")
  results[[as.character(v)]] <- fit_variance(v)
}

saveRDS(results, "prior_sweep_results.rds")
cat(format(Sys.time()), "DONE\n")
