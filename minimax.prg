
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

static node
static xbest

#define  PRUNING  //  .f. .and.

*****************************************************************************
function go()

local x,v

    node:=0
    xbest:=NIL
    setwidth(movecount())
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN)
    x:=xbest

    ? turn(), "["+v::int::str(5)+"]", x::str(4), rc(x), node

    if( NIL!=x )
        forw(x)
        drawtop(x)
    end
    label_rate(v)


*****************************************************************************
static function minimax(depth,alfa,beta)

local teach:=teach()
local width:=width()
local n,fm,x,v,xopt,vopt

    //width:={4} //debug

    node++
    depth++

    if( depth>len(width) )
        movegen(8)
        vopt:=posvalue()
        leaf(depth,vopt)
        return vopt
    end

    fm:=movegen(width[depth])
    //? depth, fm
    
    if( turn_x() )
        vopt:=alfa

        for n:=1 to len(fm)
            if( forw(x:=fm[n]) )
                if( teach>=depth )
                    drawalt(x)
                    sleep(100)
                end

                v:=minimax(depth,alfa,beta)

                if( v>alfa )
                    alfa:=v
                    vopt:=v
                    xopt:=x
                end
                if( PRUNING beta<=alfa )
                    n:=9999
                end

                back()
                debug(x,v,depth)
                if( teach>=depth )
                    drawalt(x)
                end
            end
        next

        if( vopt==PVALUE_INFIN )
            vopt-=(depth-1)
        end
    end


    if( turn_o() )
        vopt:=beta

        for n:=1 to len(fm)
            x:=fm[n]
            if( forw(x) )
                if( teach>=depth )
                    drawalt(x)
                    sleep(100)
                end

                v:=minimax(depth,alfa,beta)

                if( v<beta )
                    beta:=v
                    vopt:=v
                    xopt:=x
                end
                if( PRUNING beta<=alfa )
                    n:=9999
                end

                back()
                debug(x,v,depth)
                if( teach>=depth )
                    drawalt(x)
                end
            end
        next

        if( vopt==-PVALUE_INFIN )
            vopt+=(depth-1)
        end
    end

    if( depth==1 )
        if( xopt==NIL )
            xopt:=fm[1]
        end
        xbest:=xopt
    end

    return vopt



*****************************************************************************
static function debug(x,v,depth)
static mc
    if( depth==teach() )
        if( mc!=movecount() )
            mc:=movecount()
            ? "-----------------------------------------------------------------------------";?
        end
        ?? turn(),"["+v::str::alltrim+"]";?
        c_cb_button_press_stat(x)
        fflush()
    end


*****************************************************************************
static function leaf(depth,v)

static leaf

local mc:=movecount()
local md:=mc-depth+1
local m

    if( leaf==NIL )
        set channel(leaf) to log-leaf 
    end
    set channel(leaf) on

    ? str(md,3), str(depth,2), "["+v::str(5)+"]"

    for m:=md to mc-1
        ?? str(cell(m),5)
        
        if( m==md )
            ?? "!"
        elseif( m==md+1 )
            ?? "?"
        end
    next

    set channel(leaf) off



*****************************************************************************
