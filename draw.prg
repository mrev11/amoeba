
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
#define FIG_XT      3
#define FIG_OT      4
#define FIG_XA      5
#define FIG_OA      6


// ilyen körök vannak
//
//  chr(0x2299)
//  chr(0x25cf) 
//  chr(0x2609)
//  chr(0x29be)
//  chr(0x29bf)
//  chr(0x2d54)
//  chr(0x2d59)


#define CIRCLE1  chr(0x25cf) 
#define CIRCLE2  chr(0x29bf)
#define CIRCLE3  chr(0x2d54)

#define xLEGACY
#ifdef  LEGACY
  static legacy:=.t.
  static SHAPE_X :="<span size='x-large'><b>X</b></span>"   // FIG_X
  static SHAPE_O :="<span size='x-large'><b>O</b></span>"   // FIG_O

  static SHAPE_XT:=SHAPE_X                                  // FIG_XT
  static SHAPE_OT:=SHAPE_O                                  // FIG_OT

  static SHAPE_XA:="<span size='x-large'>X</span>"          // FIG_XA
  static SHAPE_OA:="<span size='x-large'>O</span>"          // FIG_OA
#else
  static legacy:=.f.
  static SHAPE_X :="<span size='x-large'><b>"+CIRCLE1+"</b></span>"  // FIG_X
  static SHAPE_XT:="<span size='x-large'><b>"+CIRCLE2+"</b></span>"  // FIG_XT (top)
  static SHAPE_XA:="<span size='x-large'><b>"+CIRCLE3+"</b></span>"  // FIG_XA (alt)

  static SHAPE_O:=SHAPE_X
  static SHAPE_OT:=SHAPE_XT
  static SHAPE_OA:=SHAPE_XA
#endif


static area:=drawingarea()
static ascx:=asc("X")
static asco:=asc("O")

static altflag:=.f.


******************************************************************************
function shape_x()
    return  SHAPE_X

******************************************************************************
function shape_o()
    return  SHAPE_O


******************************************************************************
function drawall()
local cx,top

    top:=topcell()

    for cx:=0 to ROWCOL-1
        if( cx!=top )
            drawcell(cx)
        end
    next

    if( top!=NIL )
        if(altflag,drawalt(top),drawtop())
    end

// Probléma, hogy gtk.main_stabilize()-ból általában (de nem mindig) 
// meghívódik cb_expose(), aminek újra kell tudnia rajzolni a képet.
//
// main_stabilize -> cb_expose -> drawall -> drawcell -> main_stabilize
//
// (Tehát ebben eleve van egy rekurzió, amit a rendszer valahogy kivéd.)
// Tudni kell, milyen alakzat van a top-ban, ezért kell az altflag-es szarság.


******************************************************************************
function drawtop()

local top
local fig,color

    if( (top:=topcell())!=NIL )
        fig:=figure(top)
        if( fig==ascx )
            fig:=FIG_XT
            color:=if(legacy,YELLOW,BLACK)
        elseif( fig==asco )
            fig:=FIG_OT
            color:=if(legacy,YELLOW,WHITE)
        else
            fig:=0
            color:=GREY
        end
        drawcell(top,fig,color)
    end
        

******************************************************************************
function drawalt(cx)
local fig,color

    fig:=figure(cx)
    if( fig==ascx )
        altflag:=.t.
        fig:=FIG_XA
        color:=if(legacy,YELLOW,BLACK)
    elseif( fig==asco )
        altflag:=.t.
        fig:=FIG_OA
        color:=if(legacy,YELLOW,WHITE)
    else
        altflag:=.f.
        fig:=0
        color:=GREY
    end

    drawcell(cx,fig,color)


******************************************************************************
function drawnum(cx,num)
local fig,color
    fig:=figure(cx)
    if( fig==asc(" ") .and. num<=9 )
        fig:=-num
        color:=GREY
        drawcell(cx,fig,color)
    end


******************************************************************************
function drawcell(cx,fig,color)

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
    makelayout(SHAPE_XT),;
    makelayout(SHAPE_OT),;
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

    if( fig==NIL .and. color==NIL )
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
    end

    gdk.drawable.draw_rectangle(draw,gc[GREY],.t.,x,y,CELLSIZE,CELLSIZE)
    gdk.drawable.draw_rectangle(draw,gc[BLACK],.f.,x,y,CELLSIZE,CELLSIZE)

    if( fig>0)
        gdk.drawable.draw_layout(draw,gc[color],x+dx,y+dy,lo[fig])
    elseif( fig<0 )
        gdk.drawable.draw_layout(draw,gc[BLACK],x+dx,y+dy,lo1[-fig]) //movegen
    end

    gtk.main_stabilize()


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
