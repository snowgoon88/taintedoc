help:
	@echo "  make campagne | adiante | poster (=all)"
	@echo "  make web"

all: campagne adiante poster

campagne: campagne.tex
	latexmk -pdf campagne.tex

adiante: mer_adiante.gv
	dot -Tpdf mer_adiante.gv -o mer_adiante.pdf

poster: poster.tex
	latexmk -pdf poster.tex

web: poster campagne adiante
	mv campagne.pdf docs
	mv mer_adiante.pdf docs
	mv poster.pdf docs
