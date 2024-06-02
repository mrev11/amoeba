
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

static node         // ennyi állást értékelt ki
static xbest        // minimax futása után a legjobb lépés
static width        // elemzofa szelessege
static turn         // ki gondolkodik
static ilevel
static maxenf

static movestack:=array(ROWCOL)
static ascx:=asc("X")
static asco:=asc("O")


******************************************************************************************
function node()
    return node

******************************************************************************************
function xbest()
    return xbest


******************************************************************************************
function init_minimax(swflg)
local mc,curlev

    curlev:=setwidth(mc:=movecount(),swflg)

    node:=0
    xbest:=NIL
    width:=width()
    turn:=if(0==movecount()%2,ascx,asco)
    maxenf:=maxenf()
    ilevel:=infolevel()

    if( mc<5 )
        width:={6,5,4,3,2,1}
    end

    return curlev


******************************************************************************************
function minimax(depth,alfa,beta,bestline,forced_count)

local candidate_move,n,x,xopt,vopt
local bestline1:={}
local winner

    node++
    depth++

    if( depth-forced_count>len(width) )
        vopt:=posvalue(10)
        bestline:={}
        //leaf(depth,vopt,alfa,beta)
        return vopt
    end

    candidate_move:=movegen(width[depth-forced_count],turn)

    if( len(candidate_move)==0 )
        winner:=winner()
        if( winner==32  )
            vopt:=posvalue(10)
        elseif( winner==asco )
            vopt:=-PVALUE_INFIN
        elseif( winner==ascx )
            vopt:=PVALUE_INFIN
        end         
        return vopt
    end

    if( enforced(candidate_move[1]) )
        // kényszerhelyzet
        if( depth<=1 )
            // azonnal válaszol
            xbest:=candidate_move[1]
            return NIL
        elseif( forced_count<maxenf )
            // hosszabbítja az elemzőfát
            // (be nem vált kísérlet)
            ++forced_count
        end
    end

    if( turn_x() )
        vopt:=-PVALUE_INFIN

        for n:=1 to len(candidate_move)
            x:=candidate_move[n]
            movestack[depth]:=x
            forw(x)
            if( ilevel>=depth )
                drawalt()
                stabilize()
                sleep(200)
            end
            vopt:=max(vopt,minimax(depth,alfa,beta,@bestline1,forced_count))
            back()
            if( ilevel>=depth )
                drawcell(x)
            end
            info(depth,x,vopt)

            if( vopt>alfa )
                alfa:=vopt
                xopt:=x
                bestline:=update_bestline(depth,x,vopt,bestline1)
                if( vopt>=beta )
                    exit
                end
            end

            if( PVALUE_INFIN-vopt-depth<2 )
                // 2 lepes tavolsagra vagyunk a fa leveletol 
                // 0 lepes tavolsag -> fekete nyerolepes, mar breakelt (alfa==beta)
                // 1 lepes tavolsag -> feher nyerolepes, masik program ag kezeli
                // 2 lepes tavolsag -> akkor jon ide
                // 3 vagy tobb      -> folytatja a ciklust
                // showpos(x,vopt,depth)
                exit
            end
        next

        if( vopt==PVALUE_INFIN )
            vopt-=(depth-1)
        end
    end

    if( turn_o() )
        vopt:=+PVALUE_INFIN

        for n:=1 to len(candidate_move)
            x:=candidate_move[n]
            movestack[depth]:=x
            forw(x)
            if( ilevel>=depth )
                drawalt()
                stabilize()
                sleep(200)
            end
            vopt:=min(vopt,minimax(depth,alfa,beta,@bestline1,forced_count))
            back()
            if( ilevel>=depth )
                drawcell(x)
            end
            info(depth,x,vopt)

            if( vopt<beta )
                beta:=vopt
                xopt:=x
                bestline:=update_bestline(depth,x,vopt,bestline1)
                if( vopt<=alfa )
                    exit
                end
            end

            if( PVALUE_INFIN+vopt-depth<2 )
                // 2 lepes tavolsagra vagyunk a fa leveletol 
                // showpos(x,vopt,depth)
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
static function info(depth,x,v)

//#define NOTDEF
#ifdef NOTDEF
    // ezzel + a tree.exe programmal
    // vizsgálni (browse-olni) lehet az elemzőfát
    // a log-amoeba-ban maradó infó alapján
    local level:=1
    if( depth<=level )
        ?? space((depth-1)*4)
        ?? turn(), "["+v::int::str(5)+"]", pos2rc(x)::padr(3), node
        ?
    end
#else
    if( depth==1 )
        ?? turn(),"["+v::int::str(5)+"]"
        print_pattern(x)
        ?
    end
#endif


******************************************************************************************
static function leaf(depth,v,alfa,beta)

static log
local line,n

    line:=pos2rc(movestack[1])
    for n:=2 to depth-1
        line+=","+pos2rc(movestack[n])
    next

    if( log==NIL )
        log:=channelNew("log-leaf")
        log:open
    end
    log:on
    ? turn(), depth,v,alfa,beta,line
    log:off


******************************************************************************************
static function update_bestline(depth,pos,val,bestline)

local labtxt

    bestline::aiins(1,pos)

    if( depth==1 )
        labtxt:=bestline_format(bestline,val,if(turn_x(),0,1))
        label_bestline(labtxt)
    end

    return bestline



******************************************************************************************
static function enforced(cx,depth)
local enforced
    enforced := turn_x() .and. fieldval_o(cx)>=PVALUE_EGY .or.;
                turn_o() .and. fieldval_x(cx)>=PVALUE_EGY 
    return enforced


******************************************************************************************
static function enforce(cx,depth)
local enforced
    enforced := turn_o() .and. 0!=numand(fieldval_o(cx),1) .or.;
                turn_x() .and. 0!=numand(fieldval_x(cx),1)
    return enforced


******************************************************************************************
function showpos(x,vopt,depth)

local dist

    // ha mar korabban elertuk az elemzofa levelet, akkor:

    // ilyen melyen vagyunk a faban (depth)  : depth                      
    // ilyen tavol vagyunk a leveltol (dist) : PVALUE_INFIN-vopt+1-depth  
    // INVARIANS                             : depth+dist+vopt=PVALUE+1

    dist:=PVALUE_INFIN-abs(vopt)+1-depth

    forw(x)
    drawalt()
    stabilize()

    ?? movecount()::str::alltrim+":"+pos2rc(x)
    ?? " vopt="+vopt::str::alltrim 
    ?? " depth="+depth::str::alltrim 
    ?? " dist="+dist::str::alltrim 
    ?? " press any key ..." 
    ?

    inkey(0)

    back()
    drawcell(x)
    stabilize()

******************************************************************************************

