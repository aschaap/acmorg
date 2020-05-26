# Name of Org file
NAME=acmorg
# Name of bib file, should be identical to the filename to tangle into in the org file, minus the .bib
BIB=refs
# Desired name of tgz archive
ARCHIVE=replicable
# Relative path to figures; comment out FIGURES if there are no figures to make $(ARCHIVE).tgz, or add $(FIGURES) to .PHONY
FIGURES=figures/*
# ARCHIVE_FILES=$(shell git ls-tree -r master --name-only | grep -v -e '$(NAME).pdf')
ARCHIVE_FILES=$(NAME).org $(BIB).bib Makefile $(FIGURES)

.PHONY: all clean distclean

all: $(NAME).pdf

# If you have good Emacs and Org-mode installed by default, delete "-l ~/.emacs.d/init.el"
%.tex: %.org
	emacs -batch -l ~/.emacs.d/init.el --eval "(setq enable-local-eval t)" --eval "(setq enable-local-variables t)" \
	--eval "(setq org-export-babel-evaluate t)" $^  --funcall org-latex-export-to-latex

$(BIB).bib: $(NAME).org
	emacs -batch -l ~/.emacs.d/init.el $^  --funcall org-babel-tangle

%.pdf: %.tex $(BIB).bib
	pdflatex `basename $@ .pdf`
	bibtex `basename $@ .pdf`
	pdflatex `basename $@ .pdf`
	pdflatex `basename $@ .pdf`
#	Alternatively:
#	latexmk -shell-escape -f -pdf `basename $^ .tex`

%.html: %.org
# Ensure everything exports as expected; e.g., TikZ figures
	emacs -batch -l ~/.emacs.d/init.el --eval "(setq enable-local-eval t)" --eval "(setq enable-local-variables t)" \
	   --eval "(setq org-export-babel-evaluate t)" $^  --funcall org-html-export-to-html

$(ARCHIVE).tgz: $(ARCHIVE_FILES)
	tar --xform "s|^|$(ARCHIVE)/|" -zcf $@ $^

clean:
	rm -f $(NAME).aux $(NAME).bbl $(NAME).blg $(NAME).log $(NAME).out *~

distclean: clean
	rm -f $(NAME).html $(NAME).tex $(NAME).pdf
