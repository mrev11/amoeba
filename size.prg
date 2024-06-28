
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


#clang
#include <cccapi.h>

int tablesize()
{
    _clp_tablesize(0);
    int size=(int)(TOP()->data.number+0.5);
    return size;
}

int cellsize()
{
    _clp_cellsize(0);
    int size=(int)(TOP()->data.number+0.5);
    return size;
}
#cend


******************************************************************************************
function tablesize(x)
static size:=init_tablesize()
    if( x!=NIL )
        size:=x
    end
    return size

static function init_tablesize()
local x:=val(getenv("AMOEBA_TABLESIZE"))
    if( x==0 )
        x:=16
    else
        x:=max(x,10)
        x:=min(x,24)
    end
    return x


******************************************************************************************
function cellsize(x)
static size:=init_cellsize()
    if( x!=NIL )
        size:=x
    end
    return size

static function init_cellsize()
local x:=val(getenv("AMOEBA_CELLSIZE"))
    if( x==0 )
        x:=48
    else
        x:=max(x,32)
        x:=min(x,96)
    end
    return x

******************************************************************************************


