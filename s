#!/bin/bash

 export AMOEBA_CONTINUOUS_PLAY=20
 export AMOEBA_POWER_BLACK=2
 export AMOEBA_POWER_WHITE=2

export AMOEBA_TABLESIZE=14
export AMOEBA_CELLSIZE=40
export AMOEBA_COLOR=77,66,22

amoeba.exe  | tee log-amoeba
