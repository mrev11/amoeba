
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

#include "gdk.ch"
#include "gtk.ch"

#include "amoeba.ch"
#include "tabsize.ch"

******************************************************************************
function validpos(event,x,y,but)

static cellsize  := DRAW_CELLSIZE
static orig_x    := DRAW_ORIGO_X
static orig_y    := DRAW_ORIGO_Y

local xy:=gdk.event.get_coords(event)

    x:=xy[1]
    y:=xy[2]
    but:=gdk.event_button.get_button(event) //1,2,3 -- bal,köz,jobb

    if( x%cellsize<2 .or. x%cellsize>cellsize-2 )
        return .f.
    elseif( y%cellsize<2 .or. y%cellsize>cellsize-2 )
        return .f.
    end

    x:=int(x/cellsize)-1
    y:=int(y/cellsize)-1

    if( x<0 .or. tablesize()<=x )
        return .f.
    elseif( y<0 .or. tablesize()<=y )
        return .f.
    elseif( figure(y*tablesize()+x)!=32 )
        return .f.
    end

    return  .t.


******************************************************************************
