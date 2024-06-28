
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

#define PRINT(x)    ? #x, any2str(x)

static width  // {{w11,...},{w21,...},...,{w81,...}}

static power_current

static width_current
static width_black:=NIL
static width_white:=NIL

static maxenf_current
static maxenf_black:=0
static maxenf_white:=0

static movflg_current
static movflg_black:=.f.
static movflg_white:=.f.


******************************************************************************
function parse_power(p:=getenv("AMOEBA_POWER"))
local pw:=p::strtran(".","!")::val::max(0)::min(8)  // tizedespont!

    opt_power(pw)

    if( "+"$p )
        movflg_black:=.t.
        movflg_white:=.t.
    end

    if( "-"$p )
        movflg_black:=.f.
        movflg_white:=.f.
    end

    maxenf_white:=val(p::split(".")::asize(2)[2]|"0")::min(10)::max(0)
    maxenf_black:=val(p::split(".")::asize(2)[2]|"0")::min(10)::max(0)

    width:=init_width()

    width_black:=init_width_black()
    width_white:=init_width_white()

    maxenf_black:=init_maxenf_black()
    maxenf_white:=init_maxenf_white()

    movflg_black:=init_movflg_black()
    movflg_white:=init_movflg_white()
    

#ifndef PRINT_POWER
    //PRINT (width)
    PRINT (power_current)
    PRINT (width_current)
    PRINT (width_black)
    PRINT (width_white)
    PRINT (maxenf_current)
    PRINT (maxenf_black)
    PRINT (maxenf_white)
    PRINT (movflg_current)
    PRINT (movflg_black)
    PRINT (movflg_white)
#endif


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
static function powinit(p)
local n
    p:=split(p)
    for n:=1 to len(p)
        p[n]:=val(p[n])
    next
    return p


*****************************************************************************
static function init_width_black()
local pw:=power_black()
    if( pw::empty )
        return NIL
    end
    pw::=val
    pw::=max(1)
    pw::=min(8)
    ?? "Black plays at power", power_black(), width[pw]::any2str
    ?
    return width[pw]


static function init_width_white()
local pw:=power_white()
    if( pw::empty )
        return NIL
    end
    pw::=val
    pw::=max(1)
    pw::=min(8)
    ?? "Black plays at power", power_white(), width[pw]::any2str
    ?
    return width[pw]


*****************************************************************************
static function init_maxenf_black()
local pw:=power_black()
local enf:=pw::split::asize(2)[2]
    if( enf!=NIL )
        return enf::val
    end
    return maxenf_black // nem változik
    
    
static function init_maxenf_white()
local pw:=power_white()
local enf:=pw::split::asize(2)[2]
    if( enf!=NIL )
        return enf::val
    end
    return maxenf_white // nem változik


*****************************************************************************
static function init_movflg_black()
local pw:=power_black()
    if( '+'$pw )
        return .t.
    elseif( '-'$pw )
        return .f.
    end
    return movflg_black // nem változik


static function init_movflg_white()
local pw:=power_white()
    if( '+'$pw )
        return .t.
    elseif( '-'$pw )
        return .f.
    end
    return movflg_white // nem változik


*****************************************************************************
function power_black()
static power:=getenv("AMOEBA_POWER_BLACK")
    return power


*****************************************************************************
function power_white()
static power:=getenv("AMOEBA_POWER_WHITE")
    return power


*****************************************************************************
function width() // aktuális elemzőfa
    return aclone(width_current)


*****************************************************************************
function setwidth(movecount, recalc:=.f. )
local w
    if( !recalc .and. turn_x() .and. width_black!=NIL )
        width_current:=width_black

    elseif( !recalc .and. turn_o() .and. width_white!=NIL )
        width_current:=width_white

    elseif( power_current!=NIL )
        width_current:=power_current

    elseif( movecount<8 )
        width_current:=width[1]

    elseif( movecount<16 )
        width_current:=width[2]

    elseif( movecount<32 )
        width_current:=width[3]

    else
        width_current:=width[4]

    end

    setmaxenf()
    setmovflg()

    return current_level()


*****************************************************************************
function setmaxenf()
    maxenf_current:=if(turn_x(),maxenf_black ,maxenf_white)


*****************************************************************************
function maxenf()
    return maxenf_current

// kényszerlépés hosszabbíthatja az elemzőfát
// a megengedett maximális hosszabbodás: maxenf()
//
// Példa: export AMOEBA_POWER_BLACK=3,2
//  a 3-as erősséggel játszik
//  plusz az elemzőfa 2-vel szinttel mélyülhet


*****************************************************************************
function setmovflg()
    movflg_current:=if(turn_x(),movflg_black ,movflg_white)


*****************************************************************************
function movflg()
    return movflg_current

// bevegyen-e movegen minden  kényszerítő lépést


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
    cache_clean()


// power_current==NIL  vagy  power_current=={4,3,2,1...}


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

