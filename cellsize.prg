
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

// Ezek CCC-ből és C++-ból is meghívható függvények


#clang
#include <cccapi.h>

//----------------------------------------------------------------------------------------
int size_cellsize() //eredetileg 48
{
    static int size=48;
    static int init=0;
    if( !init )
    {
        init=1;
        const char *env=getenv("AMOEBA_CELLSIZE");
        if( env && *env )
        {
            int s;
            sscanf(env,"%d",&s);
            s=max(s,32);
            s=min(s,64);
            size=s;
        }
    }
    return size;
}

//----------------------------------------------------------------------------------------
int size_origo_x() //eredetileg 40
{
    return (int)(size_cellsize()*((double)40/(double)48));
}


//----------------------------------------------------------------------------------------
int size_origo_y() //eredetileg 40
{
    return (int)(size_cellsize()*((double)40/(double)48));
}


//----------------------------------------------------------------------------------------
int size_radius() //eredetileg 14
{
    return (int)(size_cellsize()*((double)14/(double)48));
}

#cend


******************************************************************************************
function size_cellsize()
local size
#clang
    number( size_cellsize() );
    assign(LOCAL_size);
    pop();
#cend
    return size


******************************************************************************************
function size_origo_x()
local size
#clang
    number( size_origo_x() );
    assign(LOCAL_size);
    pop();
#cend
    return size


******************************************************************************************
function size_origo_y()
local size
#clang
    number( size_origo_y() );
    assign(LOCAL_size);
    pop();
#cend
    return size


******************************************************************************************
function size_radius()
local size
#clang
    number( size_radius() );
    assign(LOCAL_size);
    pop();
#cend
    return size


******************************************************************************************
