
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

#include "draw.ch"

#define VERSION         "Amoeba 3.0 for GTK2 scout"
#define VERSION_WEB     "Amoeba 3.0 for the WEB"


#define TABLESIZE       tablesize()
#define MAXROW          TABLESIZE
#define MAXCOL          TABLESIZE
#define ROWCOL          TABLESIZE*TABLESIZE

#define CELLSIZE        cellsize()

#define CIRCLE_NORMAL   0
#define CIRCLE_SMALL    1


#define POW0  "auto"
#define POW1  "11,6,4,3,2"                       //  8-ig
#define POW2  "12,7,5,4,3,3"                     // 16-ig
#define POW3  "13,8,6,4,4,3,3"                   // 32-ig
#define POW4  "14,8,6,5,4,4,3,3"                 // 32 fölött
#define POW5  "15,8,7,5,5,4,4,3,3"               // interaktívan beállítható
#define POW6  "16,9,7,6,5,5,4,4,3,3"             // interaktívan beállítható
#define POW7  "17,9,8,7,6,6,5,5,4,4,3,3"         // interaktívan beállítható
#define POW8  "18,9,8,7,6,5,5,5,4,4,4,3,3,3"     // interaktívan beállítható


#define CACHE
#define NEGASCOUT

#define POSVALUE   10
