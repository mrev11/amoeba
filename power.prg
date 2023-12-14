
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

static width_current

static width:=init_width()
static width_black:=init_width_black()
static width_white:=init_width_white()
static power


*****************************************************************************
static function init_width()
local w:=array(8)
    w[1]:=powinit(POW1) 
    w[2]:=powinit(POW2) 
    w[3]:=powinit(POW3) 
    w[4]:=powinit(POW4) 
    w[5]:=powinit(POW5) 
    w[6]:=powinit(POW6)
    w[7]:=powinit(POW7)
    w[8]:=powinit(POW8)
    return w


*****************************************************************************
static function init_width_black()
local p
    if( !getenv("AMOEBA_POWER_BLACK")::empty )
        p:=getenv("AMOEBA_POWER_BLACK")::val
        p::=max(1)
        p::=min(8)
        ? "Black plays at power", p, width[p]
        ?
        return width[p]
    end


static function init_width_white()
local p
    if( !getenv("AMOEBA_POWER_WHITE")::empty )
        p:=getenv("AMOEBA_POWER_WHITE")::val
        p::=max(1)
        p::=min(8)
        ? "White plays at power:", p, width[p]
        ?
        return width[p]
    end


*****************************************************************************
function width() // elemzőfa aktuális szélessége
    return width_current


*****************************************************************************
function setwidth(movecount, eval:=.f. )
local w
    if( !eval .and. turn_x() .and. width_black!=NIL )
        width_current:=width_black

    elseif( !eval .and. turn_o() .and. width_white!=NIL )
        width_current:=width_white
        
    elseif( power!=NIL )
        width_current:=power

    elseif( movecount<=2 )
        width_current:=width[1]

    elseif( movecount<=4 )
        width_current:=width[2]

    elseif( movecount<=8 )
        width_current:=width[3]

    elseif( movecount<=16 )
        width_current:=width[4]

    elseif( movecount<=32 )
        width_current:=width[5]

    elseif( movecount<=64 )
        width_current:=width[6]

    else
        width_current:=width[7]
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
function infolevel(t)
static level:=.t.
    if( t!=NIL )
        level:=t
    end

    if( !level  )
        return 0
    elseif( width_current::len<16 )
        return 1
    else
        return 2
    end


*****************************************************************************
