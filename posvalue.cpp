
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
#include <pattern.h>
#include <cell.h>

//--------------------------------------------------------------------------
int cell::posvalue() //statikus állásértékelés
{
    if( cell::winner=='O' )
    {
        return -PVALUE_INFIN;
    }
    else if( cell::winner=='X' )
    {
        return  PVALUE_INFIN;
    }

    int oturn=((cell::movecount&1)==1);
    int xturn=((cell::movecount&1)==0);

    int v=0;
    for( int i=0; i<cell::bestcnt; i++ )
    {
        v+=cell::best[i].vt;
        v-=cell::best[i].vo;
    }

    if( oturn )
    {
        v=-v;
    }
    return v;
}


//--------------------------------------------------------------------------
