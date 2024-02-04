
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
local curlev
local bestline:={}

    //label_bestline("")

    cell_save()

    cx:=back()
    if( cx==NIL  )
        return NIL
    end

    ? "=============================================================================";?

    drawcell(cx)
    label_turn()

    curlev:=setwidth(movecount(),.t.)
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,@bestline,0)
    x:=xbest()

    ? turn(), "["+v::int::str(5)+"]", pos2rc(x)::padr(3), node(), bestline::line2str(v) 


    if( NIL!=x )
        forw(x)

        recalc_store({v,curlev,x})
        label_rate()

        for n:=1 to 5
            drawcell(x)
            sleep(300)
            drawtop()
            sleep(300)
        next
        back()
        drawcell(x)
    end

    forw(cx)
    drawtop()
    label_turn()
    cell_restore()




******************************************************************************************
function go_move()

local x,v,n
local curlev
local bestline:={}

    //label_bestline("")
    if( topcell()!=NIL )
        drawcell(topcell())
    end

    ? "-----------------------------------------------------------------------------";?

    curlev:=setwidth(movecount())
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,@bestline,0)
    x:=xbest()

    ? turn(), "["+v::int::str(5)+"]", pos2rc(x)::padr(3), node(), bestline::line2str(v)

    if( NIL!=x )
        forw(x)

        rating_store({v,curlev})
        label_rate()

        for n:=1 to 3
            drawcell(x)
            sleep(80)
            drawtop()
            sleep(80)
        next
    end


******************************************************************************************
static function line2str(line,v)
local x:="",n
    if( !empty(line) )
        x:=str(len(line),4)+":"
        x+=line[1]::pos2rc
        for n:=2 to len(line)
            x+=","+line[n]::pos2rc
        next
        if( abs(v)>9000 )
            x+="#"
        end
    end
    return x


******************************************************************************************


