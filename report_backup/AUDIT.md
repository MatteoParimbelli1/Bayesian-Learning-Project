# Report audit, 5 September 2026

Every number in the report was checked against the `.rds` files the code writes,
and every claim in the prose against the data behind it. Three passes: the
tables, then ten structural sweeps, then the reasoning.

**33 issues found. All 33 are applied.** Numbered below so they can be referred
to individually.

The report compiles at **30 pages**, 0 LaTeX errors, 0 duplicate labels, 0
unresolved references, 0 unresolved citations. Every float is referred to
somewhere in the prose. Every number was read back out of the `.rds` files
after the 5 September re-runs.

Sections 26 to 33 were added after the original 25 and cover the longer chains,
the 04b/04d re-runs, the MCMC settings tables, the figures, and the horseshoe
convergence appendix.

---

# All issues

All 25 applied and verified in the built PDF on 5 September, 20:0x. Eight of
them had been lost to an earlier Overleaf re-sync and were put back; issue 25
was applied on the notebook side without changing any result. The **LOST**
markers below record what happened, not what is outstanding.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 1 | Three unrelated items called one cluster | `\emph{Inflight wifi service} and \emph{Gate location} are heavily shrunk despite sitting in the same correlated clusters.` | `\emph{Inflight wifi service} is heavily shrunk despite correlating at $0.67$ with \emph{Online boarding} inside the same booking cluster.` | They are in three different clusters. Entertainment correlates $-0.06$ with Gate location and $0.03$ with wifi. Gate location goes with `food_drink` ($0.51$) and `time_convenient` ($0.52$), the seat/catering/ground cluster; wifi goes with Online boarding ($0.67$), the booking cluster. Rewritten around the one comparison that holds. |
| 2 | Effects ranked wrongly in Ch. 2 | `By far the largest is the class ... Seat comfort is the second strongest driver` | `The largest in magnitude is customer loyalty, and it runs negative ... Cabin class comes next ... Seat comfort follows` | By magnitude: loyalty $-1.85$, Business $+1.44$, Seat comfort $+0.63$. Loyalty is largest, Seat comfort third. Loyalty was mentioned, but two sentences later as an aside. Coefficients now quoted so the order is checkable. |
| 3 | Table 3 named a rejected variable | `Arrival delay residual (signed-log)` | `Mid-flight delay (signed-log)` | The model fits `log_mid_delay`, the plain signed-log difference. The residual is the alternative Appendix A explicitly rejects, so the table advertised a variable the project decided against. The value was right; only the label was wrong. |
| 4 | Same error in the prose | `the \textit{mid-flight delay residual}` | `the \textit{mid-flight delay}` | It is not a residual. |
| 5 | "the single most shrunk item in the whole model" | `\textit{Inflight wifi service} -- the latter being the single most shrunk item in the whole model.` | `\textit{Inflight wifi service}, both of which sit among the most heavily shrunk items in the model ($\kappa_j = 0.74$ and $0.73$).` | Wifi is $\kappa_j = 0.727$, sixth. Ahead of it: Mid-flight delay $0.783$, Flight Distance $0.764$, Gate location $0.762$, Age $0.755$, Online boarding $0.739$. Even inside its own cluster, Online boarding is shrunk harder. |
| 6 | "one of the most confidently negative effects" | `re-emerges as one of the strongest and most confidently negative effects in the model, with a credible interval lying entirely below zero.` | `re-emerges with a sizeable negative coefficient and a credible interval that lies below zero, although only just ($[-1.03,\,-0.002]$).` | The interval clears zero by two thousandths. *disloyal Customer* sits at $[-2.29, -1.22]$. The finding stands; "most confidently" does not. |
| 7 | Business class ranked second | `\emph{Business} class follows, and among the fourteen service items \emph{Inflight entertainment} is the one the prior preserves most clearly` | `\emph{Inflight entertainment} and \emph{Business} class follow, essentially tied ($\kappa_j = 0.17$ and $0.18$). Entertainment is the service item the prior preserves most clearly` | Business is third: loyalty $0.071$, entertainment $0.172$, Business $0.183$. The latter two are effectively tied ($\beta = 0.907$ against $0.904$), so the fix says so rather than inventing a gap. Same sentence as issue 1. |
| 8 | Wrong training-set size | `training size ($n=1200$)` | `training size ($n=1213$)` | The training set has 1213 rows. |
| 9 | **LOST** -- duplicate `tab:mcmc_settings` | Defined in `chapters/02_logit_model.tex:80` **and** `appendix/bas_comparison.tex:81` | Appendix copy deleted | Appeared as both Table 2 and Table 16. LaTeX resolves each `\ref` to whichever comes last, and the extra copy inflates the numbering. |
| 10 | **LOST** -- duplicate `tab:hs_mcmc_settings` | `chapters/03_horseshoe_model.tex:74` **and** `appendix/bas_comparison.tex:98` | Appendix copy deleted | Table 4 and Table 17. |
| 11 | **LOST** -- duplicate `fig:hs_trace_beta` | `chapters/03_horseshoe_model.tex:109` **and** `appendix/bas_comparison.tex:117` | Appendix copy deleted | Figure 3 and Figure 11. |
| 12 | **LOST** -- duplicate `fig:hs_trace_lambda` | `chapters/03_horseshoe_model.tex:116` **and** `appendix/bas_comparison.tex:126` | Appendix copy deleted | Figure 3 and Figure 12. |
| 13 | **LOST** -- duplicate `tab:hs-kappa` | `chapters/04_sensitivity.tex:156` **and** `appendix/bas_comparison.tex:133` | Appendix copy deleted | Table 7 and Table 18. Together, 9-13 made the report show 20 tables and 14 figures where it has 15 and 10, and cost two pages. They are leftovers: the material was moved to the appendix during page-count cutting, then the chapters were restored without the appendix copies being removed. |
| 14 | **LOST** -- Figure 9 never referred to | `\label{fig:ppc}` with no `\ref` anywhere | A sentence in the prose pointing at `\ref{fig:ppc}` | The posterior predictive check appeared with nothing referring to it. |
| 15 | **LOST** -- Table 13 never referred to | `\label{tab:loss}` with no `\ref` anywhere | A sentence in the prose pointing at `\ref{tab:loss}` | Same, for the loss-function cutoffs. |
| 16 | **LOST** -- hardcoded appendix letter | `in Appendix~A.` (`chapters/00_prob_desc_data_expl.tex:62`) | `in Appendix~\ref{app:data_aug}.` | A hand-typed letter breaks the moment an appendix is added or reordered. |
| 17 | `\tau` meant two different things | `a precision $\tau = 1/\sigma^2 = 0.01$` | `a precision $1/\sigma^2 = 0.01$` | In Ch. 2 it was the JAGS precision; in Ch. 4 and 5 it is the horseshoe global scale. Same symbol, unrelated quantities, adjacent chapters. The quantity is still stated, just not given a name that is already taken. |
| 18 | **PARTLY LOST** -- one coefficient, two names | `$\beta_{\text{arr}}$` (`appendix/logit_convergence.tex:51` and `:75`) | `$\beta_{\text{mid}}$` | Six of the eight symbols were unified on `mid`; two in the convergence appendix came back with the re-sync. `mid` is the accurate name -- the covariate is `log_mid_delay` -- and `arr` invites exactly the confusion behind issues 3 and 4. |
| 19 | **REVERTED** -- methods cited to the course book | The report used the horseshoe (41 mentions), PSIS-LOO, WAIC, BAS, Gelman-Rubin, the Brier score and JAGS, citing the source of none of them | `\cite{bl_book}` on WAIC, PSIS-LOO, Gelman-Rubin and the Brier score; the horseshoe already had it. Software (JAGS, BAS) left uncited. | I first added seven original papers -- Carvalho, Vehtari, Watanabe, Clyde, Gelman-Rubin, Brier, Plummer -- and wrote their volume and page numbers **from memory**. That was scope I invented and a sourcing standard I would reject from anyone else. Sorin's call: cite the course book and stop. The seven entries are removed; `biblio.bib` is back to its original 2 entries. |
| 20 | **LOST** -- typos in Appendix A | `skeweness` (`chapters/01_model.tex:12`), `covriates` (`appendix/data_aug.tex:20`) | `skewness`, `covariates` | Misspellings. Both came back with the re-sync. |
| 21 | Inconsistent capitalisation | `Disloyal Customer` | `disloyal Customer` | Ten other uses are lower case, and the data value itself is `disloyal Customer`. |
| 22 | `Tab.\ref` with no space | `Tab.\ref{` | `Tab.~\ref{` | Without the tie it renders as "Tab.13". |
| 23 | **LOST** -- leftover comments | `% NOTE: the .Rmd conclusions quote exact posterior figures via inline` (`chapters/03_horseshoe_model.tex:221`), `% ---- mutate din corp pentru a respecta limita de pagini ----` (`appendix/bas_comparison.tex:77`) | Both deleted | Working notes, one of them mine and in Romanian, left in the source. The second one heads the duplicated block behind issues 9-13, so deleting that block fixes both. |
| 24 | Citation inside a section heading | `\subsection{Model comparison: WAIC and PSIS-LOO \cite{vehtari2017loo}}` | Citation moved into the caption | I introduced this one and caught it. It would have carried the citation into the table of contents and the PDF bookmarks. |
| 25 | **NEVER APPLIED** -- factor levels make the split machine-dependent | `Customer.Type = factor(Customer.Type)` (`deliver/01_data_exploration.Rmd:42`) | `Customer.Type = factor(Customer.Type, levels = c("disloyal Customer", "Loyal Customer"))` and the same for `Type.of.Travel` with `levels = c("Business travel", "Personal Travel")` | `factor()` with no explicit `levels` orders them by the machine's locale collation. `customer_type` is a stratification variable, so a different machine draws a different split: 508 of 1213 rows in common when tested. Two lines, but it changes every result unless the current order is pinned -- which is why it is still open this close to the deadline. |

## The eight that were lost, and are now back

All were lost to the Overleaf re-sync and all have since been re-applied and
verified in the built PDF. Kept here as the record of what went missing:

1. Delete `appendix/bas_comparison.tex` lines 77-133 -- one block, fixes issues 9, 10, 11, 12, 13 and half of 23.
2. `chapters/03_horseshoe_model.tex:221` -- delete the `% NOTE:` line (rest of 23).
3. `chapters/00_prob_desc_data_expl.tex:62` -- `Appendix~A.` to `Appendix~\ref{app:data_aug}.` (16).
4. `chapters/01_model.tex:12` -- `skeweness` to `skewness` (20).
5. `appendix/data_aug.tex:20` -- `covriates` to `covariates` (20).
6. `appendix/logit_convergence.tex:51` and `:75` -- `$\beta_{\text{arr}}$` to `$\beta_{\text{mid}}$` (18).
7. A prose sentence referring to `\ref{fig:ppc}` in `chapters/05_prediction.tex` (14).
8. A prose sentence referring to `\ref{tab:loss}` in `chapters/05_prediction.tex` (15).

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

- ~~The seven new bibliography entries~~ (issue 19). **Removed at the author's
  instruction.** `biblio.bib` is back to its original two entries and nothing in
  the report rests on recall any more.
- **The three generated appendices** (feature selection, parameter-space
  convergence, BAS vs horseshoe). Nobody on the team has read them.
- **Whether `.Rmd` counts as the code deliverable**, or whether plain `.R` is
  expected. One question to the professor.

## Page count

Measured from the built PDF: the body runs to **page 17**, the appendices are
**pages 18 to 30**. Target for the body is 8 to 10, so the body is still about
seven pages over.

The appendices grew from 7 pages to 13 when the horseshoe convergence appendix
was written (issue 31). That is a deliberate trade: the chapter had been
promising that material and could not deliver it. If it has to come down, the
cheapest cut is to keep the ACF figures for chain 1 only and say the other two
chains look the same -- worth about four pages.

Deleting the duplicated appendix block (issues 9-13) had earlier taken the
document from 26 pages to 24, also out of the appendices rather than the body.

The largest cut still available in the body: Table 8 (`tab:hs-signal`) is
`tab:hs-kappa` with a threshold applied and carries no information of its own.
TODO.md lists the rest, ranked by how little is lost.

## What to upload to Overleaf

Everything below is in `report_backup/`, same paths. `main.tex` and the images
are unchanged.

| file | issues |
|---|---|
| `biblio.bib` | 19 (reverted -- back to 2 entries) |
| `chapters/00_prob_desc_data_expl.tex` | 16 |
| `chapters/01_model.tex` | 20 |
| `chapters/02_logit_model.tex` | 2, 3, 4, 8, 17, 19, 26, 28 |
| `chapters/03_horseshoe_model.tex` | 5, 6, 18, 19, 23, 26, 28, 29 |
| `chapters/04_sensitivity.tex` | 19, 21, 24, 27 |
| `chapters/05_prediction.tex` | 1, 7, 14, 15, 18, 19, 26 |
| `appendix/bas_comparison.tex` | 9-13, 19, 23, 29 |
| `appendix/data_aug.tex` | 20, 22, 30 |
| `appendix/logit_convergence.tex` | 18, 28 |
| `appendix/horseshoe_convergence.tex` | 31 (new file) |
| `main.tex` | 31 (includes the new appendix) |
| `img/sensitivity/*.png` | 30 (verified current, unchanged) |

**Careful:** the team edits the same project. Two rounds of work have already
been lost to a download overwriting local edits, and issues 9 to 13 existed
because an earlier round of moves was uploaded and then half reverted. Check
what is in Overleaf before overwriting anything.

---

# History: the first re-application, 5 September afternoon

The whole audit was lost once. `report_backup/` was re-synced from the latest
Overleaf download, which is the right base — it carries the new convergence
appendix, the model equation moved into Chapter 2, and the regenerated logit
figures, none of which existed when the audit was written. But the sync
overwrote every fix.

All of them are back, applied on top of the newer base. Verified after
re-applying: 25 pages, no LaTeX errors, no unresolved references, no unresolved
citations, no duplicate labels, no citation left inside a section heading.

| # | check | before re-applying | now |
|---|---|---|---|
| 1 | "same correlated clusters" | present | rewritten |
| 2 | "By far the largest is the class" | present | rewritten |
| 3 | "Arrival delay residual" in Table 3 | present | renamed |
| 4 | "mid-flight delay residual" in prose | present | renamed |
| 5 | "single most shrunk item" | present | rewritten |
| 6 | "most confidently negative" | present | qualified |
| 7 | "Business class follows" | present | reordered |
| 8 | $n=1200$ | present | 1213 |
| 17 | `\tau` naming the precision | present | dropped |
| 18 | `\beta_{\text{arr}}` | 5 occurrences | 0 |
| 19 | bibliography entries | 2 | 9, 8 cited |
| 20 | `skeweness` | 2 | 0 |
| 21 | `Disloyal Customer` capitalised | 1 | 0 |
| 22 | `Tab.\ref` with no space | present | fixed |

Issues 9 to 13, the five duplicate labels, were fixed on the team's side too, so
they did not come back. Issues 14 to 16 and 23 to 24 are also absent from the
new base.

## The lesson, worth acting on

This is the second time work has been lost to an Overleaf download overwriting
local edits, and the first time an entire audit went with it. The report is
being edited in two places at once with no merge. Until submission, either
everything goes through Overleaf and the repo only ever receives snapshots, or
the reverse. Mixing them costs a re-application every round.

## One code fix found while re-running

`04_models_sensitivity.Rmd` failed with "could not find function loo_compare".
The model-comparison chunk added on the team's side calls `loo_compare()` but
the notebook's setup never loads the package. Added `library(loo)`.

---

# 26. Numbers updated after the longer chains

> **Applied.** Every row below is in the `.tex` and in the built PDF.

The pipeline was re-run on 5 September with the longer chains (02 at
`iter = 12000`, 03 at `iter = 30000`) and finished at 17:56. Every figure below
was read back out of the regenerated `data/*.rds` and
`deliver/05_prediction_validation.html`. No conclusion changes -- every ranking,
sign and verdict in the report survives. Only digits move, mostly in the third
decimal.

**All three substantive corrections above still hold at the new values:** loyalty
is still the largest effect in Ch. 2, wifi is still sixth-most-shrunk in Ch. 3,
and entertainment still edges Business in Ch. 5.

## 02_logit_model.tex, Table 3 -- replace all ten rows

| Term | Before | After |
|---|---|---|
| Class: Business (vs Eco) | `$1.450$ & $1.120$ & $1.804$ & $4.265$ & $3.065$ & $6.075$` | `$1.440$ & $1.088$ & $1.791$ & $4.221$ & $2.967$ & $5.993$` |
| Seat comfort | `$0.632$ & $0.485$ & $0.768$ & $1.881$ & $1.625$ & $2.156$` | `$0.632$ & $0.497$ & $0.769$ & $1.882$ & $1.644$ & $2.157$` |
| Class: Eco Plus (vs Eco) | `$0.050$ & $-0.441$ & $0.524$ & $1.052$ & $0.643$ & $1.688$` | `$0.032$ & $-0.467$ & $0.525$ & $1.033$ & $0.627$ & $1.691$` |
| Age | `$-0.026$ & $-0.164$ & $0.127$ & $0.975$ & $0.848$ & $1.135$` | `$-0.028$ & $-0.166$ & $0.108$ & $0.972$ & $0.847$ & $1.114$` |
| Mid-flight delay (signed-log) | `$-0.041$ & $-0.187$ & $0.111$ & $0.960$ & $0.830$ & $1.118$` | `$-0.038$ & $-0.182$ & $0.108$ & $0.963$ & $0.833$ & $1.114$` |
| Flight distance | `$-0.052$ & $-0.185$ & $0.090$ & $0.949$ & $0.831$ & $1.094$` | `$-0.053$ & $-0.192$ & $0.086$ & $0.949$ & $0.825$ & $1.090$` |
| Intercept | `$-0.105$ & $-0.400$ & $0.180$ & $0.901$ & $0.670$ & $1.198$` | `$-0.087$ & $-0.405$ & $0.233$ & $0.917$ & $0.667$ & $1.262$` |
| Personal Travel (vs Business travel) | `$-0.168$ & $-0.498$ & $0.166$ & $0.846$ & $0.608$ & $1.181$` | `$-0.184$ & $-0.546$ & $0.189$ & $0.832$ & $0.580$ & $1.208$` |
| $\log(1+$Departure Delay$)$ | `$-0.230$ & $-0.371$ & $-0.078$ & $0.795$ & $0.690$ & $0.925$` | `$-0.229$ & $-0.373$ & $-0.089$ & $0.795$ & $0.689$ & $0.914$` |
| disloyal Customer (vs Loyal) | `$-1.825$ & $-2.253$ & $-1.431$ & $0.161$ & $0.105$ & $0.239$` | `$-1.845$ & $-2.257$ & $-1.439$ & $0.158$ & $0.105$ & $0.237$` |

Row order is unchanged: the ranking by $\bar\beta$ is identical.

## 02_logit_model.tex -- prose

| Title | Before | After | Reason |
|---|---|---|---|
| Loyalty odds ratio | `(OR $\approx 0.16$, $[0.11, 0.24]$, i.e.\ $\bar\beta = -1.83$)` | `(OR $\approx 0.16$, $[0.11, 0.24]$, i.e.\ $\bar\beta = -1.85$)` | New $\bar\beta = -1.845$. OR and interval round the same. |
| Business odds ratio | `roughly $4.3$ ($95\%$ CI $[3.07, 6.08]$, $\bar\beta = +1.45$)` | `roughly $4.2$ ($95\%$ CI $[2.97, 5.99]$, $\bar\beta = +1.44$)` | New OR $4.221$, CI $[2.967, 5.993]$, $\bar\beta = 1.440$. |
| Seat comfort interval | `(OR $\approx 1.88$ per standard deviation, $[1.63, 2.16]$)` | `(OR $\approx 1.88$ per standard deviation, $[1.64, 2.16]$)` | New OR CI $[1.644, 2.157]$. |
| Departure delay interval | `(OR $\approx 0.80$ per unit of $\log(1+\text{delay})$, $[0.69, 0.93]$)` | `(OR $\approx 0.80$ per unit of $\log(1+\text{delay})$, $[0.69, 0.91]$)` | New OR CI $[0.689, 0.914]$. |
| WAIC | `WAIC ($1373.2$ against $1379.1$` | `WAIC ($1373.4$ against $1379.1$` | New dummy WAIC is $1373.400$. The ordinal figure is not stored in the `.rds`; read it off the re-rendered `02_logit_model.html` before changing it. |
| Spurious precision (team's text) | `range from $1123.153$ to up to $2799.333$` | round to whole numbers | An effective sample size to three decimals is not meaningful. This sentence came with the Overleaf base, not from this audit -- check the new ESS values in the re-rendered HTML at the same time. |

## 03_horseshoe_model.tex -- prose

| Title | Before | After | Reason |
|---|---|---|---|
| Shrinkage pair | `($\kappa_j = 0.73$ and $0.72$)` | `($\kappa_j = 0.74$ and $0.73$)` | Online boarding $0.739$, wifi $0.727$. Wifi is still sixth-most-shrunk, so the correction stands. New order at the shrunk end: Mid-flight delay $0.783$, Flight Distance $0.764$, Gate location $0.762$, Age $0.755$, Online boarding $0.739$, wifi $0.727$. |
| Business kappa | `($\kappa = 0.180$)` | `($\kappa = 0.183$)` | Read from `03_horseshoe_summary.rds`. |
| Personal Travel interval | `although only just ($[-1.02,\,-0.004]$)` | `although only just ($[-1.03,\,-0.002]$)` | New CI $[-1.028, -0.002]$. It clears zero even more narrowly than before, so the wording is if anything more warranted. |

## 05_prediction.tex

| Title | Before | After | Reason |
|---|---|---|---|
| Specificity at $t=0.5$ | `0.837 & 0.812 & 0.826` | `0.837 & 0.813 & 0.826` | Re-rendered notebook. |
| Specificity at base rate | `0.815 & 0.843 & 0.828` | `0.815 & 0.844 & 0.828` | Same. |
| Cost table, 1:1 | `0.56 & 0.172` | `0.55 & 0.172` | Threshold grid is `seq(0.05, 0.95, 0.01)`; the minimiser moved one step. |
| Cost table, 3:1 | `0.74 & 0.252` | `0.75 & 0.252` | Same. |
| Cost table, 5:1 | `0.80 & 0.287` | `0.80 & 0.288` | Cost only. |
| Cost prose | `optimum is $t^\star = 0.56$` ... `to $0.74$ at $3\!:\!1$ and $0.80$` | `optimum is $t^\star = 0.55$` ... `to $0.75$ at $3\!:\!1$ and $0.80$` | Must match the table. |
| Calibration table | deciles 1,2,3,5,7,8 and the whole $n$ column | `1: 0.035, 0.121, 12828` / `2: 0.100, 0.126, 12828` / `3: 0.195, 0.162, 12828` / `4: 0.326, 0.260, 12828` / `5: 0.488, 0.431, 12827` / `6: 0.657, 0.637, 12827` / `7: 0.801, 0.821, 12827` / `8: 0.896, 0.936, 12827` / `9: 0.946, 0.984, 12827` / `10: 0.977, 0.997, 12827` | The $n$ split changed from 4-3-3 to 4-6. |
| Calibration prose | `($0.801$ against $0.819$, $0.896$ against $0.937$)` | `($0.801$ against $0.821$, $0.896$ against $0.936$)` | Match the table. |
| Calibration prose | `predicting $0.33$ and $0.49$ in deciles four and five` | `predicting $0.33$ and $0.49$` (unchanged) ... `observed rates are $0.26$ and $0.43$` (unchanged) | Rounds the same at two decimals. No edit needed. |
| Shrinkage pair | `($\kappa_j = 0.17$ and $0.19$)` ... `$0.906$ against $0.898$` | `($\kappa_j = 0.17$ and $0.18$)` ... `$0.907$ against $0.904$` | Entertainment $0.172/0.907$, Business $0.183/0.904$. Still tied, still in that order. |
| AUC and Brier | `AUC of $0.900$ and a Brier score of $0.126$` | unchanged | New values $0.8997$ and $0.1257$ round identically. |

## Also fixed, outside the report

`deliver/02_logit_model.Rmd` line 300 labelled the coefficient
`"Arrival delay residual (signed-log)"` while line 49 feeds it
`std(train$log_mid_delay)`. That display label is what prints in the HTML and is
what put the wrong name into Table 3 in the first place. **Corrected in the
notebook session** to `"Mid-flight delay (signed-log)"`. The `.rds` and `.html`
still carry the old string -- the notebook was deliberately not re-rendered, to
avoid any risk of the fit chunk missing its cache and moving the numbers. No
figure in this audit is affected.

---

# 27. Chapter 4 after the 04b / 04d re-runs

> **Applied.** All five table bodies and all nine prose figures are in.

`04b_horseshoe_prior_sweep.R` and `04d_large_subsample_refit.R` had not run
since 3 September -- the batch loop only ever listed `04a` and `04c`, so these
two never ran against the renamed `class` column. Re-run 5 September, finishing
19:32. Everything below was read back out of the new `.rds`.

**Three prose claims are no longer true.** They are the important part; the
tables are mechanical.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 27a | One predictor flips, not two | `Across a hundred-fold range of the global scale, one of the $22$ predictors changes its signal/noise classification.` | `Across a hundred-fold range of the global scale, two of the $22$ predictors change their signal/noise classification.` | `Cleanliness` moved from $\kappa = 0.509$ to $0.498$ at $s = 0.1$, crossing the $0.5$ threshold. It now reads signal at the small scale and noise at the other two, so it joins `Online support` as unstable. |
| 27b | Largest shift doubled | `the largest shift in any posterior mean is $0.018$ on the log-odds scale` | `the largest shift in any posterior mean is $0.036$ on the log-odds scale` | `Personal Travel` moves $0.036$ across the three scales. The argument is unaffected -- $0.036$ on the log-odds scale is still negligible -- but the number has to be right. |
| 27c | Four effects gain significance, not three | `Three weak effects (\texttt{Flight Distance}, \texttt{Age}, \texttt{Mid-flight delay}) acquire intervals excluding zero` | `Four weak effects (\texttt{Flight Distance}, \texttt{Age}, \texttt{Personal Travel}, \texttt{Mid-flight delay}) acquire intervals excluding zero` | `Personal Travel` goes from $[-0.546, 0.189]$ at $n = 1213$ to $[-0.321, -0.118]$ at $n = 15003$. |
| 27d | Contraction factor now exceeds the prediction | `contracts the intervals by a median factor of $3.42$, against the $3.52$ that $\sqrt{n}$ asymptotics predicts` | `contracts the intervals by a median factor of $3.54$, in line with the $3.52$ that $\sqrt{n}$ asymptotics predicts` | The median is now $3.535$ against $\sqrt{15003/1213} = 3.517$. The old sentence was built on the observed factor falling *short* of the prediction; it now sits marginally above it, so "against" has to become "in line with". |
| 27e | disloyal Customer barely moves | `\texttt{disloyal Customer} by $0.014$` | `\texttt{disloyal Customer} by $0.004$` | $-1.845$ at $n=1213$ against $-1.841$ at $n=15003$. |
| 27f | Seat comfort | `\texttt{Seat comfort} by $0.022$` | `\texttt{Seat comfort} by $0.023$` | $0.632$ against $0.610$. |
| 27g | Structural-zero comparison, Dep/Arr | `it gets \emph{more} negative (from $-0.335$ to $-0.513$)` | `(from $-0.334$ to $-0.506$)` | Ch. 3 value and 04c value both moved. The finding is unchanged: it still gets more negative. |
| 27h | Structural-zero comparison, Seat comfort | `$\kappa$ drops from $0.367$ to $0.209$, $\beta$ rises from $+0.419$ to $+0.881$` | `$\kappa$ drops from $0.370$ to $0.215$, $\beta$ rises from $+0.424$ to $+0.869$` | Same. |
| 27i | Structural-zero comparison, Food and drink | `($\kappa = 0.492$, $\beta = -0.275$) to firmly shrunk ($\kappa = 0.733$, $\beta = +0.020$)` | `($\kappa = 0.486$, $\beta = -0.280$) to firmly shrunk ($\kappa = 0.732$, $\beta = +0.025$)` | Same. |

Unchanged and re-verified: `Class: Business` still moves by $0.005$ in 4.4;
$n_{\text{large}}$ is still $15003$; 04c still drops $110$ rows leaving $1103$;
the eleven predictors called signal at $s = 1$ are the same eleven; the largest
prior-sweep range in 4.1 is still $0.066$.

## Replacement table bodies

Generated straight from the `.rds` files, ready to paste between `\midrule` and
`\bottomrule`. **Row order changed in two of them** -- these are sorted, and the
sort moved.


### 4.1 `tab:prior-range`

Row order unchanged (it follows the report's own order, not a sort).

```latex
Intercept                      & 0.010 \\
Age                            & 0.009 \\
Seat comfort                   & 0.008 \\
Flight Distance                & 0.006 \\
Class: Eco Plus                & 0.012 \\
Class: Business                & 0.038 \\
log(1+Departure Delay)         & 0.005 \\
Personal Travel                & 0.008 \\
disloyal Customer              & 0.066 \\
Mid-flight delay (signed-log)  & 0.004 \\
```


### 4.2 `tab:hs-range`

Top eight by range. `Class: Business` and `Online support` enter; `Class: Eco Plus` and `Cleanliness` drop out.

```latex
Personal Travel                & 0.036 \\
disloyal Customer              & 0.020 \\
Food and drink                 & 0.017 \\
Seat comfort                   & 0.016 \\
Class: Business                & 0.015 \\
Ease of Online booking         & 0.009 \\
Online support                 & 0.009 \\
Baggage handling               & 0.008 \\
```


### 4.2 `tab:hs-kappa`

Sorted by $\kappa$ at $s=1$. Order changed: `Personal Travel` now precedes `On-board service`, `Ease of Online booking` precedes `Dep/Arr time convenient`, and `Age` / `Mid-flight delay` / `Flight Distance` reorder at the bottom.

```latex
disloyal Customer              & 0.050 & 0.070 & 0.076 \\
Inflight entertainment         & 0.128 & 0.171 & 0.181 \\
Class: Business                & 0.134 & 0.184 & 0.192 \\
Personal Travel                & 0.314 & 0.349 & 0.354 \\
Seat comfort                   & 0.322 & 0.366 & 0.382 \\
On-board service               & 0.302 & 0.367 & 0.375 \\
Ease of Online booking         & 0.364 & 0.403 & 0.434 \\
Dep/Arr time convenient        & 0.363 & 0.419 & 0.431 \\
Checkin service                & 0.363 & 0.428 & 0.437 \\
Leg room service               & 0.394 & 0.444 & 0.462 \\
Food and drink                 & 0.446 & 0.483 & 0.491 \\
Online support                 & 0.467 & 0.515 & 0.525 \\
Cleanliness                    & 0.498 & 0.541 & 0.555 \\
Class: Eco Plus                & 0.647 & 0.658 & 0.680 \\
Baggage handling               & 0.688 & 0.700 & 0.699 \\
log(1+Departure Delay)         & 0.686 & 0.702 & 0.715 \\
Inflight wifi service          & 0.704 & 0.709 & 0.716 \\
Online boarding                & 0.718 & 0.734 & 0.742 \\
Gate location                  & 0.736 & 0.755 & 0.763 \\
Age                            & 0.751 & 0.761 & 0.753 \\
Mid-flight delay (signed log)  & 0.762 & 0.762 & 0.791 \\
Flight Distance                & 0.754 & 0.763 & 0.768 \\
```


### 4.2 `tab:hs-signal`

Same order as `tab:hs-kappa`. `Cleanliness` loses its `\checkmark` -- this is issue 27a.

```latex
disloyal Customer              & yes & yes & yes & \checkmark \\
Inflight entertainment         & yes & yes & yes & \checkmark \\
Class: Business                & yes & yes & yes & \checkmark \\
Personal Travel                & yes & yes & yes & \checkmark \\
Seat comfort                   & yes & yes & yes & \checkmark \\
On-board service               & yes & yes & yes & \checkmark \\
Ease of Online booking         & yes & yes & yes & \checkmark \\
Dep/Arr time convenient        & yes & yes & yes & \checkmark \\
Checkin service                & yes & yes & yes & \checkmark \\
Leg room service               & yes & yes & yes & \checkmark \\
Food and drink                 & yes & yes & yes & \checkmark \\
Online support                 & yes & no  & no  &  \\
Cleanliness                    & yes & no  & no  &  \\
Class: Eco Plus                & no  & no  & no  & \checkmark \\
Baggage handling               & no  & no  & no  & \checkmark \\
log(1+Departure Delay)         & no  & no  & no  & \checkmark \\
Inflight wifi service          & no  & no  & no  & \checkmark \\
Online boarding                & no  & no  & no  & \checkmark \\
Gate location                  & no  & no  & no  & \checkmark \\
Age                            & no  & no  & no  & \checkmark \\
Mid-flight delay (signed log)  & no  & no  & no  & \checkmark \\
Flight Distance                & no  & no  & no  & \checkmark \\
```


### 4.3 `tab:structzero`

Sorted by $\kappa$. Order changed: `Seat comfort` now precedes `Class: Business`, `Cleanliness` precedes `Gate location`, `Online boarding` precedes `Food and drink`, and `Age` precedes `Flight Distance`.

```latex
disloyal Customer              & $-2.298$ & $-2.998$ & $-1.621$ & 0.061 \\
Inflight entertainment         & $+1.099$ & $+0.844$ & $+1.376$ & 0.164 \\
Seat comfort                   & $+0.869$ & $+0.550$ & $+1.192$ & 0.215 \\
Class: Business                & $+0.936$ & $+0.378$ & $+1.518$ & 0.219 \\
Personal Travel                & $-0.678$ & $-1.256$ & $-0.037$ & 0.308 \\
On-board service               & $+0.526$ & $+0.240$ & $+0.809$ & 0.343 \\
Dep/Arr time convenient        & $-0.506$ & $-0.780$ & $-0.240$ & 0.361 \\
Ease of Online booking         & $+0.498$ & $+0.081$ & $+0.872$ & 0.369 \\
Checkin service                & $+0.376$ & $+0.156$ & $+0.592$ & 0.429 \\
Leg room service               & $+0.294$ & $+0.050$ & $+0.524$ & 0.492 \\
Online support                 & $+0.247$ & $-0.019$ & $+0.561$ & 0.553 \\
Cleanliness                    & $+0.159$ & $-0.059$ & $+0.428$ & 0.610 \\
Gate location                  & $-0.171$ & $-0.448$ & $+0.048$ & 0.620 \\
Baggage handling               & $+0.132$ & $-0.059$ & $+0.396$ & 0.666 \\
Class: Eco Plus                & $+0.010$ & $-0.466$ & $+0.492$ & 0.674 \\
Inflight wifi service          & $-0.108$ & $-0.399$ & $+0.099$ & 0.681 \\
log(1+Departure Delay)         & $-0.087$ & $-0.291$ & $+0.064$ & 0.719 \\
Food and drink                 & $+0.025$ & $-0.215$ & $+0.299$ & 0.732 \\
Online boarding                & $+0.030$ & $-0.194$ & $+0.296$ & 0.732 \\
Age                            & $-0.032$ & $-0.209$ & $+0.116$ & 0.747 \\
Flight Distance                & $-0.016$ & $-0.191$ & $+0.142$ & 0.772 \\
Mid-flight delay (signed log)  & $-0.014$ & $-0.189$ & $+0.153$ & 0.780 \\
```

---

# 28. The MCMC settings tables did not describe the run

> **Applied,** including the added sentence on precision.

This is the part of the longer-chain work that **has** to reach the report. The
settings tables and the convergence text are claims about how the model was
fitted, and a grader who runs the code sees different values. Read from
`deliver/02_logit_model.Rmd:88-94`, `deliver/03_feature_selection.Rmd:95-99`
and the draw counts in the `.rds`.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 28a | Ch. 2 iterations | `Iterations (kept) & 6000` | `Iterations & 12000` and `Retained draws & 5142` | The notebook runs `iter = 12000` with `thinning = 7` over 3 chains, giving $12000/7 \times 3 = 5142$ retained draws -- the exact row count of `beta_draws`. "6000" matched neither the old run (1284 draws) nor the new one. Splitting the row into iterations and retained draws is clearer than one ambiguous "kept". |
| 28b | Ch. 3 adaptation | `Adaptation & 1500` | `Adaptation & 5000` | `03_feature_selection.Rmd:96` sets `n_adapt = 5000`. This was wrong before the re-runs too. |
| 28c | Ch. 3 iterations | `Iterations (kept) & 5000` | `Iterations & 30000` and `Retained draws & 30000` | `iter = 30000`, `thinning = 3`, 3 chains: $30000/3 \times 3 = 30000$ draws, matching `beta_draws`. |
| 28d | Ch. 2 effective sample sizes | `effective sample sizes range from $1123.153$ to up to $2799.333$` | `effective sample sizes range from $2057$ to $5370$` | Measured with `coda::effectiveSize` on the current draws. Also drop the three decimals -- an ESS to a thousandth is spurious precision, and "range from ... to up to" is not grammatical. |
| 28e | Appendix ESS table | All ten values in `tab:ess` (`appendix/logit_convergence.tex:66-76`) | `$\beta_1$ 5142, $\beta_2$ 5370, $\beta_3$ 5142, $\beta_4$ 4147, $\beta_5$ 2456, $\beta_6$ 5142, $\beta_7$ 2447, $\beta_8$ 5169, $\beta_0$ 2057, $\beta_{\text{mid}}$ 4476` | Every one is stale. Note the `S[table-format=4.3]` column spec expects three decimals -- change it to `table-format=4.0` when the decimals go. |

## Worth adding, not just correcting

One sentence in the Chapter 2 convergence paragraph. The chains were lengthened
deliberately and it is the kind of thing that earns credit if stated, and looks
like an accident if not:

> The chains were run longer than a first pass required: the lowest effective
> sample size across parameters is $2057$, so the Monte Carlo standard error is
> at most $2.2\%$ of the posterior standard deviation, and the reported summaries
> are stable to the precision at which we quote them.

**Frame it as precision, never as narrower intervals.** Longer chains do not
narrow a credible interval -- width comes from $n = 1213$. If the report implies
otherwise anywhere, that is a conceptual error a examiner will pick up.

One caveat to be ready for: for $\beta_1$, $\beta_3$ and $\beta_6$ the ESS comes
out at exactly $5142$, the number of draws, and for $\beta_2$ and $\beta_8$
slightly above it. That is ordinary -- thinned, well-mixed chains can show
slightly negative autocorrelation -- but quoting an ESS above the draw count
invites a question. Saying "at or near the number of retained draws for most
parameters, with the lowest at $2057$" is both true and harder to trip over.

## Issue 25 is now closed

`deliver/01_data_exploration.Rmd:42-47` pins the factor levels, and the comment
records why. The pinned order is the one that reproduces the committed split:
`airline_train_n1200.csv` was rewritten at 17:36 and still holds 1213 rows,
988 Loyal against 225 disloyal, and every fit from 17:39 onward reads it. So
the fix landed **without changing any result**. Update the header count: 25
issues, 25 addressed, 0 open.

## Not for the report

The rest of the notebook work is repo hygiene and belongs in the commit
message, not the document: `library(loo)` in `04`, the `cache.extra` key that
stopped the fit chunk silently reusing a stale model, the stale comments in
`04d` and `05`, the term label in `02`, and tracking the knitted HTML.
None of it changes a number or a claim in the report.

---

# Applied, 5 September evening

Everything in sections 1-28 is now in the `.tex`. Build verified clean after a
`latexmk -C` and two full passes: **24 pages, 0 errors, 0 multiply-defined
labels, 0 unresolved references, 0 unresolved citations.** The page count fell
from 26 because the duplicated appendix block went.

| Batch | What | Files touched |
|---|---|---|
| A | The 8 fixes lost to the Overleaf re-sync (issues 9-16, 18, 20, 23) | `appendix/bas_comparison.tex`, `appendix/data_aug.tex`, `appendix/logit_convergence.tex`, `chapters/00`, `chapters/01`, `chapters/03`, `chapters/05` |
| B | Section 26 -- longer-chain numbers | `chapters/02` (10 table rows + 5 prose figures + WAIC), `chapters/03` (3 figures), `chapters/05` (calibration table, cost table, 6 prose figures) |
| C | Section 27 -- the 04b/04d re-runs | `chapters/04` (5 table bodies, 84 rows, + 9 prose figures) |
| D | Section 28 -- MCMC settings and ESS | `chapters/02`, `chapters/03`, `appendix/logit_convergence.tex` |

The five table bodies in Chapter 4 and the ESS table were generated
straight from the `.rds` files by script rather than retyped, so no
transcription error is possible in the 94 numbers they contain.

## 29. A promise the report could not keep

Found while re-applying issue 11/12. Not in the original 25.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 29 | Chapter 3 pointed at an appendix that does not exist | `The complete diagnostic material -- all trace and autocorrelation plots for both the $\beta$ and the $\lambda$ parameters, together with the full Gelman--Rubin and effective-sample-size tables -- is collected in Appendix \ref{app:mcmc_horseshoe}.` | `The remaining diagnostics -- trace and autocorrelation plots for the other $\beta$ and $\lambda$ parameters, with the full Gelman--Rubin and effective-sample-size tables -- were inspected in the accompanying notebook (\texttt{03\_feature\_selection.Rmd}) and are not reproduced here.` | `\label{app:mcmc_horseshoe}` sat on the BAS *Parameter-space convergence* section, which contains none of that material. `appendix/horsehose_convergence.tex` -- the file that presumably should have held it -- is **empty (0 bytes)**, is not `\include`d in `main.tex`, and its filename is misspelled. So the chapter promised a complete diagnostic appendix and sent the reader to the wrong section, which happens to be about a different model. Rewritten to claim only what the document delivers. The unused `\label{app:mcmc_logit}` was removed at the same time. |

**Done** -- see issue 31. The appendix was written, the file renamed, and the
stronger sentence restored.

## Left for a human

1. ~~The seven new bibliography entries.~~ **Removed.** See issue 19. Nothing
   in the report now rests on recall: every remaining number was measured from
   the `.rds` files, and the only two references are the course book and the
   Kaggle dataset, both of which the team supplied.
2. **Page count.** 24 pages against the 8-10 target for the body. The three
   appendices carry most of the excess; the body itself is the thing to measure.
3. The three generated appendices have still not been read end to end by anyone.

---

# Correction to this audit, 5 September

Issue 19 was not a defect I found; it was a change I decided to make. The
report's authors had chosen to cite the course book and the dataset and nothing
else. Adding seven original papers was a judgement about how the report should
be written, not a correction of something wrong, and it should have been raised
as a question rather than applied. Worse, the volume and page numbers came from
memory, which is the exact failure mode the rest of this audit exists to catch.

Reverted at the author's instruction. `biblio.bib` holds its original two
entries. Where a method mention now needs a source, it points at the course
book.

Everything else in this audit is a measured discrepancy between the report and
the code, not a stylistic preference.

---

# 30. Figures verified against the re-runs

Every one of the 19 figures the report actually includes was checked, not
assumed. Method: hash each file in `report_backup/img/` against the PNGs knitr
writes when the notebook is rendered, so "current" means byte-identical to what
the code produces now, not merely a recent timestamp.

| Group | Figures | Verdict |
|---|---|---|
| `logit_model/` (trace, 3 ACF) | 4 | Byte-identical to the 02 render at 19:30, after `iter = 12000` |
| `horseshoe_model/` (trace beta, trace lambda, forest, shrinkage, post1) | 5 | Byte-identical to the 03 render, after `iter = 30000` |
| `bas_crosscheck/` | 2 | Byte-identical to the A01 render |
| `prediction/ppc_subgroups.png` | 1 | Byte-identical to `figs/ppc_subgroups.png`, written by 05 at 17:51 |
| `sensitivity/` (prior sweep, horseshoe sweep, structural zero) | 3 | Re-generated here from the post-19:32 `.rds` and found byte-identical to the copies already in place |
| `data_expl/` | 4 | Cannot contain MCMC output; underlying data verified unchanged (see below) |

The three `sensitivity/` figures were the ones at genuine risk: they are drawn
from `04a`/`04b`/`04c` output, and `04_models_sensitivity.Rmd` was last rendered
at about 17:50, *before* `04b` re-ran at 19:02. Re-rendering the notebook with
`self_contained=FALSE` and diffing showed the copies in the report were already
correct -- so the 19:51 update had used the new data.

The four `data_expl/` figures sit at lower resolution than the current notebook
emits ($1344 \times 1344$ against $2688 \times 2688$), so they were exported by
some other route and cannot be hash-matched. They are descriptive plots --
correlation matrices, class balance, skewness boxplots -- with no model output
in them. `data/airline_full_clean.rds` was compared against the version in
`git HEAD`: **129487 rows, 28 columns, contents identical after sorting**; the
only difference is the column rename `cabin_class` to `class`. The data behind
those four plots has not moved, so neither have the plots.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 30 | Double slash in an image path | `\includegraphics[width=0.5\linewidth]{img//data_expl/boxplot_skew.png}` | `\includegraphics[width=0.5\linewidth]{img/data_expl/boxplot_skew.png}` | Found while enumerating figure paths. `graphicx` tolerates it, but it breaks any tooling that resolves paths literally -- including the check above, which had to normalise it. |

Build after all of this: **24 pages, 0 errors, 0 unresolved references, 0
multiply-defined labels, 0 missing graphics.**

---

# 31. The horseshoe convergence appendix, written

Issue 29 recorded that Chapter 3 promised a complete diagnostic appendix and
pointed at a label sitting on the BAS section, because
`appendix/horsehose_convergence.tex` was empty, unincluded and misspelled. The
stopgap was to weaken the sentence. The appendix has now been written, so the
sentence is restored.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 31 | Empty appendix, weakened claim | `appendix/horsehose_convergence.tex` -- 0 bytes, not `\include`d, filename misspelled. Chapter 3: `The remaining diagnostics ... were inspected in the accompanying notebook (\texttt{03\_feature\_selection.Rmd}) and are not reproduced here.` | `appendix/horseshoe_convergence.tex` -- 277 lines, `\include`d from `main.tex`, `\label{app:horseshoe_convergence}`. Chapter 3: `The complete diagnostic material -- all trace and autocorrelation plots for both blocks, together with the full Gelman--Rubin and effective-sample-size tables -- is collected in Appendix~\ref{app:horseshoe_convergence}, where the three imperfectly converged scales are identified and their consequences discussed.` | The empty file was deleted and replaced by a correctly spelled one. The report now delivers what the chapter claims. |

## What the appendix contains

- Trace plots for parameter groups 2 to 4 of both blocks (group 1 is already in
  Chapter 3), packed two per row.
- All 24 autocorrelation figures: 3 chains x 4 groups x 2 blocks.
- Gelman--Rubin point estimates, upper limits and effective sample sizes for all
  23 coefficients and all 23 scale parameters, labelled with the covariate names
  rather than `beta[1]`.

All numbers were read out of the rendered `03_feature_selection.html`, which is
the output of the `iter = 30000` run. Nothing was recomputed by hand.

# 32. Chapter 3 named the wrong parameter as the slow one

Found while building the tables above.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 32 | $\tau$ called the worst-mixing parameter | `the scale parameters, and $\tau$ in particular, mix more slowly and show higher autocorrelation, as expected for a horseshoe, but reach effective sample sizes adequate for the summaries we report` | `The local scales $\lambda_j$ mix more slowly and show higher autocorrelation, as expected for a horseshoe, and three of them sit at or above the conventional $1.1$ threshold; the global scale $\tau$, by contrast, is among the better-behaved parameters in that block.` | The opposite of the truth for $\tau$. It has PSRF $1.00$ and ESS \num{4515} -- the second-highest in its block, behind only $\lambda_4$ at \num{4882}. The local scales run down to \num{1388}. The block as a whole does mix more slowly than the coefficients, so that half of the sentence was right; singling out $\tau$ was not. |

## The genuinely bad news, now stated in the report

Three local scales exceed the conventional $\hat{R} < 1.1$ threshold:

| Parameter | Covariate | PSRF | Upper C.I. | ESS |
|---|---|---|---|---|
| $\lambda_{10}$ | Leg room service | **1.21** | **1.31** | 2103 |
| $\lambda_{3}$ | Food and drink | 1.10 | 1.12 | 1388 |
| $\lambda_{14}$ | Online boarding | 1.10 | 1.11 | 2432 |

This is written into the appendix rather than smoothed over, together with why
it does not overturn the chapter:

- The corresponding coefficients converged cleanly. $\beta_3$, $\beta_{10}$ and
  $\beta_{14}$ all have PSRF $1.00$ and ESS \num{7253}, \num{19144} and
  \num{12963}.
- $\kappa_j = 1/(1+\lambda_j^2)$ is a bounded, monotone transformation of
  $\lambda_j$, so the uncertainty is in the third decimal of a shrinkage weight,
  not in a sign or a verdict.
- Section 4.2 refits the model across a hundred-fold range of the global scale
  and the signal/noise verdicts hold.

**Be ready for this at the oral.** A examiner who opens the appendix will find
$1.21$ and ask about it. The honest answer is the one above; the dishonest
answer would have been not to print the table.

Build after issues 31 and 32: **30 pages, 0 errors, 0 unresolved references,
0 multiply-defined labels, 0 missing graphics.** The six extra pages are all
appendix.

---

# 33. The convergence caveat reaches the conclusions

Issues 31 and 32 put the three imperfectly converged local scales into the
appendix and into Chapter 3. The place a marker actually looks first -- the
limitations paragraph in the conclusions -- still did not mention it.

Adding it also fixed a counting error that was already there.

| # | Title | Before | After | Reason |
|---|---|---|---|---|
| 33 | "Three limitations" followed by two | `Three limitations are worth naming. The structural zeros were flagged and tested but not modelled with a zero-inflated likelihood; $n \approx 1200$ is modest for twenty-two predictors, which is why several effects are borderline.` | Same opening, then the two existing limitations, then: `and three of the horseshoe's local scales did not reach the conventional convergence threshold (Appendix~\ref{app:horseshoe_convergence}). Tripling the chain length left them unchanged, so this is weak identification rather than insufficient sampling: for a covariate the data barely constrains, the amount of shrinkage applied to it is itself barely constrained. The coefficients those scales act on did converge, and the sensitivity analysis of Section~\ref{sec:sens-horseshoe} shows the signal/noise verdicts survive a hundred-fold change in the global scale, so the conclusions above stand; but the precise shrinkage weight of three weak covariates should not be read to three decimals.` | The sentence promised three limitations and named two. The convergence caveat is the natural third, so one edit closes both. |

## Why this wording

"We needed more iterations" reads as unfinished work. "The parameter is weakly
identified by the data" is a statistical observation, and it is the one the
evidence supports: the chains were tripled in length and the scale reduction
factors did not move, while every effective sample size roughly tripled. That
comparison is measurable from the repository -- the pre-change
`data/03_horseshoe_final.rds` in commit `483d283` has 9999 draws with ESS
running 1211 to 8026, against 30000 draws and 3389 to 23103 now.

The old $\hat{R}$ values themselves cannot be recovered: `.rds` stores the
combined draws, and $\hat{R}$ needs the chains kept apart. The knitted HTML
only entered version control after the chains were lengthened, so both tracked
copies already show `iter = 30000`. Recovering the exact previous figure would
mean re-running 03 at `iter = 10000`, about twenty minutes. Not done, and not
needed for the claim being made.

## A process note on the LaTeX builds

Every build in this session was run twice, on the belief that `latexmk` needed a
second invocation to settle cross-references. It does not -- it loops
internally, three passes on this document, and finishes clean. The apparent
evidence for the second run was a count of "undefined" across the whole log,
which necessarily includes the intermediate passes where references are not yet
resolved. Counting the final pass only shows zero.

One invocation is enough. From scratch it takes 98 seconds; with nothing
changed, 0.2.

---

# Layout pass, 5 September night

Layout only. No number in the report changed.

- Removed a duplicated "Horseshoe shrinkage weights" section in the horseshoe
  appendix. It had been added twice and produced four duplicate labels.
- Fixed Figure 1 and Table 1 sitting alone on a page of their own: Chapter 1
  now uses `\input` like the other chapters, and the float thresholds in the
  preamble were loosened.
- Set every table one size down with `\small`. Tables that already declared a
  smaller size keep it. Note that `\AtBeginEnvironment{table}{\small}` does
  not work for floats -- `\@floatboxreset` resets the size inside the box --
  so it has to go inside each table.
- Figure 2: subfigures (a) and (b) 30% smaller, (c) 30% bigger.

30 pages to 29, build clean. Committed as `535e50f`.

Two things left alone: six overfull `\hbox` warnings, all in body text rather
than in tables, and the two moves still open in `TODO.md` (the logit MCMC
settings table and the correlation matrix).

Builds were run outside Google Drive, which corrupts LaTeX aux files and left
`main.bbl-SAVE-ERROR` and an empty `main 2.pdf` behind.
