
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
#include "pvalue.h"


******************************************************************************************
function go_move()

local x,v,n
local curlev
local bestline:={}
local rts,pws

    if( topcell()!=NIL )
        drawcell(topcell())
    end

    ? "-----------------------------------------------------------------------------------"

    if( continuous_play()>1 )
        ?  "Game="+(1+gamecount())::str::alltrim+"/"+continuous_play()::str::alltrim
        ?? " Move="+(1+movecount())::str::alltrim
        ?? " Draw="+drawmeter()::str::alltrim
    end
    ?

    curlev:=init_minimax()
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,@bestline,0)
    x:=xbest()

    if( v==0 )
        drawmeter(drawmeter()+1)
    else
        drawmeter(0)
    end

    total_nodes(node())

    if( NIL!=x )

        rts:=ratestr(v,curlev) // forw elott
        pws:=powstr(curlev)    // forw elott

        ? turn(), "["+valstr(v)+"]", pos2rc(x)::padr(3),;
            " Nodes="+nodestr(node())," Power="+pws, bestline::line2str(v)

        forw(x)

        rating_store(rts) // forw utan
        recalc_store() // forw utan (delete)
        bestline_store(bestline)
        label_rate()

        for n:=1 to 3
            drawcell(x)
            sleep(100)
            drawtop()
            sleep(100)
        next
    end


******************************************************************************************
function go_recalc()

local cx,x,v,n
local curlev
local bestline:={}
local rts,pws

    cell_save()

    cx:=back()
    if( cx==NIL  )
        return NIL
    end

    ? "===================================================================================";?

    drawcell(cx)
    label_turn()

    curlev:=init_minimax(.t.)
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN,@bestline,0)
    x:=xbest()

    if( NIL!=x )

        rts:=calcstr(v,curlev,x) // forw elott
        pws:=powstr(curlev)      // forw elott

        ? turn(), "["+valstr(v)+"]", pos2rc(x)::padr(3),;
            " Nodes="+nodestr(node()), " Power="+pws, bestline::line2str(v)

        forw(x)

        recalc_store(rts) 
        bestline_store(bestline)
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
static function line2str(line,v)
local x:="",n
    if( !empty(line) .and. v!=NIL )
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
static function valstr(v)
    return if( v==NIL, space(5), v::int::str(5) )


******************************************************************************************
static function nodestr(n)
    return n::transform("999,999,999,999",n)::alltrim


******************************************************************************************
static function powstr(x) // forw() elott kell hivni
    x::=str::alltrim
    if( turn_x() .and. movegen_black()==0 )
        x+="+"
    end
    if( turn_o() .and. movegen_white()==0 )
        x+="+"
    end
    return x


******************************************************************************************
static function ratestr(v,curlev)  // forw() elott kell hivni
local str
    if( v!=NIL )
        str:=v::str::alltrim
        str+="/"+powstr(curlev)
    end
    return str|""


******************************************************************************************
static function calcstr(v,curlev,move)  // forw() elott kell hivni
local str:=ratestr(v,curlev)
    str+=":"+pos2rc(move)
    return str


******************************************************************************************

    