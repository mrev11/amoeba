#!/bin/bash
.  /home/vermes/bashrcx
cd /home/vermes/amoeba


# AMOEBA_CONTINUOUS_PLAY=-1 : magtol nem valaszol
# AMOEBA_CONTINUOUS_PLAY=0  : automatikusan valaszol (default)
# AMOEBA_CONTINUOUS_PLAY=1  : onmaga ellen jatszik (1 partit)
# AMOEBA_CONTINUOUS_PLAY=n  : onmaga ellen jatszik  n darab partit

export AMOEBA_CONTINUOUS_PLAY=100
export AMOEBA_POWER_BLACK=5
export AMOEBA_POWER_WHITE=5

 export AMOEBA_TABLESIZE=20
# export AMOEBA_CELLSIZE=48
# export AMOEBA_COLOR=77,66,22
export AMOEBA_BLINK=0

amoeba.exe "$@"  | tee log-amoeba 
#xterm -e tail -f  /home/vermes/amoeba-pyx/log-amoeba

