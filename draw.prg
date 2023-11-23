
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


#define BLACK       1
#define GREY        2
#define LTGREY      3
#define YELLOW      4
#define WHITE       5

#define FIG_X       1
#define FIG_O       2
#define FIG_XA      3
#define FIG_OA      4


// ilyen körök vannak
// #define CIRCLE1  chr(0x2299)
// #define CIRCLE2  chr(0x25cf) 
// #define CIRCLE3  chr(0x2609)
// #define CIRCLE4  chr(0x29be)
// #define CIRCLE5  chr(0x29bf)
// #define CIRCLE6  chr(0x2d54)
// #define CIRCLE7  chr(0x2d59)

#define CIRCLE1  chr(0x25cf) 
#define CIRCLE2  chr(0x29bf)

#define LEGACYx
#ifdef  LEGACY
  static legacy:=.t.
  static SHAPE_X:="<span size='x-large'><b>X</b></span>"    // FIG_X
  static SHAPE_O:="<span size='x-large'><b>O</b></span>"    // FIG_O
  static SHAPE_XA:="<span size='x-large'>X</span>"          // FIG_XA
  static SHAPE_OA:="<span size='x-large'>O</span>"          // FIG_OA
#else
  static legacy:=.f.
  static SHAPE_X:= "<span size='x-large'><b>"+CIRCLE1+"</b></span>"  // FIG_X
  static SHAPE_XA:="<span size='x-large'><b>"+CIRCLE2+"</b></span>"  // FIG_XA
  static SHAPE_O:=SHAPE_X
  static SHAPE_OA:=SHAPE_XA
#endif


static area:=drawingarea()


******************************************************************************
function shape_x()
    return  SHAPE_X

******************************************************************************
function shape_o()
    return  SHAPE_O


******************************************************************************
function drawall()

local cx
local fig,color
local ascx:=asc("X")
local asco:=asc("O")

    for cx:=0 to ROWCOL-1
        fig:=figure(cx)
        if( fig==ascx )
            fig:=FIG_X
            color:=BLACK
        elseif( fig==asco )
            fig:=FIG_O
            color:=WHITE
        else
            fig:=0
            color:=GREY
        end
        drawcell(cx,fig,color)
    next

    drawtop()

    gtk.main_stabilize()


******************************************************************************
function drawtop()

local top
local fig,color
local ascx:=asc("X")
local asco:=asc("O")

    if( (top:=topcell())!=NIL )
        fig:=figure(top)
        if( fig==ascx )
            fig:=if(legacy,FIG_X,FIG_XA)
            color:=if(legacy,YELLOW,BLACK)
        elseif( fig==asco )
            fig:=if(legacy,FIG_O,FIG_OA)
            color:=if(legacy,YELLOW,WHITE)
        else
            fig:=0
            color:=GREY
        end
        drawcell(top,fig,color)
    end


******************************************************************************
function draw(cx,alt,fmx)

// kirajzolja cells[cx]-et
//
// egy cella lehet üres vagy lehet benne
//
//  - 'X' (mindig fekete)
//  - 'x' (X alternatív alakja, fekete/sárga)
//  - 'O' (mindig fehér)
//  - 'o' (O alternatív alakja, fehér/sárga)
//
// ha fmx egy szám, akkor cells[x] heyén a számot jeleníti meg

local top:=topcell()
local under:=undercell()
local fig,color

    if( under!=NIL )
        //? "UNDER",figure(under)::chr
        if( figure(under)==asc("X") )
            fig:=FIG_X
            color:=BLACK
        else
            fig:=FIG_O
            color:=WHITE
        end
        drawcell(under,fig,color)
    end

    fig:=figure(cx)

    if( fig==asc(" ") )
        fig:=if(fmx==NIL,0,-fmx )
        color:=GREY

    elseif( fig==asc("X") )
        if( legacy )
            fig:=if(alt==NIL,FIG_X,FIG_XA)
            color:=if(cx==top,YELLOW,BLACK)
        else
            fig:=if(alt==NIL.and.cx<top,FIG_X,FIG_XA)
            color:=BLACK
        end

    elseif( fig==asc("O") )
        if( legacy )
            fig:=if(alt==NIL,FIG_O,FIG_OA)
            color:=if(cx==top,YELLOW,WHITE)
        else
            fig:=if(alt==NIL.and.cx<top,FIG_O,FIG_OA)
            color:=WHITE
        end
    else
        break("IDE NEM JOHET")
    end

    drawcell(cx,fig,color)

    gtk.main_stabilize()


******************************************************************************
static function drawcell(cx,fig,color)

static gc:={;
    makegc("#000000"),; //fekete
    makegc("#b0b0b0"),; //szürke
    makegc("#d0d0d0"),; //világosszürke
    makegc("#ffff00"),; //sárga
    makegc("#ffffff"),; //fehér
    NIL}

static lo:={;
    makelayout(SHAPE_X),;
    makelayout(SHAPE_O),;
    makelayout(SHAPE_XA),;
    makelayout(SHAPE_OA),;
    NIL}

static lo1:={;
    makelayout("1"),;
    makelayout("2"),;
    makelayout("3"),;
    makelayout("4"),;
    makelayout("5"),;
    makelayout("6"),;
    makelayout("7"),;
    makelayout("8"),;
    makelayout("9"),;
    NIL}

local i:=cx%TABLESIZE
local j:=int(cx/TABLESIZE)

local x:=i*CELLSIZE
local y:=j*CELLSIZE
local draw:=area:get_drawable
local dx:=5
local dy:=1

    gdk.drawable.draw_rectangle(draw,gc[GREY],.t.,x,y,CELLSIZE,CELLSIZE)
    gdk.drawable.draw_rectangle(draw,gc[BLACK],.f.,x,y,CELLSIZE,CELLSIZE)

    if( fig>0)
        gdk.drawable.draw_layout(draw,gc[color],x+dx,y+dy,lo[fig])
    elseif( fig<0 )
        gdk.drawable.draw_layout(draw,gc[BLACK],x+dx,y+dy,lo1[-fig]) //movegen
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
static function makelayout(x)
local label:=gtk.label.new(x)
    gtk.label.set_use_markup(label,.t.)
    return gtk.label.get_layout(label)


******************************************************************************
