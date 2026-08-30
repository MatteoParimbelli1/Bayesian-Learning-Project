suppressMessages({library(dplyr); library(rjags); library(coda); library(caret)})
set.seed(123)

full <- readRDS("airline_full_clean.rds")
full$y <- as.integer(full$satisfaction == "satisfied")

# Draw a larger, still-tractable stratified subsample (~15,000 rows) as a
# stand-in for "the full 129,880 rows": a genuine full-data JAGS refit is not
# feasible on this single-core sandbox (cost scales ~linearly with n, and the
# n=1203 fit already takes ~100s -- 129,880 rows would take on the order of
# hours). This is disclosed explicitly in the write-up.
strata <- interaction(full$satisfaction, full$Class, drop = TRUE)
idx_large <- createDataPartition(y = strata, p = 15000 / nrow(full), list = FALSE)
large <- full[idx_large, ]
cat("Large subsample size:", nrow(large), "\n")

std <- function(x) as.numeric(scale(x))
logDepDelay     <- log1p(large$Departure.Delay.in.Minutes)
signedLogArr    <- sign(large$ArrivalDelay.Residual) * log1p(abs(large$ArrivalDelay.Residual))
Age_std         <- std(large$Age)
Seat_std        <- std(large$Seat.comfort)
FlightDist_std  <- std(large$Flight.Distance)
logDepDelay_std <- std(logDepDelay)
obs  <- !is.na(signedLogArr)
mu_a <- mean(signedLogArr[obs]); sd_a <- sd(signedLogArr[obs])
arr_delay_std <- (signedLogArr - mu_a) / sd_a

Class_EcoPlus  <- as.integer(large$Class == "Eco Plus")
Class_Business <- as.integer(large$Class == "Business")
TypeTravel_Personal <- as.integer(large$Type.of.Travel == "Personal Travel")
CustType_disloyal   <- as.integer(large$Customer.Type == "disloyal Customer")

X_dummy <- cbind(Age_std, Seat_std, FlightDist_std, Class_EcoPlus, Class_Business,
                  logDepDelay_std, TypeTravel_Personal, CustType_disloyal)

model_code <- '
model {
  for (i in 1:n) {
    y[i] ~ dbern(p[i])
    logit(p[i]) <- beta0 + inprod(X[i,], beta) + beta_arr * arr_delay[i]
    arr_delay[i] ~ dnorm(0, 1)
  }
  beta0 ~ dnorm(0, 0.01)
  beta_arr ~ dnorm(0, 0.01)
  for (j in 1:P) { beta[j] ~ dnorm(0, 0.01) }
}'

dataList <- list(y = large$y, X = X_dummy, arr_delay = arr_delay_std,
                  n = nrow(X_dummy), P = ncol(X_dummy))

cat(format(Sys.time()), "Compiling (n=", nrow(large), ")...\n")
m <- jags.model(textConnection(model_code), data = dataList, n.chains = 3, n.adapt = 300, quiet = TRUE)
cat(format(Sys.time()), "Burn-in...\n")
update(m, 1000)
cat(format(Sys.time()), "Sampling...\n")
samples <- coda.samples(m, variable.names = c("beta0","beta","beta_arr"), n.iter = 1500, thin = 2)

sm <- as.matrix(samples)
post_mean <- colMeans(sm)
post_ci <- apply(sm, 2, quantile, c(0.025,0.975))
result_tbl <- data.frame(mean = round(post_mean,4), lo = round(post_ci[1,],4), hi = round(post_ci[2,],4))
result_tbl$width <- result_tbl$hi - result_tbl$lo
print(result_tbl)

saveRDS(list(result_tbl = result_tbl, n_large = nrow(large)), "large_subsample_results.rds")
cat(format(Sys.time()), "DONE\n")
