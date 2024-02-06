
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

#include  "draw.ch"


*****************************************************************************
function main(*)

local args:={*},n
local power
local size
local file
local game

    size:=val(getenv("AMOEBA_TABLESIZE"))

    for n:=1 to len(args)
        if( args[n]=="-t" .and. n<len(args) )
            size:=args[++n]::val

        elseif( args[n]=="-p" .and. n<len(args) )
            power:=args[++n]::val::max(0)::min(8)

        elseif( file(args[n]) )
            file:=args[n]

        else
            usage()
        end
    next

    if( file!=NIL )
        size:=memoread(file)::strtran("amoeba","")::val
    end

    if( !empty(size) )
        tablesize(size)
        cell_classinit()
    end

    if( power!=NIL )
        power(power)
    end   

    amoeba_gui(file)


******************************************************************************
static function usage()
    ?
    ? "Usage: amoeba.exe [-t <tablesize>] [-p <power>] [<amoebafile>]  "
    ?
    ? "defaults:"
    ? "     tablesize  - 16"
    ? "     power      - 0 (=auto)"
    ? "     amoebafile - empty"
    ?
    quit


******************************************************************************
function tablesize(ts)  // command line option
static tablesize:=DRAW_TABSIZE
    if( ts!=NIL )
        ts:=max(ts,12)
        ts:=min(ts,24)
        tablesize:=ts
        cairo_settabsize(ts)
        cell_settabsize(ts)
    end
    return tablesize


******************************************************************************
function power(pw)  // command line option
static power:=0
    if( pw!=NIL )
        power:=pw
    end
    return power


******************************************************************************

