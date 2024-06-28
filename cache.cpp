
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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cell.h>

#include <cccapi.h>

#define CACHESIZE   0x3ffff     // ekkora egy hash tábla
#define CACHEMASK   0xf         // ennyi darab hash tábla (kb 4 millio állás)



//----------------------------------------------------------------------------------------
struct NODE
{
    ZCODE       code;
    unsigned    depth;
    signed      value;
    unsigned    flag;
};

//----------------------------------------------------------------------------------------
struct CACHE
{
    NODE node[CACHESIZE+1];

    CACHE()
    {
        memset(this,0,sizeof(CACHE));
    }

    NODE *search(ZCODE code)
    {
        int x=code&CACHESIZE;
        if( node[x].code==code )
        {
            return &node[x]; // talált
        }
        else
        {
            return 0; // nem talált
        }
    }

    void insert( ZCODE code, unsigned depth, signed value, unsigned flag)
    {
        int x=code&CACHESIZE;
        node[x].code  = code ;
        node[x].depth = depth;
        node[x].value = value;
        node[x].flag  = flag ;
    }
};


static CACHE cache[CACHEMASK+1];

// ha a tablan mc darab kő van, akkor a
//      cache[mc&CACHEMASK]
// példány tartalmazza az állás adatait


//----------------------------------------------------------------------------------------
void _clp_cache_search(int argno)
{
    CCC_PROLOG("cache_search",0);
    NODE *node=0;
    if( cell::code )
    { 
        node=cache[ CACHEMASK & cell::movecount ].search(cell::code);
    }
    else
    {
        // üres táblán cell::code==0
        // üresre nem adunk találatot
    }

    if( node )
    {
        //printf("FOUND %08x %d\n",cell::code, cell::movecount);
        number( node->depth );
        number( node->value );
        number( node->flag  );
        array(3);
    }
    else
    {
        _ret();
    }
    _rettop();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
void _clp_cache_insert(int argno)
{
    CCC_PROLOG("cache_insert",3);
    unsigned depth = _parni(1);
    signed   value = _parni(2);
    signed   flag  = _parni(3);
    cache[ CACHEMASK & cell::movecount ].insert(cell::code, depth, value, flag);
    _ret();
    CCC_EPILOG();
}


//----------------------------------------------------------------------------------------
void _clp_cache_clean(int argno)
{
    CCC_PROLOG("cache_clean",0);
    memset(cache,0,sizeof(cache));
    _ret();
    CCC_EPILOG();
}


//----------------------------------------------------------------------------------------
