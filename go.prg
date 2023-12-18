
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

#include "amoeba.ch"
#include "tabsize.ch"


******************************************************************************************
function treshold()
    return len(width())*0.5


******************************************************************************************
function go_recalc()

local cx,x,v,n

    label_bestline("")

    cell_save()

    cx:=back()
    if( cx==NIL  )
        return NIL
    end

    ? "=============================================================================";?

    drawcell(cx)

    setwidth(movecount(),.t.)
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,"")
    x:=xbest()

    ? turn(), "["+v::int::str(5)+"]", rc(x)::padr(3), node(), any2str(width())

    label_rate(v)

    if( NIL!=x )
        forw(x)
        for n:=1 to 5
            drawcell(x)
            sleep(300)
            drawtop(x)
            sleep(300)
        next
        back()
        drawcell(x)
    end

    forw(cx)
    drawtop()

    cell_restore()


******************************************************************************************
function go_move()

local x,v,n

    label_bestline("")

    ? "-----------------------------------------------------------------------------";?

    setwidth(movecount())
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,"")
    x:=xbest()

    ? turn(), "["+v::int::str(5)+"]", rc(x)::padr(3), node(), any2str(width())

    if( NIL!=x )
        forw(x)
        for n:=1 to 3
            drawcell(x)
            sleep(80)
            drawtop(x)
            sleep(80)
        next
    end

    label_rate(v)
    


******************************************************************************************


