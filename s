#!/bin/bash
cd ~/amoeba
. ~/envccc
clear

amoeba.exe $1 | tee log-amoeba
