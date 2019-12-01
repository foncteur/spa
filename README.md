# spa
Projet de SPA (solver principles and architecture), 2019

## Fichiers 

Fichiers .ml : parser, main, et un fichier par type de générateur

## Comment compiler ?

`ocamlbuild main.byte`

## Comment créer les fichiers d'input pour les solveurs ?

Utiliser le script `compile_tests.sh` qui crée un fichier de solveur pour chaque fichier dans le dossier tests

## Comment lancer les solveurs ?

Pour les fichiers `.smt2`, il suffit de lancer `z3 nom_du_fichier.smt2` en ayant installé [z3](https://github.com/Z3Prover/z3)
Pour les fichiers `.mzn`, il suffit de lancer `minizinc --solver config_gecode.msc nom_du_fichier.mzn` en ayant installé [minizinc](https://www.minizinc.org/) et [gecode](https://www.gecode.org/)
Pour les fichiers `.lp`, il suffit de lancer `glpsol --lp nom_du_fichier.lp` en ayant installé [glpk](https://www.gnu.org/software/glpk/)
