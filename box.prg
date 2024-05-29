
// sajat boxok
// ideiglenesen meretet kap
// ideiglenesen bordert kap
// fejleszteskor latszodjon, hol van

#include "amoeba.ch"

#ifdef DEBUG
******************************************************************************************
function hbox(parent,expand:=.t.,fill:=.f.,padding:=0)
local frm:=gtkFrameNew()
local box:=gtkHBoxNew()
    frm:add(box)
    parent:pack_start(frm,expand,fill,padding)
    return box


******************************************************************************************
function vbox(parent,expand:=.f.,fill:=.t.,padding:=0)
local frm:=gtkFrameNew()
local box:=gtkVBoxNew()
    frm:add(box)
    //frm:set_border_width(1)
    parent:pack_start(frm,expand,fill,padding)
    return box


#else
******************************************************************************************
function hbox(parent,expand:=.t.,fill:=.f.,padding:=0)
local box:=gtkHBoxNew()
    parent:pack_start(box,expand,fill,padding)
    return box


******************************************************************************************
function vbox(parent,expand:=.f.,fill:=.t.,padding:=0)
local box:=gtkVBoxNew()
    parent:pack_start(box,expand,fill,padding)
    return box


******************************************************************************************
#endif
