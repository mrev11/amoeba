


#define DRAW_BLACK(cr)   cairo_set_source_rgb(cr,0,0,0)
#define DRAW_WHITE(cr)   cairo_set_source_rgb(cr,1,1,1)
#define DRAW_EMPTY(cr)   cairo_set_source_rgb(cr,0.66,0.66,0.5)


#include <cairo/cairo-svg.h>
#include <stdio.h>
#include <math.h>

#define SIZE    40.0
#define RADIUS  14.0

//----------------------------------------------------------------------------------------
int main(int argc, char **argv) 
{
    cairo_surface_t *surface;
    cairo_t *cr; 

    surface = cairo_svg_surface_create("black.svg",SIZE,SIZE);
    cr = cairo_create(surface);
    DRAW_BLACK(cr); 
    cairo_new_sub_path(cr);
    cairo_arc(cr,SIZE/2,SIZE/2,RADIUS,0,2*M_PI);
    cairo_fill(cr);
    cairo_destroy(cr);
    cairo_surface_destroy(surface);


    surface = cairo_svg_surface_create("white.svg",SIZE,SIZE);
    cr = cairo_create(surface);
    DRAW_WHITE(cr); 
    cairo_new_sub_path(cr);
    cairo_arc(cr,SIZE/2,SIZE/2,RADIUS,0,2*M_PI);
    cairo_fill(cr);
    cairo_destroy(cr);
    cairo_surface_destroy(surface);
}

//----------------------------------------------------------------------------------------
