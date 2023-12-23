
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


#define FIG_EMPTY   0
#define FIG_X       1
#define FIG_O       2
#define FIG_XA      3
#define FIG_OA      4
#define FIG_XT      5
#define FIG_OT      6


static area:=drawingarea()
static ascx:=asc("X")
static asco:=asc("O")

static altflag:=.f.


******************************************************************************
function drawcell(cx,fig)
local x:=cx%TABLESIZE
local y:=int(cx/TABLESIZE)
    if( fig==NIL )
        fig:=figure(cx)
        if( fig==ascx )
            fig:=FIG_X
        elseif( fig==asco )
            fig:=FIG_O
        else
            fig:=FIG_EMPTY
        end
    end
    cairo_drawcell(area:gobject,x,y,fig)
    gtk.main_stabilize()


******************************************************************************
function drawalt(cx)
local fig
    fig:=figure(cx)
    if( fig==ascx )
        altflag:=.t.
        fig:=FIG_XA
    elseif( fig==asco )
        altflag:=.t.
        fig:=FIG_OA
    else
        altflag:=.f.
        fig:=FIG_EMPTY
    end
    drawcell(cx,fig)


******************************************************************************
function drawtop()
local top,fig
    if( (top:=topcell())!=NIL )
        fig:=figure(top)
        if( fig==ascx )
            fig:=FIG_XT
        elseif( fig==asco )
            fig:=FIG_OT
        else
            fig:=FIG_EMPTY
        end
        drawcell(top,fig)
    end
        

******************************************************************************
function drawall()
local cx,top

    cairo_drawgrid(area:gobject)
    scale()

    top:=topcell()
    for cx:=0 to ROWCOL-1
        if( cx!=top )
            drawcell(cx)
        end
    next

    if( top!=NIL )
        if(altflag,drawalt(top),drawtop())
    end


******************************************************************************
function drawclean(flag)
static f:=.f.
    if( flag!=NIL )
        f:=flag
    elseif( f )
        drawall()
        f:=.f.
    end


******************************************************************************
function drawnum(cx,num)

local i:=cx%TABLESIZE
local j:=int(cx/TABLESIZE)
local draw:=area:get_drawable
local x,y
static gc:=makegc("#000000")

    if( figure(cx)==asc(" ") .and. num<=9 )
        x:=(i+1)*CELLSIZE + CELLSIZE/5
        y:=(j+1)*CELLSIZE + CELLSIZE/10+if(CELLSIZE<40,-4,0)
        gdk.drawable.draw_layout(draw,gc,x,y,numlayout(num))
    end


******************************************************************************
static function makegc(colorspec)
local color:=gdk.color.new()
local gc:=gdk.gc.new(area:get_drawable)
    gdk.color.parse(colorspec,color)
    gdk.gc.set_rgb_fg_color(gc,color)
    gdk.color.free(color)
    return gc


******************************************************************************
static function numlayout(n) // n=0...99
static label:=array(100)
local  x:=n+1
    if( label[x]==NIL )
        if( CELLSIZE>=40 )
            label[x]:=gtklabelNew("<b>"+n::str::alltrim+"</b>")
            label[x]:set_use_markup(.t.)
        else
            label[x]:=gtklabelNew(n::str::alltrim)
        end
    end 
    return label[x]:get_layout()


******************************************************************************
static function abclayout(n) // n=0...99
static label:=array(100)
static a:=asc("a")
local  x:=n+1
    if( label[x]==NIL )
        if( CELLSIZE>=40 )
            label[x]:=gtklabelNew( "<b>"+chr(a+n)+"</b>" )
            label[x]:set_use_markup(.t.)
        else
            label[x]:=gtklabelNew(chr(a+n))
        end
    end 
    return label[x]:get_layout()


******************************************************************************
static function scale()

static gc:=makegc("#000000")
local draw:=area:get_drawable
local i,x,y,dx,dy,cs

    cs:=CELLSIZE

    //horizontal:012
    for i:=0 to TABLESIZE-1
        dx:=cs*0.1 + if(i<10,cs*0.1,0)
        dy:=cs*0.2 + if(cs<40,-2,0)

        x:=dx + (i+1)*cs
        y:=dy
        gdk.drawable.draw_layout(draw,gc,x,y,numlayout(i+1))
    next

    //vertical:abc
    for i:=0 to TABLESIZE-1
        dx:=cs*0.3 + if(cs<40,-2,0)
        dy:=cs*0

        x:=dx
        y:=dy + (i+1)*cs
        gdk.drawable.draw_layout(draw,gc,x,y,abclayout(i))
    next

******************************************************************************
