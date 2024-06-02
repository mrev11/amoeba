
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


*****************************************************************************
function main(*)

local args:={*},n
local size
local power
local file

    for n:=1 to len(args)
        if( args[n]=="-t" .and. n<len(args) )
            size:=args[++n]::val::max(10)::min(24)

        elseif( args[n]=="-p" .and. n<len(args) )
            power:=args[++n]

        elseif( file(args[n]) )
            file:=args[n]
            size:=memoread(file)::strtran("amoeba","")::val
            if( 10<=size<=24 )
                //OK
            else
                ? "Invalid amoebafile:", file
                usage()
            end
        else
            usage()
        end
    next
 
    parse_power(power)
    tablesize(size)
    cell_classinit()

    amoeba_gui(file)


******************************************************************************
static function usage()
    ?
    ? "Usage: amoeba.exe [-t <tablesize>] [-p <power>] [<amoebafile>]  "
    ?
    ? "defaults:"
    ? "     tablesize  - 12"
    ? "     power      - 0 (=auto)"
    ? "     amoebafile - empty"
    ?
    quit



******************************************************************************

