# Report audit, 5 September 2026

Everything in the report that carries a number was checked against the `.rds`
files the code writes. What follows is what was wrong, what was fixed, and what
was verified and left alone.

The report now compiles with **0 errors, 0 unresolved references and 0
duplicate labels**, at 22 pages.

---

## Fixed

### 1. Five duplicate labels

The same figures and tables were defined twice, once in a chapter and once in
the appendix. LaTeX resolved each `\ref` to whichever came last, and the
duplicates inflated the numbering: the report showed 20 tables and 14 figures
where it has 15 and 10.

| label | appeared as |
|---|---|
| `tab:mcmc_settings` | Table 2 **and** Table 16 |
| `tab:hs_mcmc_settings` | Table 4 **and** Table 17 |
| `fig:hs_trace_beta`, `fig:hs_trace_lambda` | Figure 3 **and** Figures 11-12 |
| `tab:hs-kappa` | Table 7 **and** Table 18 |

Removed the appendix copies. Every `\ref` in the prose points at the chapter
copy, so nothing else had to change. The document dropped from 24 pages to 22.

These are leftovers: the material was moved to the appendix during an earlier
round of page-count cutting, then the chapters were restored without the
appendix copies being taken back out.

### 2. A stray Romanian comment

`% ---- mutate din corp pentru a respecta limita de pagini ----` in
`appendix/bas_comparison.tex`. Mine, from the same round. Removed.

### 3. Two false claims in Section 4.5

**"Inflight wifi service, the single most shrunk item in the whole model"** is
wrong. Wifi has $\kappa_j = 0.722$; five predictors are shrunk harder:

| | $\kappa_j$ |
|---|---|
| Gate location | 0.768 |
| Mid-flight delay | 0.767 |
| Flight Distance | 0.762 |
| Age | 0.757 |
| Online boarding | 0.727 |
| **Inflight wifi service** | **0.722** |

Even inside its own booking/connectivity cluster, Online boarding is shrunk
slightly harder. Replaced with a statement that both sit among the most heavily
shrunk items, quoting $\kappa_j = 0.73$ and $0.72$.

**"Personal Travel ... one of the strongest and most confidently negative
effects in the model, with a credible interval lying entirely below zero"**
overstates it. The interval is $[-1.021, -0.004]$: it clears zero by four
thousandths. By comparison, *disloyal Customer* sits at $[-2.307, -1.221]$.
Kept the negative finding, added "although only just" and the interval.

---

## Verified and correct

| what | result |
|---|---|
| `tab:prior-range`, 10 rows | 10/10 match |
| `tab:hs-range`, 8 rows | 8/8 |
| `tab:hs-kappa`, 22 predictors x 3 global scales | 22/22 |
| `tab:hs-signal`, the $\kappa_j < 0.5$ verdicts | 22/22 |
| `tab:structzero`, 22 rows x 4 values | 22/22 |
| Table 10, the new PSIS-LOO comparison | correct |
| base counts: 1213, 1103, 110, 128274, 15003, 129487 | all correct |

On the PSIS-LOO table: elpd $-686.6$ and $-491.9$, SE $16.7$ and $21.2$,
$p_{\text{loo}}$ $10.4$ and $21.8$, $\Delta$elpd $194.8$ at SE $17.5$, so $11.1$
standard errors. WAIC for the logit is $1373.2$, and neither model has a single
Pareto $k$ above $0.7$. The LOO-IC figures differ in the last decimal, $1373.4$
against $1373.3$ and $983.7$ against $983.8$; that is the spread between two
MCMC runs, not an error. Re-running `02` and `03` moves coefficients by at most
$0.019$ on the log-odds scale and changes no signal/noise verdict.

---

## Corrections made by the team, confirmed against the data

The Business-class paragraph in Section 4.5 was already fixed before this
audit. The data agrees with the corrected text: $\beta = +0.898$, credible
interval $[0.431, 1.348]$, $\kappa_j = 0.186$. It shrinks from an odds ratio of
$4.26$ in Section 3 to $2.45$, so "shrinks markedly" holds, but the interval
never crosses zero and the horseshoe keeps it as the third least shrunk
coefficient in the model. A detail worth knowing: it is not quite the largest
odds ratio, *Inflight entertainment* is marginally ahead at $2.47$.

In Chapter 6, `1203` was corrected to `1213`, which fixes an error of mine; the
training set does have 1213 records. The limitation about encoding and link
choices being settled on training WAIC was removed, correctly, since
out-of-sample validation was added for that section.

---

# Second pass, ten checks

Ten separate sweeps over the report and the code, each looking for a different
class of mistake.

## Fixed

**Cross-references.** Two floats were never referred to in the prose: Figure 9,
the posterior predictive check, and Table 13, the loss-function cutoffs. Both
now have a sentence pointing at them. Chapter 1 said "in Appendix~A" with the
letter typed by hand, which breaks the moment an appendix is added or reordered;
it is now `\ref{app:data_aug}`.

**Notation: `\tau` meant two different things.** In Chapter 3 it was the JAGS
precision, $1/\sigma^2 = 0.01$. In Chapters 4 and 5 it is the horseshoe global
scale. Same symbol, unrelated quantities, adjacent chapters. Chapter 3 no longer
names the precision.

**Notation: one coefficient, two names.** Chapter 3 wrote $\beta_{\text{mid}}$
with `midflight_delay`; Chapters 4 and 6 wrote $\beta_{\text{arr}}$ with
`arr_delay`. Nine symbols unified on `mid`. That is the accurate name: the
covariate is `log_mid_delay`, and `arr_delay` invites confusion with the arrival
delay residual, which Appendix A explicitly rejects.

**Citations.** The report used six standard methods and cited the source of none
of them: the horseshoe (41 mentions, pointing only at the course book), PSIS-LOO,
WAIC, BAS, Gelman-Rubin and the Brier score. Added Carvalho, Polson and Scott
(2010); Vehtari, Gelman and Gabry (2017); Watanabe (2010); Clyde, Ghosh and
Littman (2011); Gelman and Rubin (1992); Brier (1950); and Plummer (2003) for
JAGS. The bibliography goes from 2 entries to 9, 8 of them cited. **Worth
spot-checking the volume and page numbers before submission.**

**Sample size.** Section 3.2 said the training size is $n = 1200$; it is 1213.

**Typos.** `skeweness` twice and `covriates` once in Appendix A;
`Disloyal Customer` capitalised in one table row where the other ten uses are
lower case; `Tab.\ref` with no space, which renders as "Tab.13".

**A leftover `% NOTE:` comment** in Chapter 4.

**One I introduced and caught.** The PSIS-LOO citation first landed inside a
`\subsection{}` heading, which would have carried it into the table of contents
and the PDF bookmarks. Moved into the caption.

## Checked and clean

Every odds ratio quoted in Chapter 3 matches the posterior draws: Seat comfort
1.88 [1.62, 2.16], disloyal Customer 0.16 [0.11, 0.24], departure delay 0.79
[0.69, 0.93], Personal Travel [0.61, 1.18]. Bibliography keys all resolve, no
entry is uncited. Every one of the six sections the brief requires is present,
including model comparison, which is Section 5.5.

The code: all eight files that draw random numbers set a seed, `bas.glm` is
seeded before each call, there is no `install.packages` inside a chunk, no
absolute paths, and the AUC rank statistic casts its class counts with
`as.numeric()`.

Matteo's out-of-sample validation checks out. His standardisation uses training
means and standard deviations, and neither delay column has missing values, so
nothing silently becomes `NA`. His prediction matrix reaches 1.3 GB at 1284
draws by 128,274 rows, which is large but holds.

## Still open

The factor levels at `deliver/01_data_exploration.Rmd:42`, recorded in TODO.md.
`Customer.Type` and `Type.of.Travel` are built with `factor()` and no explicit
`levels`, so their order follows the machine's locale. Since `customer_type` is
one of the stratification variables, a different machine draws a different
train/test split: 508 of 1213 rows in common when tested. Two lines to fix, but
it changes the results unless the current order is pinned.

---

# Before submitting

## Someone has to check these; I could not

- **The seven new bibliography entries.** Authors, titles, years and journals I
  am confident about; volume and page numbers came from memory, not from the
  papers. Ten minutes on Google Scholar settles it. They are in `biblio.bib`:
  `carvalho2010horseshoe`, `vehtari2017loo`, `watanabe2010waic`,
  `clyde2011bas`, `gelman1992rubin`, `brier1950`, `plummer2003jags`.
- **The three generated appendices** (feature selection, parameter-space
  convergence, BAS vs horseshoe). Nobody on the team has read them.
- **Whether `.Rmd` counts as the code deliverable**, or whether plain `.R` is
  expected. Worth one question to the professor.

## Page count

The body is 15 printed pages against a target of 8 to 10. TODO.md lists what
could still come out, roughly four pages' worth, ranked by how little is lost:
Table 8 (`tab:hs-signal`) is `tab:hs-kappa` with a threshold applied and carries
no information of its own; Table 6 can drop to the ten rows the prose actually
discusses; and four subsections run 40 to 52 lines each for conclusions that are
a sentence long.

## What to upload to Overleaf

Everything below is in `report_backup/`, same paths.

| file | why |
|---|---|
| `biblio.bib` | seven new entries |
| `chapters/00_prob_desc_data_expl.tex` | hardcoded "Appendix A", JAGS citation |
| `chapters/02_logit_model.tex` | $n=1200 \to 1213$, tau collision, two citations |
| `chapters/03_horseshoe_model.tex` | the two false claims, notation, horseshoe citation |
| `chapters/04_sensitivity.tex` | citation moved out of a heading, capitalisation |
| `chapters/05_prediction.tex` | notation, two unreferenced floats |
| `appendix/bas_comparison.tex` | five duplicate labels removed, BAS citation |
| `appendix/data_aug.tex` | two typos, `Tab.~\ref` spacing |

`main.tex` and the images are unchanged.

**Careful:** the team edits the same project. Two rounds of work have already
been lost to a download overwriting local edits, and the five duplicate labels
existed because an earlier round of moves was uploaded and then half reverted.
Check what is in Overleaf before overwriting anything.

## State at the end of this audit

22 pages. No LaTeX errors, no unresolved references, no unresolved citations, no
duplicate labels, and every float referred to somewhere in the prose.

Every number in the report has been checked against the `.rds` files the code
writes: the five sensitivity tables row by row, all four odds ratios in Chapter
3, the PSIS-LOO table, and every sample-size figure. The two that were wrong are
fixed and listed above.

---

# Third pass: the reasoning, not the tables

Forty-nine claims were extracted from the prose, every sentence containing a
superlative, a ranking, a count or a quantifier, and each was checked against the
data. Four were wrong.

## Wrong

**Chapter 3 ranked the effects incorrectly.** The text said "by far the largest
is the class" and called Seat comfort "the second strongest driver". By
magnitude the order is customer loyalty ($\bar\beta = -1.83$), then Business
class ($+1.45$), then Seat comfort ($+0.63$). Loyalty is the largest effect and
Seat comfort is third. The paragraph did mention loyalty, but two sentences
later and as an afterthought. Rewritten to give the real order, with the
coefficients quoted so the ranking can be checked at a glance.

**Table 3 named the wrong variable.** One row read "Arrival delay residual
(signed-log)". The model uses `log_mid_delay`, the plain signed-log difference
between arrival and departure delay. The residual is the alternative Appendix A
explicitly rejects, so the table advertised a variable the project decided
against. The value, $-0.041$, was right; only the label was wrong. The prose
repeated the error two paragraphs later, calling it the "mid-flight delay
residual"; it is not a residual.

**The conclusions put three unrelated items in one cluster.** The text had
*Inflight entertainment*, *Inflight wifi service* and *Gate location* "sitting in
the same correlated clusters". They do not:

| | entertainment | wifi | gate location |
|---|---|---|---|
| entertainment | 1.00 | 0.31 | **-0.06** |
| wifi | 0.31 | 1.00 | **0.03** |

Gate location correlates with `food_drink` (0.51) and `time_convenient` (0.52),
so it belongs to the seat/catering/ground cluster that Section 5.3 describes
correctly. Wifi belongs to the booking cluster, where it correlates 0.67 with
`Online boarding`. The sentence merged three separate clusters into one.
Rewritten around the one comparison that holds.

**The same sentence mis-ranked two effects.** It read "Customer loyalty is the
strongest ... *Business* class follows". Business is third: loyalty
($\kappa_j = 0.070$), then Inflight entertainment ($0.171$), then Business
($0.186$). Entertainment and Business are effectively tied, $0.906$ against
$0.898$ in coefficient, so the fix says so rather than inventing a gap.

## Checked and correct

Every remaining claim holds:

- *Departure/Arrival time convenient* does have the largest share of structural
  zeros, 6.3%, and does sit in a cluster with Gate location (0.52), Food and
  drink (0.48) and Seat comfort (0.35).
- The eleven covariates listed as signal at $s = 1$ are exactly the eleven with
  $\kappa_j < 0.5$.
- *disloyal Customer* is the least shrunk coefficient at all three global scales,
  0.052, 0.071 and 0.076.
- Business, entertainment and loyalty are indeed the three least shrunk.
- *Inflight entertainment* is the best-preserved of the fourteen service items.
- The largest movement across global scales is 0.018; the largest across prior
  variances is 0.066; exactly one predictor of twenty-two changes verdict.
- 129,880 records and 22 columns in the raw file; classes split 54.7 / 45.3; the
  training base rate is 0.546; the held-out set is 128,274 rows.
- Every odds ratio and credible interval quoted in Chapter 3.
- Every calibration decile, the AUC of 0.900, the Brier score of 0.126 and the
  accuracy of 82.8%.

## No fabrications

Nothing in the report describes a quantity the code does not compute. The four
errors were all misreadings of real output: a ranking taken from the wrong
column, a label carried over from a variable that was dropped, and a cluster
claim that was never checked against the correlation matrix.
