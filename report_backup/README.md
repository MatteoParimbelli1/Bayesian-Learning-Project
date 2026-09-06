# Report backup

The report is written in Overleaf; this is a copy of its LaTeX sources so the
whole team can read and diff them from the repo, and so a working version
survives if the Overleaf project is lost.

Sources, figures and the compiled `main.pdf` are all here, so the project can
be rebuilt in Overleaf from this folder alone and anyone can read the current
report without compiling it.

To rebuild the PDF locally: `latexmk -pdf main.tex` from this folder. The figures are also reproducible: the notebooks in
`deliver/` regenerate them into `figs/`.

## Restoring into a fresh Overleaf project

1. Upload every file from this folder, keeping `chapters/` and `appendix/`
   as subfolders.
2. Upload `img/` as well, keeping its subfolders (`data_expl`,
   `horseshoe_model`, `sensitivity`, `prediction`, `bas_crosscheck`) intact:
   the `\includegraphics` paths depend on them.
3. Set the compiler to pdfLaTeX and the bibliography to Biber
   (Menu -> Settings). `biblatex` with `backend=biber` will not resolve
   citations under bibtex.

## Keeping it in sync

This is a snapshot, not a live link. After a round of edits in Overleaf,
download the source zip and copy the `.tex` files back over this folder, so
the history here stays useful.
