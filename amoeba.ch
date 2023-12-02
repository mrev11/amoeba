
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


#define TABLESIZE       16
#define MAXROW          TABLESIZE
#define MAXCOL          TABLESIZE
#define ROWCOL          TABLESIZE*TABLESIZE

#define PVALUE_INFIN    9999
#define PVALUE_EGY      2000
#define PVALUE_KET2      400
#define PVALUE_KET1      100
#define PVALUE_HAR2       30
#define PVALUE_HAR1        8
#define PVALUE_NEGY2       2

//Athlon-64/3000 processzor sebességével
//üres táblán nem jó POW6-7-8-cal játszani.

#define POW0  "auto"      
#define POW1  "4,4,3,3,2,2,1,1"                //  4-ig
#define POW2  "5,4,4,3,3,2,2,1,1"              //  8-ig
#define POW3  "5,5,4,4,3,3,2,2,1,1"            // 16-ig
#define POW4  "6,5,5,4,4,3,3,2,2,1,1"          // 24-ig
#define POW5  "6,6,5,5,4,4,3,3,2,2,1,1"        // 40-ig
#define POW6  "7,6,6,5,5,4,4,3,3,2,2,1,1"      // 56-ig
#define POW7  "7,7,6,6,5,5,4,4,3,3,2,2,1,1"    // 56 fölött
#define POW8  "9,8,7,6,6,5,5,4,4,3,3,2,2,1,1"  // interaktívan beállítható

