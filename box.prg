
// sajat boxok
// ideiglenesen meretet kap
// ideiglenesen bordert kap
// fejleszteskor latszodjon, hol van

#include "amoeba.ch"

#ifdef DEBUG
******************************************************************************************
function hbox(parent,expand:=.t.,fill:=.t.,padding:=0)
local frm:=gtkFrameNew()
local box:=gtkHBoxNew()
    frm:add(box)
    parent:pack_start(frm,expand,fill,padding)
    return box


******************************************************************************************
function vbox(parent,expand:=.t.,fill:=.t.,padding:=0)
local frm:=gtkFrameNew()
local box:=gtkVBoxNew()
    frm:add(box)
    parent:pack_start(frm,expand,fill,padding)
    return box


#else
******************************************************************************************
function hbox(parent,expand:=.t.,fill:=.t.,padding:=0)
local box:=gtkHBoxNew()
    parent:pack_start(box,expand,fill,padding)
    return box


******************************************************************************************
function vbox(parent,expand:=.t.,fill:=.t.,padding:=0)
local box:=gtkVBoxNew()
    parent:pack_start(box,expand,fill,padding)
    return box


******************************************************************************************
#endif
