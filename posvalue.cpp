
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


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/rand.h>

#include <cccapi.h>

#include <amoeba.ch>
#include <tabsize.h>
#include <pattern.h>
#include <cell.h>


//--------------------------------------------------------------------------
int cell::posvalue() //statikus állásértékelés
{
    int v=0;

    if( cell::winner=='O' )
    {
        v=-PVALUE_INFIN;
    }
    else if( cell::winner=='X' )
    {
        v=PVALUE_INFIN;
    }
    else
    {
        for( int i=0; i<cell::bestcnt; i++ )
        {
            v+=cell::best[i].vt;
            v-=cell::best[i].vo;
        }
        if( cell::movecount&1 )
        {
            v=-v;
        }
    }

    //printf("POSVALUE=%d movecount=%d ",v,cell::movecount);
    //if( cell::movecount>0 )
    //{
    //    int cx=cell::movestack[cell::movecount-1];
    //    printf( "lastmove=%d{%d,%d}\n",cx,cx/TABLESIZE,cx%TABLESIZE );
    //}
    //else
    //{
    //    printf("\n");
    //}

    return v;
}


//--------------------------------------------------------------------------
