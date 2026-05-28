#!/bin/bash

mkdir -p object
pkg-config --cflags gtk+-2.0  >object/gtk-cflags
pkg-config --libs   gtk+-2.0  >object/gtk-libs
echo -Wno-deprecated-declarations >>object/gtk-cflags

cccapp.sh  @parfile.bld  
