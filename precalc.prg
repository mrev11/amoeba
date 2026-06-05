
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

#define POSVALUE  2

static ascx:=asc("X")
static asco:=asc("O")

static width:={60,40,30,20,10,10}


******************************************************************************************
function precalc_movegen(cnt)

local result:={}
local candidates:=movegen(2*cnt)
local color:=if(turn_o(),1,-1)
local n,x,value

    for n:=1 to len(candidates)
        forw(x:=candidates[n])
        value:=color*precalc_minimax(1,-PVALUE_INFIN,PVALUE_INFIN)
        back()
        result::aadd({x,value})
    next
   
    asortkey(result,{|e|color*e[2]})

    //for n:=1 to len(result)
    //    ? n, result[n], pos2rc(result[n][1])
    //next
    //?
    
    if( len(result)>cnt )
        asize(result,cnt)
    end
    
    for n:=1 to len(result)
        //? n, result[n][1]::pos2rc::padr(3), result[n][2]
        result[n]:=result[n][1]
    next
    ?? "@"

    return result


******************************************************************************************
static function precalc_minimax(depth,alfa,beta)

local candidates,n,x,vopt
local color:=if(turn_x(),1,-1)

    depth++

    if( depth>len(width) )
        vopt:=posvalue(POSVALUE)
        return color*vopt
    end

    candidates:=movegen(width[depth])

    if( len(candidates)==0 )
        if( winner()==32  )
            vopt:=posvalue(POSVALUE)
        elseif( winner()==ascx )
            vopt:=PVALUE_INFIN
        elseif( winner()==asco )
            vopt:=-PVALUE_INFIN
        end
        return color*vopt
    end

    //negamax
    vopt:=-PVALUE_INFIN
    for n:=1 to len(candidates)
        x:=candidates[n]
        forw(x)
        vopt::=max(-precalc_minimax(depth,-beta,-alfa))
        back()
        if( alfa<vopt )
            alfa:=vopt
            if( beta<=alfa )
                exit
            end
        end
    next

    if( vopt==PVALUE_INFIN )
        vopt-=(depth-1)
    end

    if( depth==1 )
        return color*vopt
    end

    return vopt

******************************************************************************************
