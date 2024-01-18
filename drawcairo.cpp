
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

#include <gdk/gdk.h>
#include <gtk/gtk.h>
#include <math.h>

#include <cccapi.h>
#include <draw.ch>


extern int size_cellsize();
extern int size_origo_x();
extern int size_origo_y();
extern int size_radius();

extern double tabcolor(int);


static int tablesize    = DRAW_TABSIZE;
static int cellsize     = DRAW_CELLSIZE;
static int origo_x      = DRAW_ORIGO_X ;
static int origo_y      = DRAW_ORIGO_Y;
static int radius       = DRAW_RADIUS;


//----------------------------------------------------------------------------------------
void _clp_cairo_settabsize(int argno)
{
    CCC_PROLOG("cairo_settabsize",1);
    tablesize=_parni(1);
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
void _clp_cairo_drawgrid(int argno)
{
    CCC_PROLOG("cairo_drawgrid",1);
    GtkWidget *da=(GtkWidget *)_parp(1); //drawing area
    cairo_t *cr=gdk_cairo_create(da->window);

    double bc=0xb8/256.0;
    cairo_set_source_rgb(cr,bc,bc,bc);
    cairo_rectangle(cr,0,0,
                       100+tablesize*cellsize,
                       100+tablesize*cellsize);
    cairo_fill(cr);


    DRAW_EMPTY(cr);
    cairo_rectangle(cr,origo_x,origo_y,tablesize*cellsize,tablesize*cellsize);
    cairo_fill(cr);

    DRAW_BLACK(cr);
    cairo_set_line_width(cr,1);
    for( int i=0; i<=tablesize; i++)
    {
        cairo_move_to(cr, origo_x                    ,origo_y+i*cellsize);
        cairo_line_to(cr, origo_x+tablesize*cellsize ,origo_y+i*cellsize);
    }
    for( int i=0; i<=tablesize; i++)
    {
        cairo_move_to(cr, origo_x+ i*cellsize  ,origo_y+0);
        cairo_line_to(cr, origo_x+ i*cellsize  ,origo_y+tablesize*cellsize);
    }
    cairo_stroke(cr);

    cairo_destroy(cr);
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
static void setcolor(cairo_t *cr, int fig)
{
   if( fig==0 )
    {
        DRAW_EMPTY(cr);
    }
    else if( fig&1 )
    {
        DRAW_BLACK(cr);
    }
    else
    {
        DRAW_WHITE(cr);
    }
}

//----------------------------------------------------------------------------------------
void _clp_cairo_drawcell(int argno)  // gobject,x,y,fig
{
    //static int count=0;

    CCC_PROLOG("cairo_drawcell",4);
    GtkWidget *da=(GtkWidget *)_parp(1); //drawing area
    cairo_t *cr=gdk_cairo_create(da->window);
    int x=_parni(2);
    int y=_parni(3);
    int fig=_parni(4);


    //printf("drawcell(%5d): x=%2d y=%2d fig=%d\n", ++count,  x,y,fig); fflush(0);

    // fig==0 empty
    // fig==1 black
    // fig==2 white
    // fig==3 alt-black
    // fig==4 alt-white
    // fig==5 top-black
    // fig==6 top-white

    int cs=cellsize;
    int rd=radius;

    if( fig==0 )
    {
        rd++;
    }

    cairo_new_sub_path(cr);
    cairo_arc(cr, origo_x+x*cs+cs/2, origo_y+y*cs+cs/2,rd,0,2*M_PI);
    setcolor(cr,fig);
    cairo_fill(cr);

    if( fig>=3 )
    {
        rd=radius*0.75;
        cairo_new_sub_path(cr);
        cairo_arc(cr, origo_x+x*cs+cs/2, origo_y+y*cs+cs/2,rd,0,2*M_PI);
        setcolor(cr,0);
        cairo_fill(cr);
    }

    if( fig>=5 )
    {
        rd=radius*0.4;
        cairo_new_sub_path(cr);
        cairo_arc(cr, origo_x+x*cs+cs/2, origo_y+y*cs+cs/2,rd,0,2*M_PI);
        setcolor(cr,fig);
        cairo_fill(cr);
    }


    cairo_destroy(cr);
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
