
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

#include <gtk/gtk.h>
#include <cairo/cairo.h>
#include <math.h>
#include <cccapi.h>

//----------------------------------------------------------------------------------------
void _clp_amoeba_pixbuf(int argno)
{
    CCC_PROLOG("amoeba_pixbuf",0);

    GdkPixmap *pixmap=gdk_pixmap_new(0,100,100,24);
    cairo_t   *cr=gdk_cairo_create(pixmap);

    //background
    double r=0.77;
    double g=0.66;
    double b=0.22;
    cairo_set_source_rgb(cr,r,g,b);    
    cairo_rectangle(cr,0,0,100,100);
    cairo_fill(cr);

    //grid
    cairo_set_source_rgb(cr,0,0,0);    
    cairo_set_line_width(cr,3);
    cairo_move_to(cr,50,0);
    cairo_line_to(cr,50,100);
    cairo_move_to(cr,0,50);
    cairo_line_to(cr,100,50);
    cairo_stroke(cr);

    //black circles
    cairo_set_source_rgb(cr,0,0,0);    
    cairo_new_sub_path(cr);
    cairo_arc(cr,25,25,14,0,2*M_PI);
    cairo_fill(cr);
    cairo_new_sub_path(cr);
    cairo_arc(cr,75,75,14,0,2*M_PI);
    cairo_fill(cr);

    //white circles
    cairo_set_source_rgb(cr,1,1,1);    
    cairo_new_sub_path(cr);
    cairo_arc(cr,25,75,14,0,2*M_PI);
    cairo_fill(cr);
    cairo_new_sub_path(cr);
    cairo_arc(cr,75,25,14,0,2*M_PI);
    cairo_fill(cr);

    cairo_destroy(cr);

    GdkPixbuf *pixbuf=gdk_pixbuf_get_from_drawable(NULL,pixmap,NULL,0,0,0,0,100,100);
    g_object_ref(pixbuf);
    _retp(pixbuf);

    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
