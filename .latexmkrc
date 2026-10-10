# BibTeX runs inside the build/ folder, so tell it to also look one folder up,
# where main.tex and the .bib file live. (A relative path, because the full
# path may contain spaces, which BibTeX cannot handle.)
ensure_path('BIBINPUTS', '..');
