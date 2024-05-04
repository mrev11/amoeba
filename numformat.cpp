
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


#define MAXSTR 32

//--------------------------------------------------------------------------
const char* numformat(const char *format, int num)
{
    // megformaz egy szamot
    // visszaadja a megformazott szam string pointeret
    // a visszaadott stringeket statikusan tarolja
    // egyszerre maximum MAXSTR stringet tarol
    // MAXSTR elerese utan a legregebbit elfelejti

    static int x=-1;
    static const char *ptr[MAXSTR];
    if( x==-1 )
    {
        x=0;
        for(int i=0; i<MAXSTR; i++)
        {
            ptr[i]=0;
        }
    }

    const char *p;
    if( num )
    {
        char buf[128];
        sprintf(buf,format,num);
        p=strdup(buf);

        if( ptr[x] )
        {
            free( (char*)ptr[x] );
        }
        ptr[x]=p;
        x++;
        x%=MAXSTR;
    }
    else
    {
        p="";
    }

    return p;
}

//--------------------------------------------------------------------------
