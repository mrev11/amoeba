#!/bin/bash

XX=$(grep -c X amoeba-stat)
OO=$(grep -c O amoeba-stat)
EE=$(grep -c = amoeba-stat)

let total=$XX+$OO+$EE

echo total=$total X=$XX O=$OO E=$EE

let p=$XX*100/$total; echo X=$p%
let p=$OO*100/$total; echo O=$p%
let p=$EE*100/$total; echo E=$p%



