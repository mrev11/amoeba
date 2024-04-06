
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

******************************************************************************
function validpos(event,xx,yy,but)

static cellsize  := cellsize()
static orig_x    := cellsize()*5/6
static orig_y    := cellsize()*5/6

local xy,x,ix,y,iy

    xx:=0 //kimenet
    yy:=0 //kimenet

    but:=gdk.event_button.get_button(event) //1,2,3 -- bal,köz,jobb

    xy:=gdk.event.get_coords(event)
    x:=xy[1]-orig_x; ix:=int(x/cellsize)
    y:=xy[2]-orig_y; iy:=int(y/cellsize)

    if( ix<0 .or. tablesize()<=ix )
        return .f.

    elseif( iy<0 .or. tablesize()<=iy )
        return .f.

    elseif( figure(iy*tablesize()+ix)!=32 )
        return .f.

    elseif( abs(x-(ix+0.5)*cellsize)>cellsize/3 )
        return .f.

    elseif( abs(y-(iy+0.5)*cellsize)>cellsize/3 )
        return .f.
    end
    
    xx:=ix //kimenet
    yy:=iy //kimenet

    return  .t.


******************************************************************************
