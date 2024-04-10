#!/bin/bash

# AMOEBA_CONTINUOUS_PLAY=-1 : magtol nem valaszol
# AMOEBA_CONTINUOUS_PLAY=0  : automatikusan valaszol (default)
# AMOEBA_CONTINUOUS_PLAY=1  : onmaga ellen jatszik (1 partit)
# AMOEBA_CONTINUOUS_PLAY=n  : onmaga ellen jatszik  n darab partit

#export AMOEBA_CONTINUOUS_PLAY=1
export AMOEBA_POWER_BLACK=3+
#export AMOEBA_POWER_WHITE=3

export AMOEBA_CELLSIZE=48
export AMOEBA_COLOR=77,66,22

amoeba.exe  -t 12 -p 3
