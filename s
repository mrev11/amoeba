#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

amoeba.exe  -p 3  "$@" | tee log-amoeba
