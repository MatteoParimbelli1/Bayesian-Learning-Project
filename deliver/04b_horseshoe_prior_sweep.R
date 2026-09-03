suppressMessages({library(rjags); library(coda)})
set.seed(123)

## ---------------------------------------------------------------------------
## Horseshoe prior-sensitivity sweep.
##
## The horseshoe of Section 03 has one prior "knob" that materially controls how
## aggressively it shrinks: the scale s of the half-Cauchy prior on the GLOBAL
## scale tau,  tau ~ C+(0, s).  Small s pulls every coefficient hard towards
## zero (more sparsity); large s relaxes the global shrinkage. We refit the
## exact Section 03 model three times, varying only this global scale
##   s in {0.1, 1, 10}
## (s = 1 is the Section 03 default), and check whether the signal / noise
## classification and the coefficient estimates are robust to it.
##
## In JAGS a half-Cauchy C+(0, s) is a Student-t with 1 d.f. truncated to the
## positive reals; the scale enters as a precision 1/s^2:  dt(0, 1/s^2, 1) T(0,).
## The LOCAL scales lambda[j] keep the standard C+(0,1) as in Section 03.
## ---------------------------------------------------------------------------

## Paths are resolved relative to this script's own location, so it can be run
## from anywhere:  Rscript deliver/horseshoe_prior_sweep.R
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

train <- read.csv(file.path(root, "data/airline_train_n1200.csv"),
                  stringsAsFactors = FALSE)
train$y <- as.integer(train$satisfaction == "satisfied")
std <- function(x) as.numeric(scale(x))

service_items <- c("seat_comfort", "time_convenient", "food_drink", "gate_location",
                   "wifi", "entertainment", "online_support", "ease_booking",
                   "onboard_service", "legroom", "baggage", "checkin",
                   "cleanliness", "online_boarding")
X_service <- apply(train[, service_items], 2, std)

logdep_std     <- std(train$log_dep_delay)
Age_std        <- std(train$age)
FlightDist_std <- std(train$flight_distance)
logmid_delay   <- std(train$log_mid_delay)

Class_EcoPlus  <- as.integer(train$cabin_class == "Eco Plus")
Class_Business <- as.integer(train$cabin_class == "Business")
TypeTravel_Personal <- as.integer(train$travel_type == "Personal Travel")
CustType_disloyal   <- as.integer(train$customer_type == "disloyal Customer")

## Column order must match term_labels below, i.e. X_extra in
## 03_feature_selection.Rmd: Age, Flight Distance, Eco Plus, Business,
## log dep delay, Personal Travel, disloyal Customer.
X_extra <- cbind(Age_std, FlightDist_std, Class_EcoPlus, Class_Business,
                 logdep_std, TypeTravel_Personal, CustType_disloyal)
X_full <- cbind(X_service, X_extra)
P <- ncol(X_full)

term_labels <- c(
  "beta[1]" = "Seat comfort", "beta[2]" = "Dep/Arr time convenient", "beta[3]" = "Food and drink",
  "beta[4]" = "Gate location", "beta[5]" = "Inflight wifi service", "beta[6]" = "Inflight entertainment",
  "beta[7]" = "Online support", "beta[8]" = "Ease of Online booking", "beta[9]" = "On-board service",
  "beta[10]" = "Leg room service", "beta[11]" = "Baggage handling", "beta[12]" = "Checkin service",
  "beta[13]" = "Cleanliness", "beta[14]" = "Online boarding", "beta[15]" = "Age", "beta[16]" = "Flight Distance",
  "beta[17]" = "Class: Eco Plus", "beta[18]" = "Class: Business", "beta[19]" = "log(1+Departure Delay)",
  "beta[20]" = "Personal Travel", "beta[21]" = "disloyal Customer", "beta_arr" = "Mid-flight delay (signed log)"
)

## Section 03 JAGS string, with the global-tau precision (= 1 / s^2) templated in.
model_code <- function(prec_tau) sprintf('
model {
  for (i in 1:n) {
    y[i] ~ dbern(p[i])
    logit(p[i]) <- beta0 + inprod(X[i,], beta) + beta_arr * arr_delay[i]
    log_lik[i] <- logdensity.bern(y[i], p[i])
    arr_delay[i] ~ dnorm(0, 1)
  }
  beta0 ~ dnorm(0, 0.01)

  for (j in 1:P) {
    beta[j] ~ dnorm(0, prec_beta[j])
    prec_beta[j] <- 1 / (lambda[j] * lambda[j] * tau * tau)
    lambda[j] ~ dt(0, 1, 1) T(0, )
  }

  beta_arr ~ dnorm(0, prec_arr)
  prec_arr <- 1 / (lambda_arr * lambda_arr * tau * tau)
  lambda_arr ~ dt(0, 1, 1) T(0, )

  tau ~ dt(0, %f, 1) T(0, )
}', prec_tau)

## MCMC settings match Section 03.
fit_scale <- function(s) {
  prec_tau <- 1 / (s * s)
  dataList <- list(y = train$y, X = X_full, arr_delay = logmid_delay,
                   n = nrow(X_full), P = P)
  m <- jags.model(textConnection(model_code(prec_tau)), data = dataList,
                  n.chains = 3, n.adapt = 5000, quiet = TRUE)
  update(m, 1000)
  samples <- coda.samples(
    m,
    variable.names = c("beta0", "beta", "beta_arr", "lambda", "lambda_arr", "tau"),
    n.iter = 10000, thin = 3)
  sm <- as.matrix(samples)

  beta_names   <- c(paste0("beta[", 1:P, "]"), "beta_arr")
  lambda_names <- c(paste0("lambda[", 1:P, "]"), "lambda_arr")

  beta_mat   <- sm[, beta_names]
  lambda_mat <- sm[, lambda_names]
  kappa_mat  <- 1 / (1 + lambda_mat^2)   # per-predictor shrinkage weight, as in Section 03

  post_beta  <- colMeans(beta_mat)
  post_kappa <- colMeans(kappa_mat)
  beta_ci    <- apply(beta_mat, 2, quantile, c(0.025, 0.975))

  data.frame(
    term      = term_labels[beta_names],
    kappa     = round(post_kappa, 3),
    beta_mean = round(post_beta, 3),
    beta_lo   = round(beta_ci[1, ], 3),
    beta_hi   = round(beta_ci[2, ], 3),
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

global_scales <- c(0.1, 1, 10)
results <- list()
for (s in global_scales) {
  cat(format(Sys.time()), "Fitting global scale s =", s, "\n")
  results[[as.character(s)]] <- fit_scale(s)
}

out_dir <- file.path(root, "data")
saveRDS(results, file.path(out_dir, "04b_horseshoe_sweep.rds"))
cat(format(Sys.time()), "DONE\n")
