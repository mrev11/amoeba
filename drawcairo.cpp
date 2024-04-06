
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
#include <amoeba.ch>


extern double tabcolor(int);


//----------------------------------------------------------------------------------------
static int init_tablesize()
{
    extern void _clp_tablesize(int); 
    _clp_tablesize(0);
    int size=TOP()->data.number;
    pop();
    return size;
}


//----------------------------------------------------------------------------------------
static int init_cellsize()
{
    extern void _clp_cellsize(int); 
    _clp_cellsize(0);
    int size=TOP()->data.number;
    pop();
    return size;
}

//----------------------------------------------------------------------------------------
static int draw_tablesize()
{
    static int size=init_tablesize();
    return size;
}

static int draw_cellsize()
{
    static int size=init_cellsize();
    return size;
}

static int draw_origo_x()
{
    static int size=(int)(draw_cellsize()*5.0/6.0);
    return size;
}  

static int draw_origo_y()  
{
    static int size=(int)(draw_cellsize()*5.0/6.0);
    return size;
}

static int draw_radius()   
{
    static int size=(int)(draw_cellsize()*14.0/48.0);
    return size;
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
                       100+draw_tablesize()*draw_cellsize(),
                       100+draw_tablesize()*draw_cellsize());
    cairo_fill(cr);


    DRAW_EMPTY(cr);
    cairo_rectangle(cr,draw_origo_x(),draw_origo_y(),draw_tablesize()*draw_cellsize(),draw_tablesize()*draw_cellsize());
    cairo_fill(cr);

    DRAW_BLACK(cr);
    cairo_set_line_width(cr,1);
    for( int i=0; i<=draw_tablesize(); i++)
    {
        cairo_move_to(cr, draw_origo_x()                    ,draw_origo_y()+i*draw_cellsize());
        cairo_line_to(cr, draw_origo_x()+draw_tablesize()*draw_cellsize() ,draw_origo_y()+i*draw_cellsize());
    }
    for( int i=0; i<=draw_tablesize(); i++)
    {
        cairo_move_to(cr, draw_origo_x()+ i*draw_cellsize()  ,draw_origo_y()+0);
        cairo_line_to(cr, draw_origo_x()+ i*draw_cellsize()  ,draw_origo_y()+draw_tablesize()*draw_cellsize());
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

    int cs=draw_cellsize();
    int rd=draw_radius();

    if( fig==0 )
    {
        rd++;
    }

    cairo_new_sub_path(cr);
    cairo_arc(cr, draw_origo_x()+x*cs+cs/2, draw_origo_y()+y*cs+cs/2,rd,0,2*M_PI);
    setcolor(cr,fig);
    cairo_fill(cr);

    if( fig>=3 )
    {
        rd=draw_radius()*0.75;
        cairo_new_sub_path(cr);
        cairo_arc(cr, draw_origo_x()+x*cs+cs/2, draw_origo_y()+y*cs+cs/2,rd,0,2*M_PI);
        setcolor(cr,0);
        cairo_fill(cr);
    }

    if( fig>=5 )
    {
        rd=draw_radius()*0.4;
        cairo_new_sub_path(cr);
        cairo_arc(cr, draw_origo_x()+x*cs+cs/2, draw_origo_y()+y*cs+cs/2,rd,0,2*M_PI);
        setcolor(cr,fig);
        cairo_fill(cr);
    }


    cairo_destroy(cr);
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
