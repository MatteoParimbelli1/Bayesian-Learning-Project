suppressMessages({library(rjags); library(coda)})
set.seed(123)

## Paths are resolved relative to this script's own location, so it can be run
## from anywhere:  Rscript deliver/04c_structural_zero_refit.R
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

service_items <- c("seat_comfort", "time_convenient", "food_drink",
                    "gate_location", "wifi", "entertainment",
                    "online_support", "ease_booking", "onboard_service",
                    "legroom", "baggage", "checkin",
                    "cleanliness", "online_boarding")

# Exclude structural-zero flagged rows (same flag definition as Section 00)
zero_share <- sapply(train[, service_items], function(x) mean(x == 0))
zero_candidates <- names(zero_share)[zero_share > 0.02]
flag <- apply(train[, zero_candidates] == 0, 1, any)
cat("Excluding", sum(flag), "structural-zero rows out of", nrow(train), "\n")

sub <- train[!flag, ]

X_service <- apply(sub[, service_items], 2, std)
logDepDelay    <- log1p(sub$dep_delay)
Age_std         <- std(sub$age)
FlightDist_std  <- std(sub$flight_distance)
logDepDelay_std <- std(logDepDelay)

# Use the SAME delay term as the main model (03_feature_selection.Rmd) and the
# prior sweep, i.e. log_mid_delay, the signed log of the arrival-minus-departure
# difference. This script previously used arr_delay_res, the regression residual,
# which is the alternative the appendix explicitly rejected. The two are not the
# same covariate (cor(log_dep_delay, log_mid_delay) = -0.39), so using the
# residual here meant the robustness check was testing a different model from
# the one it is supposed to be checking.
obs  <- !is.na(sub$log_mid_delay)
mu_a <- mean(sub$log_mid_delay[obs]); sd_a <- sd(sub$log_mid_delay[obs])
arr_delay_std <- (sub$log_mid_delay - mu_a) / sd_a

Class_EcoPlus  <- as.integer(sub$cabin_class == "Eco Plus")
Class_Business <- as.integer(sub$cabin_class == "Business")
TypeTravel_Personal <- as.integer(sub$travel_type == "Personal Travel")
CustType_disloyal   <- as.integer(sub$customer_type == "disloyal Customer")

X_extra <- cbind(Age_std, FlightDist_std, Class_EcoPlus, Class_Business,
                  logDepDelay_std, TypeTravel_Personal, CustType_disloyal)
X_full <- cbind(X_service, X_extra)
P <- ncol(X_full)

model_code <- '
model {
  for (i in 1:n) {
    y[i] ~ dbern(p[i])
    logit(p[i]) <- beta0 + inprod(X[i,], beta) + beta_arr * arr_delay[i]
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
  tau ~ dt(0, 1, 1) T(0, )
}'

dataList <- list(y = sub$y, X = X_full, arr_delay = arr_delay_std, n = nrow(X_full), P = P)

cat(format(Sys.time()), "Compiling...\n")
m <- jags.model(textConnection(model_code), data = dataList, n.chains = 3, n.adapt = 500, quiet = TRUE)
cat(format(Sys.time()), "Burn-in...\n")
update(m, 3000)
cat(format(Sys.time()), "Sampling...\n")
samples <- coda.samples(m, variable.names = c("beta0","beta","beta_arr","lambda","lambda_arr","tau"),
                         n.iter = 4000, thin = 3)

sm <- as.matrix(samples)
beta_cols <- c(paste0("beta[",1:P,"]"), "beta_arr")
lambda_cols <- c(paste0("lambda[",1:P,"]"), "lambda_arr")
post_beta <- colMeans(sm[, beta_cols])
post_kappa <- colMeans(1 / (1 + sm[, lambda_cols]^2))
names(post_kappa) <- beta_cols
beta_ci <- apply(sm[, beta_cols], 2, quantile, c(0.025,0.975))

term_labels <- c("beta[1]"="Seat comfort","beta[2]"="Dep/Arr time convenient","beta[3]"="Food and drink",
"beta[4]"="Gate location","beta[5]"="Inflight wifi service","beta[6]"="Inflight entertainment",
"beta[7]"="Online support","beta[8]"="Ease of Online booking","beta[9]"="On-board service",
"beta[10]"="Leg room service","beta[11]"="Baggage handling","beta[12]"="Checkin service",
"beta[13]"="Cleanliness","beta[14]"="Online boarding","beta[15]"="Age","beta[16]"="Flight Distance",
"beta[17]"="Class: Eco Plus","beta[18]"="Class: Business","beta[19]"="log(1+Departure Delay)",
"beta[20]"="Personal Travel","beta[21]"="disloyal Customer",
# was "Arrival delay residual"; the model now uses log_mid_delay, matching
# 03_feature_selection.Rmd and horseshoe_prior_sweep.R
"beta_arr"="Mid-flight delay (signed log)")

result_tbl <- data.frame(term = term_labels[beta_cols], kappa = round(post_kappa[beta_cols],3),
                          beta_mean = round(post_beta,3), beta_lo = round(beta_ci[1,],3), beta_hi = round(beta_ci[2,],3))
print(result_tbl[order(result_tbl$kappa),], row.names = FALSE)

saveRDS(list(result_tbl = result_tbl, n_excluded = sum(flag), n_remaining = nrow(sub)),
        file.path(root, "data/04c_structural_zero_refit.rds"))
cat(format(Sys.time()), "DONE\n")
