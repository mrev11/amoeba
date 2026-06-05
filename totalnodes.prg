
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



******************************************************************************************
function total_nodes(n,ch:=0,sf:=0)

static nodes_white:=0
static nodes_black:=0
static cache_hit:=0
static search_fallback:=0

local nodes,sec


    if( n!=NIL )
        if( turn_x() )
            nodes_black+=n
        end
        if( turn_o() )
            nodes_white+=n
        end
        cache_hit+=ch
        search_fallback+=sf

    else
        nodes:=nodes_white+nodes_black
        ? "TOTAL_NODES="+numstr(nodes)
        ?? "  white="+numstr(nodes_white)
        ?? "  black="+numstr(nodes_black)

        if( nodes>0 )
            ?? "  hit="+numstr(cache_hit)+"("+numstr(cache_hit/nodes*100)+"%)"
        end

        if( search_fallback>0 )
            ?? "  sfb="+numstr(search_fallback)
        end

        sec:=process_utime()
        if( sec>0 )
            ?? "  time="+timestr(sec)
            ?? "  "+numstr(nodes/sec)+"/s"
        end

        ?? "  winner="+if(winner()==32,"D",chr(winner()))

    end

    return nodes_white+nodes_black


******************************************************************************************
static function numstr(num)
    return transform(num,"999,999,999,999")::alltrim


******************************************************************************************
function timestr(sec)
local s:=sec%60
local m:=(sec-s)/60
    return m::str::alltrim+"m"+s::str::alltrim+"s"


******************************************************************************************

