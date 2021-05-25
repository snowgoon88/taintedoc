all: campagne adiante

campagne:
	latexmk -pdf campagne.tex

adiante:
	dot -Tpdf mer_adiante.gv -o mer_adiante.pdf
