# Airline Customer Satisfaction (BLAMS Final Project 2026)

Bayesian analysis of airline customer satisfaction (Dataset 3), fit with
JAGS/MCMC and cross-checked with BAS.

## Layout

`deliver/` holds the pipeline behind the report: one notebook per chapter,
plus the standalone sensitivity scripts. `src/` keeps the earlier exploratory
notebooks, which are not part of the deliverable but are where several of the
modelling choices were actually settled.

Both directories are numbered, but **the two numberings are not the same
scheme**, which is easy to trip over. `deliver/` is numbered by report chapter.
`src/` is numbered by the order the exploration happened in, which is where the
chapter order originally came from but has since drifted from it.

### `deliver/` — run in order

| File | What it does | Reads | Writes |
|---|---|---|---|
| `01_data_exploration.Rmd` | Cleanup, EDA, delay decorrelation, stratified train/test split | `data/Airline_customer_satisfaction.csv` | `data/airline_train_n1200.csv`, `data/airline_test_holdout.csv`, `data/airline_full_clean.rds` |
| `02_logit_model.Rmd` | Logistic regression, vague N(0,100) priors, 9 predictors; dummy-vs-ordinal and logit-vs-probit via WAIC | train | `data/02_logit_mcmc.rds` |
| `03_feature_selection.Rmd` | Horseshoe shrinkage prior over 22 predictors; shrinkage weights κⱼ, DIC | train | `data/03_horseshoe_final.rds`, `data/03_horseshoe_summary.rds` |
| `04_models_sensitivity.Rmd` | Prior sweeps, structural-zero refit, large-subsample refit | `04a`–`04d` output in `data/` | `figs/` |
| `05_prediction_validation.Rmd` | Out-of-sample accuracy, ROC/AUC, calibration, posterior predictive checks | test, `02_logit_mcmc.rds`, `03_horseshoe_final.rds`, `A01_BAS_model.rds` | `figs/ppc_subgroups.png` |
| `A01_BAS_comparison.Rmd` (appendix) | `bas.glm` cross-check, BMA over the model space | train | `data/A01_BAS_model.rds` |

### `deliver/` — sensitivity scripts

The `04x` prefix means they belong to chapter 4: they do the actual refitting,
`04_models_sensitivity.Rmd` only reads their output. They are plain `.R` rather
than notebooks because each one runs for minutes to the better part of an hour,
which is too slow to sit inside a knit. Each resolves paths from its own
location, so it runs from anywhere, and writes a single `.rds` into `data/`
named after itself. The results are committed, so normally you don't have to
run them at all.

`04d` is the exception: it is not part of chapter 4, which covers three checks,
not four. It refits the model on a subsample an order of magnitude larger, an
analysis the team ran once early on and then lost when the cache it wrote was
never committed. It still runs, and its output is not referenced by any chapter,
so it is kept as a loose end rather than a step in the pipeline.

```bash
Rscript deliver/04a_prior_sweep.R              # ~4 min
Rscript deliver/04c_structural_zero_refit.R    # ~4 min
Rscript deliver/04d_large_subsample_refit.R    # ~25 min, see note below
Rscript deliver/04b_horseshoe_prior_sweep.R    # ~45 min
```

Timings are for an M2 Pro. On a single-core container they are roughly an
hour each, which is where the original estimate in the notebooks comes from.

## `src/` — exploratory, superseded

Kept for the record, not for running. Three of these read files the
restructure removed, so they no longer knit as-is.

| `src/` | superseded by | in the report? |
|---|---|---|
| `00_data_audit_and_eda.Rmd`, `00.1_data_audit_eda_subsampling.Rmd` | `deliver/01_data_exploration.Rmd` | yes, ch. 1 |
| `01_conjugate_baseline.Rmd` | — | **no** |
| `02_bayesian_logistic_jags.Rmd` | `deliver/02_logit_model.Rmd` | yes, ch. 3 |
| `02.1_logit_models.Rmd` (Zellner's g-prior) | — | **no** |
| `03_horseshoe_shrinkage.Rmd` | `deliver/03_feature_selection.Rmd` | yes, ch. 4 |
| `04_bas_crosscheck.Rmd` | `deliver/A01_BAS_comparison.Rmd` | yes, appendix B |
| `05_model_comparison_sensitivity.Rmd` | `deliver/04_models_sensitivity.Rmd` | yes, ch. 5 |
| `prior_sweep.R` | `deliver/04a_prior_sweep.R` | yes, ch. 5 |

Two of them have no counterpart anywhere and their results appear nowhere in
the report: the Beta-Binomial conjugate baseline, and the reference-prior /
Zellner g-prior comparison. Both are course-syllabus material, so they are the
obvious candidates if a section needs adding rather than cutting.

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
  r-ggplot2 r-rcolorbrewer r-rmarkdown r-bayesplot r-caret r-corrplot r-here

# 3. BAS is not on conda-forge, so install it from CRAN inside the env
source "$HOME/miniforge3/etc/profile.d/conda.sh" && conda activate blams
Rscript -e 'install.packages("BAS", repos="https://cloud.r-project.org")'
```

Then, to run anything:

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh" && conda activate blams
Rscript -e 'rmarkdown::render("deliver/02_logit_model.Rmd")'
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
                   "ggplot2", "RColorBrewer", "rmarkdown",
                   "bayesplot", "caret", "corrplot", "here"))
```

Then knit each `.Rmd` with the Knit button, in order.

## Notes

- `03` is the slow one. The half-Cauchy priors mix slowly so it needs a long
  burn-in and heavy thinning. Takes a few minutes.
- `05` predicts over all ~128k held-out rows and batches over the posterior
  draws to stay within memory. Don't collapse that loop into one `outer()`
  call, it blows past R's vector memory limit.
- **Rerun `03` if you change the covariates.** `04` and `05` load
  `data/03_horseshoe_final.rds`, and if that file is older than the formula in
  `03` the coefficients silently stop matching the design matrix. This already
  happened once and it doesn't error, it just gives wrong numbers.
- The delay term is `log_mid_delay`, the signed log of arrival minus departure.
  The residual `arr_delay_res` is the alternative the appendix rejects; the two
  are not interchangeable (`cor = -0.39`), so don't swap one for the other.
- Computing AUC by the rank statistic needs `as.numeric()` on the class counts:
  on the full holdout $n_1 n_0 \approx 4\times10^9$ overflows R's integer type
  and returns `NA` without warning.
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
