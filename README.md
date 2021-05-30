
# Notre campagne de Tainted Grail

ou "Un p'tit tour autour du Wyrd".

## Générer les fichier

``` shell
make all
```

## Imprimer le poster

Dans poster.tex, activer la sauvegarde sous forme externe

``` tex
%% Activate externalization to separate PDF for every image
\usetikzlibrary{external}
\tikzexternalize
```

puis générer l'image (PDF) avec

``` shell
pdflatex -shell-escape poster
```

Ensuite, on charge dans `inscape` avec l'import par Cairo. J'ai définit une `grid` de 19x20cm, puis 9 rectangles qui couvrent l'image. Et ensuite l'option d'export `batch export 9 selected objects`, ce qui me génère les images `rect-*.png`. 

Il faut maintenant les imprimer.

- convertir en PDF : ```convert rect6591-1-4.png rect6591-1-4.pdf```
- imprimer avec ```lp -d PRINTER -o options ? file```

(voir les imprimantes ```lpstat -p -d```, les options ```lpoptions -p DCP9020CDW -l```)

A voir donc...

