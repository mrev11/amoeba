#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

# export AMOEBA_CONTINUOUS_PLAY=true
# export AMOEBA_POWER_WHITE=3
# export AMOEBA_POWER_BLACK=3

#export AMOEBA_CELLSIZE=64
export AMOEBA_COLOR=66,66,33

amoeba.exe  -t 16  "$@" | tee log-amoeba
