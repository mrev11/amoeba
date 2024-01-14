


#define DRAW_BLACK(cr)   cairo_set_source_rgb(cr,0,0,0)
#define DRAW_WHITE(cr)   cairo_set_source_rgb(cr,1,1,1)
#define DRAW_EMPTY(cr)   cairo_set_source_rgb(cr,0.77,0.66,0.22)


#include <cairo/cairo-svg.h>
#include <stdio.h>
#include <math.h>

//----------------------------------------------------------------------------------------
int main(int argc, char **argv) 
{
    cairo_surface_t *surface = cairo_svg_surface_create("amoeba.svg", 100.0, 100.0);
    cairo_t *cr = cairo_create(surface);

    DRAW_EMPTY(cr);
    cairo_rectangle(cr,0,0,100,100);
    cairo_fill(cr);

    DRAW_BLACK(cr);
    cairo_move_to(cr,50,0);
    cairo_line_to(cr,50,100);
    cairo_move_to(cr,0,50);
    cairo_line_to(cr,100,50);
    cairo_set_line_width(cr,3);
    cairo_stroke(cr);

    cairo_new_sub_path(cr);
    cairo_arc(cr,25,25,16,0,2*M_PI);
    cairo_new_sub_path(cr);
    cairo_arc(cr,75,75,16,0,2*M_PI);
    cairo_fill(cr);
    
    DRAW_WHITE(cr);
    cairo_arc(cr,75,25,16,0,2*M_PI);
    cairo_new_sub_path(cr);
    cairo_arc(cr,25,75,16,0,2*M_PI);
    cairo_fill(cr);


    cairo_destroy(cr);
    cairo_surface_destroy(surface);
}

//----------------------------------------------------------------------------------------
