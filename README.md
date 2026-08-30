# Airline Customer Satisfaction (BLAMS Final Project 2026)

Bayesian analysis of airline customer satisfaction (Dataset 3), fit with
JAGS/MCMC and cross-checked with BAS.

## Pipeline

Run the notebooks **in order**. Later ones read `.rds` files the earlier
ones save.

| File | What it does | Reads | Writes |
|---|---|---|---|
| `00_data_audit_eda_subsampling.Rmd` | Cleanup, EDA, delay decorrelation, stratified train/test split | `Airline_customer_satisfaction.csv` | `data/train_subsample.csv`, `data/test_holdout.csv` |
| `01_conjugate_baseline.Rmd` | Beta-Binomial baseline, prior sensitivity, subgroup Monte Carlo | train | none |
| `02_core_logistic_jags.Rmd` | Logistic regression, vague N(0,100) priors, 9 predictors; dummy-vs-ordinal and logit-vs-probit via WAIC | train | none |
| `03_horseshoe_shrinkage.Rmd` | Horseshoe shrinkage prior over 22 predictors; shrinkage weights κⱼ, DIC | train | `data/samples_hs.rds`, `data/dic_hs.rds`, `figs/` |
| `04_bas_crosscheck.Rmd` | `bas.lm` (linear probability, as a foil) and `bas.glm` (independent variable selection) | train | `data/bas_glm_fit.rds`, `figs/` |
| `05_waic_sensitivity.Rmd` | WAIC / PSIS-LOO / DIC comparison, Pareto-k diagnostics, prior-variance sweep | train, `samples_hs.rds`, `dic_hs.rds` | `figs/` |
| `06_prediction_validation.Rmd` | Out-of-sample accuracy, confusion matrices, ROC/AUC, calibration | test, `samples_hs.rds`, `bas_glm_fit.rds` | none |

## Setup

JAGS is a **standalone program**, not an R package. Install it before
`rjags`, or the R package will fail to build.

### Option A: conda (isolated, recommended)

Keeps R, JAGS and every package in one environment, removable with
`conda env remove -n blams`. Nothing touches your system R.

```bash
# 1. Install miniforge (skip if you already have conda/mamba)
curl -L -o miniforge.sh \
  "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh"
bash miniforge.sh -b -p "$HOME/miniforge3"

# 2. Create the environment
"$HOME/miniforge3/bin/mamba" create -y -n blams -c conda-forge \
  r-base r-essentials jags r-rjags r-coda r-loo r-dplyr r-tidyr \
  r-ggplot2 r-ggrepel r-rcolorbrewer r-proc r-rmarkdown

# 3. BAS is not on conda-forge, so install it from CRAN inside the env
source "$HOME/miniforge3/etc/profile.d/conda.sh" && conda activate blams
Rscript -e 'install.packages("BAS", repos="https://cloud.r-project.org")'
```

Then, to run anything:

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh" && conda activate blams
Rscript -e 'rmarkdown::render("02_core_logistic_jags.Rmd")'
```

### Option B: system R + RStudio

> **Careful with the JAGS version.** `rjags` needs JAGS **4.x** and won't
> build against JAGS 5:
> `configure: error: pkg-config found JAGS 5.0.0 but rjags requires JAGS 4.x.y`
> `brew install jags` now gives you 5.0.0, so you end up without `rjags` and
> nothing here runs. Get JAGS **4.3.2** from the
> [official installer](https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/)
> instead, or just use Option A (the conda env pins 4.3.2).

1. Install [R](https://cloud.r-project.org) and RStudio.
2. Install [JAGS 4.3.2](https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/)
   (**not** 5.x, see the warning above).
3. In R:

```r
install.packages(c("rjags", "coda", "loo", "BAS", "dplyr", "tidyr",
                   "ggplot2", "ggrepel", "RColorBrewer", "pROC", "rmarkdown"))
```

Then knit each `.Rmd` with the Knit button, in order.

## Notes

- `03` is the slow one. The half-Cauchy priors mix slowly so it needs a long
  burn-in and heavy thinning. Takes a few minutes.
- `06` predicts over all ~128k held-out rows and batches over the posterior
  draws to stay within memory. Don't collapse that loop into one `outer()`
  call, it blows past R's vector memory limit.
- **Rerun `03` if you change the covariates.** `05` and `06` load
  `data/samples_hs.rds`, and if that file is older than the formula in `03`
  the coefficients silently stop matching the design matrix. This already
  happened once and it doesn't error, it just gives wrong numbers.
- Everything uses `set.seed(2026)`. That doesn't fully pin JAGS's internal
  RNG though, so small differences between machines are normal.

## Deliverables (per the project brief)

- Report, PDF, ~8-10 pages + optional appendix. Six required sections:
  data/problem, model specification, posterior analysis (incl. sensitivity
  and which algorithm), model selection/comparison, prediction exercise,
  conclusions. **No code in the report**, it is submitted separately.
- R code files, runnable, lightly commented.
- Slides, 20-25 min. Every member presents a part and can be questioned on
  any part of the code, including sections they did not write.
- **Due at least 3 days before the exam date.**
