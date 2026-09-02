suppressMessages({library(rjags); library(coda); library(here)})
set.seed(123)

# it might be necessary to djust th path
train <- read.csv(here("project/data/airline_train_n1200.csv"), stringsAsFactors = FALSE)
train$y <- as.integer(train$satisfaction == "satisfied")
std <- function(x) as.numeric(scale(x))

Age_std         <- std(train$age)
Seat_std        <- std(train$seat_comfort)
FlightDist_std  <- std(train$flight_distance)
logDepDelay_std <- std(train$log_dep_delay)
logMidDelay_std   <- std(train$log_mid_delay)

Class_EcoPlus  <- as.integer(train$cabin_class == "Eco Plus")
Class_Business <- as.integer(train$cabin_class == "Business")
TypeTravel_Personal <- as.integer(train$travel_type == "Personal Travel")
CustType_disloyal   <- as.integer(train$customer_type == "disloyal Customer")

X_dummy <- cbind(Age_std, Seat_std, FlightDist_std, Class_EcoPlus, Class_Business,
                 logDepDelay_std, TypeTravel_Personal, CustType_disloyal)

## Same likelihood as Section 02; only the prior precision (= 1 / prior variance)
## on every coefficient is swept.

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
  dataList <- list(y = train$y, X = X_dummy, arr_delay = logMidDelay_std,
                   n = nrow(X_dummy), P = ncol(X_dummy))
  m <- jags.model(textConnection(model_code(prec)), data = dataList,
                  n.chains = 3, n.adapt = 500, quiet = TRUE)
  update(m, 1500)
  samples <- coda.samples(m, variable.names = c("beta0", "beta", "beta_arr"),
                          n.iter = 3000, thin = 2)
  sm <- as.matrix(samples)
  data.frame(mean = colMeans(sm),
             lo = apply(sm, 2, quantile, 0.025),
             hi = apply(sm, 2, quantile, 0.975))
}

variances <- c(1, 10, 100, 10000)
results <- list()
for (v in variances) {
  cat(format(Sys.time()), "Fitting variance =", v, "\n")
  results[[as.character(v)]] <- fit_variance(v)
}

saveRDS(results, here("project/data/sensitivity/logit_prior_sweep_results.rds"))
cat(format(Sys.time()), "DONE\n")
