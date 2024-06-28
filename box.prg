
/*
 *  CCC - The Clipper to C++ Compiler
 *  Copyright (C) 2005 ComFirm BT.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


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
