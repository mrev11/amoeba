
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

static node
static xbest
static treshold

#define PRUNING         //  .f. .and.


******************************************************************************************
function go_eval()

local cx,x,v,n

    cell_save()

    cx:=back()
    if( cx==NIL  )
        return NIL
    end

    ? "=============================================================================";?

    drawcell(cx)

    node:=0
    xbest:=NIL
    setwidth(movecount(),.t.)
    treshold:=len(width())*0.5
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN)
    x:=xbest

    ? turn(), "["+v::int::str(5)+"]", rc(x), node, any2str(width()), treshold

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
function go()

local x,v,n

    ? "-----------------------------------------------------------------------------";?

    node:=0
    xbest:=NIL
    setwidth(movecount())
    treshold:=len(width())*0.5
    v:=minimax(0,-PVALUE_INFIN,PVALUE_INFIN)
    x:=xbest

    ? turn(), "["+v::int::str(5)+"]", rc(x), node, any2str(width())

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
static function minimax(depth,alfa,beta)

local width:=width()
local ilevel:=infolevel()
local n,fm,x,v,xopt,vopt

    //width:={4} //debug

    node++
    depth++

    if( depth>len(width) )
        movegen(6)
        vopt:=posvalue()
        //leaf(depth,vopt)
        return vopt
    end

    fm:=movegen(width[depth])

    if( len(fm)==0 )
        vopt:=if(turn_x(),-PVALUE_INFIN,PVALUE_INFIN )
        return vopt
    end

    if( turn_x() )
        vopt:=alfa

        for n:=1 to len(fm)
            forw(x:=fm[n])
            if( ilevel>=depth )
                drawalt(x)
                sleep(100)
            end

            v:=minimax(depth,alfa,beta)

            back()
            if( ilevel>=depth )
                drawalt(x)
            end
            info(x,v,depth)

            if( v>alfa )
                alfa:=v
                vopt:=v
                xopt:=x
            end

            if( PRUNING beta<=alfa )
                exit
            elseif( v>PVALUE_INFIN-treshold )    
                exit
            end
        next

        if( vopt==PVALUE_INFIN )
            vopt-=(depth-1)
        end
    end

    if( turn_o() )
        vopt:=beta

        for n:=1 to len(fm)
            forw(x:=fm[n])
            if( ilevel>=depth )
                drawalt(x)
                sleep(100)
            end

            v:=minimax(depth,alfa,beta)

            back()
            if( ilevel>=depth )
                drawalt(x)
            end
            info(x,v,depth)

            if( v<beta )
                beta:=v
                vopt:=v
                xopt:=x
            end

            if( PRUNING beta<=alfa )
                exit
            elseif( v<-PVALUE_INFIN+treshold )    
                exit
            end
        next

        if( vopt==-PVALUE_INFIN )
            vopt+=(depth-1)
        end
    end

    if( depth==1 )
        xbest:=xopt
    end
    return vopt


******************************************************************************************
static function info(x,v,depth)
local r,c
    if( depth<=1 )
        #define SHORT
        #ifdef  SHORT
            c:=x%MAXCOL
            r:=(x-c)/MAXCOL
            ?? space((depth-1)*4)
            ?? turn(),;
               "["+v::str(5)+"]",;
               "{"+r::str(2)+","+c::str(2)+"}",;
               node,depth
            ?
        #else
            ?? turn(),"["+v::str::alltrim+"]";?
            c_cb_button_press_stat(x)
        #endif
    end


******************************************************************************************
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



******************************************************************************************
