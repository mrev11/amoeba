
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



#define DRAW_TABSIZE     16
#define DRAW_CELLSIZE    48
#define DRAW_ORIGO_X     40
#define DRAW_ORIGO_Y     40
#define DRAW_RADIUS      14
               

#define DRAW_BLACK(cr)   cairo_set_source_rgb(cr,0,0,0)
#define DRAW_WHITE(cr)   cairo_set_source_rgb(cr,1,1,1)
#define DRAW_EMPTY(cr)   cairo_set_source_rgb(cr,0.66,0.55,0.44)

