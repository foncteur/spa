#!/usr/bin/env bash

sizes="5 6 8 10 12 15 20 25"
solver="$1"
ext="$2"

cnt=0
runonsize() {
  echo "Running on size $1"
  for f in tests/*.$1.*.$ext; do
    $solver $f
    cnt=$(( $cnt + 1 ))
  done;
  echo "Done"
}

for s in $sizes; do
    cnt=0
    ts=$(date +%s%N)  
    runonsize $s
    runtime=$((($(date +%s%N) - $ts)/1000000)) 
    n=$(( $runtime / $cnt ))
    echo "Mean time taken: $n ms, total $runtime ms"
    echo "$s $n" | tee -a $ext.results
done