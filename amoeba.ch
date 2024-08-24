
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

#define VERSION         "Amoeba 3.2 (PVS) for GTK2"
#define VERSION_WEB     "Amoeba 3.2 (PVS) for the WEB"


#define TABLESIZE       tablesize()
#define MAXROW          TABLESIZE
#define MAXCOL          TABLESIZE
#define ROWCOL          TABLESIZE*TABLESIZE


#define POW0  "auto"
#define POW1  "11,11,10,4"
#define POW2  "12,11,10,5,4"
#define POW3  "13,11,10,5,5,4"
#define POW4  "14,12,10,6,5,5,4"
#define POW5  "15,12,11,6,6,5,5,4"
#define POW6  "16,12,11,6,6,6,5,5,4"
#define POW7  "17,14,11,8,8,6,6,5,5,4"
#define POW8  "18,17,16,9,8,7,7,6,6,5,4"
//              1  2  3 4 5 6 7 8 9 0 1
//
// -p 8.10+ beallitassal a Bovo 'Impossible' idejenek kb. 2/3-at hasznalja



#define CACHE
#define NEGASCOUT

#define POSVALUE   10
#define MAXENF     50

