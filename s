#!/bin/bash


# AMOEBA_CONTINUOUS_PLAY=-1 : magtol nem valaszol
# AMOEBA_CONTINUOUS_PLAY=0  : automatikusan valaszol (default)
# AMOEBA_CONTINUOUS_PLAY=1  : onmaga ellen jatszik (1 partit)
# AMOEBA_CONTINUOUS_PLAY=n  : onmaga ellen jatszik  n darab partit

export AMOEBA_CONTINUOUS_PLAY=0
#export AMOEBA_POWER_BLACK=4
#export AMOEBA_POWER_WHITE=4

export AMOEBA_TABLESIZE=16
# export AMOEBA_CELLSIZE=40
# export AMOEBA_COLOR=77,66,22
export AMOEBA_BLINK=1

amoeba "$@"  | tee  log-amoeba

