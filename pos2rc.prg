
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
#include "pvalue.h"


******************************************************************************
function pos2rc(pos)
local r,c
    if( pos==NIL )
        r:="-"
        c:="-"
    else
        r:=chr(97+int(pos/TABLESIZE))
        c:=(1+(pos%TABLESIZE))::str::alltrim
    end
    return r+c


******************************************************************************
function rc2pos(rc)
local row:=rc[1..1]::asc-97
local col:=rc[2..]::val-1
    return  row*TABLESIZE+col


******************************************************************************
function pos2rcx(pos,settled:=.f.)
    return pos2rc(pos)+enforced_sign(pos,settled)


******************************************************************************
static function enforced_sign(x,settled)

local sign:=""

local tnx:=turn_x()
local tno:=turn_o()
local fvx:=fieldval_x(x)
local fvo:=fieldval_o(x)

    if( settled )
        // send-nel a ko mar le van rakva
        
        if( winner()!=32)
            sign:="#"
        elseif( tnx .and. fvo::numand(1)==1 )
             sign:="+"
        elseif( tno .and. fvx::numand(1)==1 )
             sign:="+"
        end

    else
        // recv-nel a ko meg nincs lerakva
        if( tnx )
            if( fvx>=PVALUE_EGY )
                sign:="#"
            elseif( fvx::numand(1)==1 )
                sign:="+"
            end
        elseif( tno )
            if( fvo>=PVALUE_EGY )
                sign:="#"
            elseif( fvo::numand(1)==1 )
                sign:="+"
            end
        end
    end

    return sign


******************************************************************************

