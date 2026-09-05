suppressMessages({library(dplyr); library(rjags); library(coda); library(caret)})
set.seed(123)

## Paths are resolved relative to this script's own location, so it can be run
## from anywhere:  Rscript deliver/04d_large_subsample_refit.R
.args <- commandArgs(trailingOnly = FALSE)
.file <- sub("^--file=", "", .args[grep("^--file=", .args)])
# Rscript encodes spaces in --file= as "~+~", which breaks the path on any
# machine whose repo lives under e.g. "My Drive". Decode them back.
.file <- gsub("~\\+~", " ", .file)
root  <- if (length(.file)) {
  normalizePath(file.path(dirname(.file), ".."))
} else {
  normalizePath("..")   # fallback: sourced interactively from deliver/
}

full <- readRDS(file.path(root, "data/airline_full_clean.rds"))
full$y <- as.integer(full$satisfaction == "satisfied")

# Draw a larger, still-tractable stratified subsample (~15,000 rows) as a
# stand-in for "the full 129,880 rows": a genuine full-data JAGS refit is not
# feasible here (cost scales ~linearly with n, and the n=1213 fit already takes
# minutes -- 129,880 rows would take hours). This is disclosed explicitly in the
# write-up.
strata <- interaction(full$satisfaction, full$cabin_class, drop = TRUE)
idx_large <- createDataPartition(y = strata, p = 15000 / nrow(full), list = FALSE)
large <- full[idx_large, ]
cat("Large subsample size:", nrow(large), "\n")

std <- function(x) as.numeric(scale(x))
logDepDelay     <- log1p(large$dep_delay)
Age_std         <- std(large$age)
Seat_std        <- std(large$seat_comfort)
FlightDist_std  <- std(large$flight_distance)
logDepDelay_std <- std(logDepDelay)

# Same delay term as the n=1213 reference fit in 02_logit_model.Rmd, i.e.
# log_mid_delay. This script previously used ArrivalDelay.Residual, which is
# the alternative the appendix rejects; with it, the two fits would differ in
# their covariates as well as in n, and the comparison would say nothing about
# the subsampling decision it is meant to test.
obs  <- !is.na(large$log_mid_delay)
mu_a <- mean(large$log_mid_delay[obs]); sd_a <- sd(large$log_mid_delay[obs])
arr_delay_std <- (large$log_mid_delay - mu_a) / sd_a

Class_EcoPlus  <- as.integer(large$cabin_class == "Eco Plus")
Class_Business <- as.integer(large$cabin_class == "Business")
TypeTravel_Personal <- as.integer(large$travel_type == "Personal Travel")
CustType_disloyal   <- as.integer(large$customer_type == "disloyal Customer")

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
# Column order matches X_dummy in 02_logit_model.Rmd.
rownames(result_tbl) <- c("Age", "Seat comfort", "Flight Distance",
  "Class: Eco Plus", "Class: Business", "log(1+Departure Delay)",
  "Personal Travel", "disloyal Customer", "Mid-flight delay (signed log)",
  "Intercept")[match(rownames(result_tbl),
  c(paste0("beta[",1:8,"]"), "beta_arr", "beta0"))]
print(result_tbl)

saveRDS(list(result_tbl = result_tbl, n_large = nrow(large)), file.path(root, "data/04d_large_subsample_refit.rds"))
cat(format(Sys.time()), "DONE\n")
