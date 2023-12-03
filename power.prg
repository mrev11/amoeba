
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



static width1:=powinit(POW1) 
static width2:=powinit(POW2) 
static width3:=powinit(POW3) 
static width4:=powinit(POW4) 
static width5:=powinit(POW5) 
static width6:=powinit(POW6)
static width7:=powinit(POW7)
static width8:=powinit(POW8)

static power
static width


*****************************************************************************
function width() // elemzőfa aktuáőis szélessége
    return width


*****************************************************************************
function setwidth(movecount)
local w

    if( power!=NIL )
        width:=power
    elseif( movecount<=2 )
        width:=width1
    elseif( movecount<=4 )
        width:=width2
    elseif( movecount<=8 )
        width:=width3
    elseif( movecount<=16 )
        width:=width4
    elseif( movecount<=32 )
        width:=width5
    elseif( movecount<=64 )
        width:=width6
    else
        width:=width7
    end


*****************************************************************************
function setpower(p)
    if( p=="auto" )
        power:=NIL
    else
        power:=powinit(p)
    end

// power==NIL  vagy  power=={4,3,2,1...}


*****************************************************************************
static function powinit(p)
local n
    p:=split(p)
    for n:=1 to len(p)
        p[n]:=val(p[n])
    next
    return p


*****************************************************************************
function teach(t)
static teach:=.t.
    if( t!=NIL )
        teach:=t
    end

    if( !teach  )
        return 0
    elseif( width::len<16 )
        return 1
    else
        return 2
    end


*****************************************************************************
