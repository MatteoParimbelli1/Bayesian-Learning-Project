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
