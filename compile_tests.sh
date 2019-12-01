#!/usr/bin/env bash

for f in tests/*.in; do
  ./main.byte constraint $f > ${f%.in}.mzn
  ./main.byte smt $f > ${f%.in}.nofun.smt2
  ./main.byte smt --use-function $f > ${f%.in}.fun.smt2
  ./main.byte lp $f > ${f%.in}.lp
done