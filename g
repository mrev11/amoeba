#!/bin/bash

LOG=$1
if [ "$LOG" == ""  ]; then
    LOG=log-amoeba
fi



echo
grep Nodes $LOG  | grep X | sort -t = -k 3 -n | tail
echo
grep Nodes $LOG  | grep O | sort -t = -k 3 -n | tail
echo
grep TOTAL_NODES $LOG | tail -n 1
echo



GAMES=$(grep -c TOTAL_NODES $LOG)
BLACK=$(grep -c winner=X $LOG)
WHITE=$(grep -c winner=O $LOG)
DRAW=$(grep -c winner=D $LOG)

echo GAMES=$GAMES   $(( ($BLACK+$BLACK+$DRAW)*50/$GAMES ))% 
echo BLACK=$BLACK   $(( $BLACK*100/$GAMES ))%
echo WHITE=$WHITE   $(( $WHITE*100/$GAMES ))%
echo DRAW=$DRAW     $(( $DRAW*100/$GAMES ))%
echo MOVES=$(grep -c  Nodes $LOG)


sleep 3
