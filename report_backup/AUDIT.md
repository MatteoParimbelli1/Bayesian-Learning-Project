# Report audit, 5 September 2026

Every number in the report was checked against the `.rds` files the code writes,
and every claim in the prose against the data behind it. Three passes: the
tables, then ten structural sweeps, then the reasoning.

**23 issues found and fixed. 1 still open.** Numbered below so they can be
referred to individually.

The report now compiles at 22 pages with no LaTeX errors, no unresolved
references, no unresolved citations, no duplicate labels, and every float
referred to somewhere in the prose.

---

# Substantive errors

Things a reader could act on and be wrong.

### 1. The conclusions put three unrelated items in one cluster

The text had *Inflight entertainment*, *Inflight wifi service* and *Gate
location* "sitting in the same correlated clusters". They do not:

| | entertainment | wifi | gate location |
|---|---|---|---|
| entertainment | 1.00 | 0.31 | **-0.06** |
| wifi | 0.31 | 1.00 | **0.03** |

Gate location correlates with `food_drink` (0.51) and `time_convenient` (0.52),
so it belongs to the seat/catering/ground cluster that Section 5.3 describes
correctly. Wifi belongs to the booking cluster, where it correlates 0.67 with
`Online boarding`. Three separate clusters merged into one sentence. Rewritten
around the one comparison that holds.

### 2. Chapter 3 ranked the effects incorrectly

"By far the largest is the class", and Seat comfort called "the second strongest
driver". By magnitude the order is customer loyalty ($\bar\beta = -1.83$),
Business class ($+1.45$), Seat comfort ($+0.63$). Loyalty is the largest effect
and Seat comfort is third. The paragraph did mention loyalty, but two sentences
later and as an afterthought. Rewritten with the coefficients quoted so the
ranking can be checked at a glance.

### 3. Table 3 named a variable the project rejected

One row read "Arrival delay residual (signed-log)". The model uses
`log_mid_delay`, the plain signed-log difference between arrival and departure
delay. The residual is the alternative Appendix A explicitly rejects, so the
table advertised a variable the project decided against. The value, $-0.041$,
was right; only the label was wrong.

### 4. The same error repeated in the prose

Two paragraphs below Table 3, the text called it the "mid-flight delay
residual". It is not a residual.

### 5. "Inflight wifi service, the single most shrunk item in the whole model"

False. Wifi sits at $\kappa_j = 0.722$, behind Gate location (0.768),
Mid-flight delay (0.767), Flight Distance (0.762), Age (0.757) and Online
boarding (0.727). Sixth, not first. Even inside its own booking cluster, Online
boarding is shrunk harder. Replaced with a statement that both are among the
most heavily shrunk, quoting the values.

### 6. "Personal Travel, one of the most confidently negative effects"

The interval is $[-1.021, -0.004]$: it clears zero by four thousandths. By
comparison *disloyal Customer* sits at $[-2.307, -1.221]$. The negative finding
stands; the confidence claim does not. Kept the finding, added "although only
just" and the interval.

### 7. Business class ranked second instead of third

The conclusions read "Customer loyalty is the strongest ... *Business* class
follows". Business is third: loyalty ($\kappa_j = 0.070$), Inflight
entertainment ($0.171$), Business ($0.186$). Entertainment and Business are
effectively tied, $0.906$ against $0.898$ in coefficient, so the fix says so
rather than inventing a gap.

### 8. Wrong training-set size

Section 3.2 said $n = 1200$. It is 1213.

---

# Structural errors

Things that break the document rather than mislead about the data.

### 9-13. Five duplicate labels

The same figures and tables were defined twice, once in a chapter and once in
the appendix. LaTeX resolved each `\ref` to whichever came last, and the extra
copies inflated the numbering: the report showed 20 tables and 14 figures where
it has 15 and 10.

| # | label | appeared as |
|---|---|---|
| 9 | `tab:mcmc_settings` | Table 2 **and** Table 16 |
| 10 | `tab:hs_mcmc_settings` | Table 4 **and** Table 17 |
| 11 | `fig:hs_trace_beta` | Figure 3 **and** Figure 11 |
| 12 | `fig:hs_trace_lambda` | Figure 3 **and** Figure 12 |
| 13 | `tab:hs-kappa` | Table 7 **and** Table 18 |

Removed the appendix copies; every `\ref` in the prose points at the chapter
copy. The document dropped from 24 pages to 22.

These were leftovers: the material was moved to the appendix during an earlier
round of page-count cutting, then the chapters were restored without the
appendix copies being taken back out.

### 14. Figure 9 was never referred to in the prose

The posterior predictive check appeared with nothing pointing at it.

### 15. Table 13 was never referred to in the prose

Same, for the loss-function cutoffs.

### 16. A hardcoded appendix letter

Chapter 1 read "in Appendix~A" with the letter typed by hand, which breaks the
moment an appendix is added or reordered. Now `\ref{app:data_aug}`.

---

# Notation

### 17. `\tau` meant two different things

In Chapter 3 it was the JAGS precision, $1/\sigma^2 = 0.01$. In Chapters 4 and
5 it is the horseshoe global scale. Same symbol, unrelated quantities, adjacent
chapters. Chapter 3 no longer names the precision.

### 18. One coefficient, two names

Chapter 3 wrote $\beta_{\text{mid}}$ with `midflight_delay`; Chapters 4 and 6
wrote $\beta_{\text{arr}}$ with `arr_delay`. Nine symbols unified on `mid`.
That is the accurate name: the covariate is `log_mid_delay`, and `arr_delay`
invites exactly the confusion behind issues 3 and 4.

---

# Scholarship

### 19. Six methods used, none of them cited

The report leaned on the horseshoe prior (41 mentions, pointing only at the
course book), PSIS-LOO, WAIC, BAS, Gelman-Rubin and the Brier score, and cited
the source of none of them. Added Carvalho, Polson and Scott (2010); Vehtari,
Gelman and Gabry (2017); Watanabe (2010); Clyde, Ghosh and Littman (2011);
Gelman and Rubin (1992); Brier (1950); and Plummer (2003) for JAGS. The
bibliography goes from 2 entries to 9, 8 of them cited.

**The volume and page numbers came from memory, not from the papers. Check them
before submitting.**

---

# Presentation

### 20. Typos in Appendix A

`skeweness` twice, `covriates` once.

### 21. Inconsistent capitalisation

`Disloyal Customer` in one table row against ten lower-case uses elsewhere.

### 22. `Tab.\ref` with no space

Renders as "Tab.13".

### 23. A leftover comment

`% NOTE:` in Chapter 4, and a Romanian comment of mine,
`% ---- mutate din corp pentru a respecta limita de pagini ----`, in the
appendix.

### 24. One I introduced and caught

The PSIS-LOO citation first landed inside a `\subsection{}` heading, which
would have carried it into the table of contents and the PDF bookmarks. Moved
into the caption.

---

# Still open

### 25. Factor levels make the train/test split machine-dependent

`deliver/01_data_exploration.Rmd:42`. `Customer.Type` and `Type.of.Travel` are
built with `factor()` and no explicit `levels`, so their order follows the
machine's locale collation. Since `customer_type` is one of the stratification
variables, a different machine draws a different split: 508 of 1213 rows in
common when tested. Two lines to fix, but it changes the results unless the
current order is pinned:

```r
Customer.Type  = factor(Customer.Type,
                        levels = c("disloyal Customer", "Loyal Customer")),
Type.of.Travel = factor(Type.of.Travel,
                        levels = c("Business travel", "Personal Travel"))
```

---

# Checked and correct

Forty-nine claims were extracted from the prose, every sentence carrying a
superlative, a ranking, a count or a quantifier. Seven were wrong, listed above.
The rest hold.

**Tables, value by value.** `tab:prior-range` 10/10, `tab:hs-range` 8/8,
`tab:hs-kappa` 22 predictors across 3 scales, `tab:hs-signal` 22 verdicts,
`tab:structzero` 22 rows by 4 values. Every odds ratio and credible interval in
Chapter 3: Seat comfort 1.88 [1.62, 2.16], disloyal Customer 0.16 [0.11, 0.24],
departure delay 0.79 [0.69, 0.93], Personal Travel [0.61, 1.18]. Every
calibration decile in Chapter 6, the AUC of 0.900, the Brier score of 0.126 and
the accuracy of 82.8%.

**The new PSIS-LOO table.** elpd $-686.6$ and $-491.9$, SE $16.7$ and $21.2$,
$p_{\text{loo}}$ $10.4$ and $21.8$, $\Delta$elpd $194.8$ at SE $17.5$, so $11.1$
standard errors. WAIC for the logit is $1373.2$; neither model has a Pareto $k$
above $0.7$. The LOO-IC figures differ in the last decimal, $1373.4$ against
$1373.3$ and $983.7$ against $983.8$, which is the spread between two MCMC runs
rather than a mistake.

**Claims about the data.** *Departure/Arrival time convenient* does have the
largest share of structural zeros, 6.3%, and does sit in a cluster with Gate
location (0.52), Food and drink (0.48) and Seat comfort (0.35). The eleven
covariates listed as signal at $s = 1$ are exactly the eleven with
$\kappa_j < 0.5$. *disloyal Customer* is the least shrunk coefficient at all
three global scales. *Inflight entertainment* is the best-preserved of the
fourteen service items. The raw file has 129,880 records and 22 columns, the
classes split 54.7 / 45.3, the training base rate is 0.546 and the held-out set
is 128,274 rows.

**The code.** All eight files that draw random numbers set a seed, `bas.glm` is
seeded before each call, no chunk calls `install.packages`, there are no
absolute paths, and the AUC rank statistic casts its class counts with
`as.numeric()`.

**Matteo's out-of-sample validation.** Standardisation uses training means and
standard deviations, and neither delay column has missing values, so nothing
silently becomes `NA`. His prediction matrix reaches 1.3 GB at 1284 draws by
128,274 rows, which is large but holds.

**No fabrications.** Nothing in the report describes a quantity the code does
not compute. Every error was a misreading of real output: a ranking taken from
the wrong column, a label carried over from a variable that was dropped, and a
cluster claim never checked against the correlation matrix.

---

# Corrections made by the team, confirmed against the data

The Business-class paragraph in Section 4.5 was already fixed before this audit,
and the data agrees with the corrected text: $\beta = +0.898$, credible interval
$[0.431, 1.348]$, $\kappa_j = 0.186$. It shrinks from an odds ratio of $4.26$ in
Section 3 to $2.45$, so "shrinks markedly" holds, but the interval never crosses
zero and the horseshoe keeps it as the third least shrunk coefficient. It is not
quite the largest odds ratio: *Inflight entertainment* is marginally ahead at
$2.47$.

In Chapter 6, `1203` was corrected to `1213`, fixing an error of mine. The
limitation about encoding and link choices being settled on training WAIC was
removed, correctly, since out-of-sample validation was added for that section.

---

# Before submitting

## Needs a human

- **The seven new bibliography entries** (issue 19). Authors, titles, years and
  journals I am confident about; volume and page numbers came from memory.
- **The three generated appendices** (feature selection, parameter-space
  convergence, BAS vs horseshoe). Nobody on the team has read them.
- **Whether `.Rmd` counts as the code deliverable**, or whether plain `.R` is
  expected. One question to the professor.

## Page count

The body is 15 printed pages against a target of 8 to 10. TODO.md lists roughly
four pages that could still come out, ranked by how little is lost. The largest
single win: Table 8 (`tab:hs-signal`) is `tab:hs-kappa` with a threshold applied
and carries no information of its own.

## What to upload to Overleaf

Everything below is in `report_backup/`, same paths. `main.tex` and the images
are unchanged.

| file | issues fixed |
|---|---|
| `biblio.bib` | 19 |
| `chapters/00_prob_desc_data_expl.tex` | 16, 19 |
| `chapters/02_logit_model.tex` | 2, 3, 4, 8, 17, 19 |
| `chapters/03_horseshoe_model.tex` | 5, 6, 18, 19, 21, 23 |
| `chapters/04_sensitivity.tex` | 19, 21, 24 |
| `chapters/05_prediction.tex` | 1, 7, 14, 15, 18 |
| `appendix/bas_comparison.tex` | 9-13, 19, 23 |
| `appendix/data_aug.tex` | 20, 22 |

**Careful:** the team edits the same project. Two rounds of work have already
been lost to a download overwriting local edits, and issues 9 to 13 existed
because an earlier round of moves was uploaded and then half reverted. Check
what is in Overleaf before overwriting anything.
