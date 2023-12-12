#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

 export AMOEBA_CONTINUOUS_PLAY=true
 export AMOEBA_POWER_WHITE=1
 export AMOEBA_POWER_BLACK=1

amoeba.exe -t 16 -p 3  "$@" | tee log-amoeba
