
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

#include <math.h>
#include <stdint.h>
#include <cairo/cairo.h>
#include <gtk/gtk.h>
#include <cccapi.h>

//----------------------------------------------------------------------------------------
void _clp_circle_image(int argno)
{
    CCC_PROLOG("circle_image",7);

    double size=_parnd(1);
    double fg_r=_parnd(2);
    double fg_g=_parnd(3);
    double fg_b=_parnd(4);
    double bg_r=_parnd(5);
    double bg_g=_parnd(6);
    double bg_b=_parnd(7);

    GdkPixmap *pixmap=gdk_pixmap_new(0,size,size,24);
    cairo_t   *cr=gdk_cairo_create(pixmap);

    //background
    cairo_set_source_rgb(cr,bg_r,bg_g,bg_b);    
    cairo_rectangle(cr,0,0,size,size);
    cairo_fill(cr);

    //foregound
    cairo_set_source_rgb(cr,fg_r,fg_g,fg_b);       
    cairo_arc(cr,size/2,size/2,size/3,0,2*M_PI);
    cairo_fill(cr);
    cairo_destroy(cr);
    
    GtkWidget *image=gtk_image_new_from_pixmap(pixmap,NULL);
    g_object_ref(image);
    _retp(image);

    CCC_EPILOG();
}


//----------------------------------------------------------------------------------------
