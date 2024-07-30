#!/bin/bash


# AMOEBA_CONTINUOUS_PLAY=-1 : magtol nem valaszol
# AMOEBA_CONTINUOUS_PLAY=0  : automatikusan valaszol (default)
# AMOEBA_CONTINUOUS_PLAY=1  : onmaga ellen jatszik (1 partit)
# AMOEBA_CONTINUOUS_PLAY=n  : onmaga ellen jatszik  n darab partit

# export AMOEBA_CONTINUOUS_PLAY=1
# export AMOEBA_POWER_BLACK=6.10+
# export AMOEBA_POWER_WHITE=6.10+
 export AMOEBA_TIME_LIMIT=60

# export AMOEBA_TABLESIZE=22
# export AMOEBA_CELLSIZE=40
# export AMOEBA_COLOR=77,66,22
 export AMOEBA_BLINK=0

# GAME=amoeba16@

amoeba $@ -p 6.15+  $GAME   #| tee -a  log-amoeba

