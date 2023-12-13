#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

export AMOEBA_CONTINUOUS_PLAY=true
export AMOEBA_POWER_WHITE=3
export AMOEBA_POWER_BLACK=3

amoeba.exe -t 16 -p 3  "$@" | tee log-amoeba
