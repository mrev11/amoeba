
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
function tree(tree)
    set printer to amoeba
    set printer on
    set console off
    aview(tree)
    set printer to 
    set printer off
    set console on
    run("less amoeba &")


*****************************************************************************
static function aview(a)
static d:=0
local n
    for n:=1 to len(a)
        if( valtype(a[n])=="A" )
            d++
            aview(a[n])
            d--
        else
            ? space(d*16),"[",a[n],"]"
        end
    next


*****************************************************************************
