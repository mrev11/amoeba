
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


static node:=0
static pruning:=.t.
static cxbest

*****************************************************************************
function go1()

local x,v

    setwidth(movecount())

    v:=evaluate(0,-PVALUE_INFIN,PVALUE_INFIN)

/*
    if( NIL!=x )
        forw(x)
        drawtop(x)
    end
    
    label_rate(v)
*/
    return v


*****************************************************************************
static function evaluate(depth,alfa,beta)

local teach:=teach()
local width:=width()

local n,fm,x,v

    node++
    depth++

    if( depth>len(width) )
        movegen(4)
        return posvalue(depth)+rand()/10
    end

    fm:=movegen(width[depth])

    if( turn_x() )
        for n:=1 to len(fm)
            x:=fm[n]
            if( forw(x) )
                if( teach>=depth )
                    drawalt(x)
                    sleep(100)
                end
                v:=evaluate(depth,alfa,beta)
                if( v>alfa )
                    alfa:=v
                    cxbest:=x
                end
                if( pruning .and. beta<=alfa )
                    //?? "A"
                    n:=9999
                end
                back()
                if( teach>=depth )
                    drawalt(x)
                end
            end
        next
        return alfa
    end

    if( turn_o() )
        for n:=1 to len(fm)
            x:=fm[n]
            if( forw(x) )
                if( teach>=depth )
                    drawalt(x)
                    sleep(100)
                end
                v:=evaluate(depth,alfa,beta)
                if( v<beta )
                    beta:=v
                    cxbest:=x
                end
                if( pruning .and. beta<=alfa )
                    //?? "B"
                    n:=9999
                end
                back()
                if( teach>=depth )
                    drawalt(x)
                end
            end
        next
        return beta
    end


*****************************************************************************
