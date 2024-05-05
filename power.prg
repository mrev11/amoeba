
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

static power_current
static width_current

static width:=init_width()
static width_black //:=init_width_black()
static width_white //:=init_width_white()

static maxenf:=0
static maxenf_black:=init_maxenf_black()
static maxenf_white:=init_maxenf_white()


******************************************************************************
function parse_power(p:=getenv("AMOEBA_POWER"))
local pw:=p::val::max(0)::min(8)

    if( "+"$p )
        movegen_white(0)    // movegen erosebb modja
        movegen_black(0)    // movegen erosebb modja
    elseif( "-"$p )
        movegen_white(1000) // movegen gyengebb modja
        movegen_black(1000) // movegen gyengebb modja
    else
        movegen_white(1000) // movegen gyengebb modja
        movegen_black(1000) // movegen gyengebb modja
    end

    // explicit inicializalas!
    width_black:=init_width_black()
    width_white:=init_width_white()

    return(pw)


******************************************************************************
function opt_power(pw)  // command line option
static power:=0
    if( pw!=NIL )
        power:=pw
    end
    return power


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
    if( !power_black()::empty )
        if( "+"$power_black() )
            movegen_black(0)
        else
            movegen_black(1000)
        end
        p:=power_black()::val
        p::=max(1)
        p::=min(8)
        ?? "Black plays at power", power_black(), width[p]::any2str
        ?
        return width[p]
    end


static function init_width_white()
local p
    if( !power_white()::empty )
        if( "+"$power_white() )
            movegen_white(0)
        else
            movegen_white(1000)
        end
        p:=power_white()::val
        p::=max(1)
        p::=min(8)
        ?? "White plays at power", power_white(), width[p]::any2str
        ?
        return width[p]
    end


*****************************************************************************
static function init_maxenf_black()
local maxenf:=power_black()::split::asize(2)[2]
    if( maxenf==NIL )
        maxenf:=0
    else
        maxenf::=val
    end
    return maxenf


static function init_maxenf_white()
local maxenf:=power_white()::split::asize(2)[2]
    if( maxenf==NIL )
        maxenf:=0
    else
        maxenf::=val
    end
    return maxenf


*****************************************************************************
function power_black()
static power:=getenv("AMOEBA_POWER_BLACK")
    return power


*****************************************************************************
function power_white()
static power:=getenv("AMOEBA_POWER_WHITE")
    return power


*****************************************************************************
function width() // elemzőfa aktuális szélessége
    return width_current


*****************************************************************************
function setwidth(movecount, recalc:=.f. )
local w
    if( !recalc .and. turn_x() .and. width_black!=NIL )
        width_current:=width_black

    elseif( !recalc .and. turn_o() .and. width_white!=NIL )
        width_current:=width_white
        
    elseif( power_current!=NIL )
        width_current:=power_current

    elseif( movecount<4 )
        width_current:=width[1]

    elseif( movecount<8 )
        width_current:=width[2]

    elseif( movecount<16 )
        width_current:=width[3]

    else
        width_current:=width[4]

    end

    setmaxenf()
    
    if( turn_x() .and. movegen_black()==0 )
        width_current:=aclone(width_current)
        width_current::aadd(0)
        width_current::aadd(0)
    end

    if( turn_o() .and. movegen_white()==0 )
        width_current:=aclone(width_current)
        width_current::aadd(0)
        width_current::aadd(0)
    end
    
    return current_level()


*****************************************************************************
function maxenf()
    return maxenf

// kényszerlépés hosszabbíthatja az elemzőfát
// a megengedett maximális hosszabbodás: maxenf()
//
// Példa: export AMOEBA_POWER_BLACK=3,2
//  a 3-as erősséggel játszik
//  plusz az elemzőfa 2-vel szinttel mélyülhet


*****************************************************************************
function setmaxenf()
    maxenf:=if(turn_x(),maxenf_black ,maxenf_white)


*****************************************************************************
function setpower(p)
    if( valtype(p)=="N" )
        if( p==0 )
            power_current:=NIL
        else
            power_current:=width[p]
        end
    else
        if( p=="auto" )
            power_current:=NIL
        else
            power_current:=powinit(p)
        end
    end

// power_current==NIL  vagy  power_current=={4,3,2,1...}


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
    elseif( width_current::len<9999 )
        return 1
    else
        return 2 //sosem (az egyszeruseg jegyeben)
    end


*****************************************************************************
static function current_level()
static level:={POW1,POW2,POW3,POW4,POW5,POW6,POW7,POW8}
local cw:=width_current::any2str
local cl
    for cl:=8 to 1 step -1
        if( level[cl]$cw )
            exit
        end
    next
    return cl // current level: 1..8 

*****************************************************************************
