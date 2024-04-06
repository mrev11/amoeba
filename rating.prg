
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


#include "amoeba.ch"


static rating:=array(ROWCOL)
static recalc:=array(ROWCOL)

******************************************************************************
function rating_store( rp )
local mc:=movecount()
    if( mc==0 )
    elseif( rp::empty )
        rating[mc]:=NIL
    else
        rating[mc]:=rp
    end

function rating_load( mc:=movecount() )
local rp
    if( mc==0 )
        rp:=NIL
    else
        rp:=rating[mc]
    end
    return rp

function rating_string(mc)
local rp:=rating_load(mc)
local r,p
    if( rp==NIL )
        rp:="n.a."
    else
        r:=rp[1]::int::str::alltrim
        p:=rp[2]::int::str::alltrim
        rp:=r+"/"+p
    end
    return rp


******************************************************************************
function recalc_store( rpm )
local mc:=movecount()
    if( mc==0 )
    elseif( rpm::empty )
        recalc[mc]:=NIL
    else
        recalc[mc]:=rpm
    end

function recalc_load(mc:=movecount())
local rpm
    if( mc==0 )
        rpm:=NIL
    else
        rpm:=recalc[mc]
    end
    return rpm

function recalc_string(mc)
local rpm:=recalc_load(mc)
local r,p,m
    if( rpm==NIL )
        rpm:=""
    else
        r:=rpm[1]::int::str::alltrim
        p:=rpm[2]::int::str::alltrim
        m:=rpm[3]::pos2rc
        rpm:="("+r+"/"+p+":"+m+")"
    end
    return rpm


******************************************************************************
