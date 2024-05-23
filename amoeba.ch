
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

#define VERSION         "Amoeba 2.1 for GTK2"
#define VERSION_WEB     "Amoeba 2.1 for the WEB"


#define TABLESIZE       tablesize()
#define MAXROW          TABLESIZE
#define MAXCOL          TABLESIZE
#define ROWCOL          TABLESIZE*TABLESIZE

#define CELLSIZE        cellsize()



#define POW0  "auto"
#define POW1  "4,4,3,3,2,2,1,1"                 //  2-ig
#define POW2  "5,5,4,4,3,3,2,2,1,1"             //  4-ig
#define POW3  "6,5,5,4,4,3,3,2,2,1,1"           //  8-ig
#define POW4  "6,6,5,5,4,4,3,3,2,2,1,1"         // 16-ig
#define POW5  "7,6,6,5,5,4,4,3,3,2,2,1,1"       // 32-ig
#define POW6  "7,7,6,6,5,5,4,4,3,3,2,2,1,1"     // 64-ig
#define POW7  "8,7,7,6,6,5,5,4,4,3,3,2,2,1,1"   // 64 fölött
#define POW8  "8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1" // interaktívan beállítható

