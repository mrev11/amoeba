#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

export AMOEBA_CONTINUOUS_PLAY=true
export AMOEBA_POWER_WHITE=4
export AMOEBA_POWER_BLACK=2
export AMOEBA_COLOR=77,66,22
export AMOEBA_CELLSIZE=64

amoeba.exe -t 12 "$@" | tee log-amoeba
