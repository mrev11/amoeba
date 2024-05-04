
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
#include <openssl/rand.h>
#include <cell.h>

//--------------------------------------------------------------------------
void cell::randomize() // újragenerálja a dist tagokat és rendezi a spirált
{
    int r=cell::tablesize/2;
    int c=cell::tablesize/2;
    cell:randomize(r,c);
}

//--------------------------------------------------------------------------
void cell::randomize(int cx) // újragenerálja a dist tagokat és rendezi a spirált
{
    int r=cx/cell::tablesize;
    int c=cx%cell::tablesize;
    cell:randomize(r,c);
}

//--------------------------------------------------------------------------
void cell::randomize(int r, int c) // újragenerálja a dist tagokat és rendezi a spirált
{
    for( int cx=0; cx<(cell::tablesize*cell::tablesize); cx++ )
    {
        cell::cells[cx]->calcdist(r,c);
    }
    qsort(cell::spiral,(cell::tablesize*cell::tablesize),sizeof(int),cell::cmp_dist);
}


//--------------------------------------------------------------------------
double cell::calcdist(int r, int c) // távolság a cx cellától
{
    unsigned char d;
    RAND_bytes(&d,1);
    dist=sqrt((row-r)*(row-r)+(col-c)*(col-c))+(int)d/256.0; //+[0,1)
    return dist;
}

//--------------------------------------------------------------------------
