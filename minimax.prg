
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

static node                      // ennyi állást értékelt ki
static xbest                     // minimax futása után a legjobb lépés
static treshold:=treshold()      // ha megközelíti a nyerést, nem keres mégjobbat
static movestack:=array(ROWCOL)  // csak debug


******************************************************************************************
function node()
    return node

******************************************************************************************
function xbest()
    return xbest


******************************************************************************************
function minimax(depth,alfa,beta,bestline,forced_count)

local width:=width()
local maxenf:=maxenf()
local ilevel:=infolevel()
local candidate_move,n,x,xopt,vopt
local bestline1:={}

    if( depth==0 )
        node:=0
        xbest:=NIL
    end

    node++
    depth++

    if( depth-forced_count>len(width) )
        movegen(10)
        vopt:=posvalue()
        //leaf(depth,vopt,alfa,beta)
        return vopt
    end

    candidate_move:=movegen(width[depth-forced_count])

    if( len(candidate_move)==0 )
        vopt:=if(turn_x(),-PVALUE_INFIN,PVALUE_INFIN )
        return vopt
    end

    if( maxenf>forced_count .and. enforced(candidate_move[1]) )
        ++forced_count
    end

    if( turn_x() )
        vopt:=-PVALUE_INFIN

        for n:=1 to len(candidate_move)
            x:=candidate_move[n]
            movestack[depth]:=x
            forw(x)
            if( ilevel>=depth )
                drawalt()
                sleep(100)
            end
            vopt:=max(vopt,minimax(depth,alfa,beta,@bestline1,forced_count))
            back()
            if( ilevel>=depth )
                drawcell(x)
                if( depth>1 )
                    drawalt()
                end
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

            if( vopt>PVALUE_INFIN-treshold )
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
                sleep(100)
            end
            vopt:=min(vopt,minimax(depth,alfa,beta,@bestline1,forced_count))
            back()
            if( ilevel>=depth )
                drawcell(x)
                if( depth>1 )
                    drawalt()
                end
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

            if( vopt<-PVALUE_INFIN+treshold )
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
        c_cb_button_press_stat(x)
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
    //log:on
    ? turn(), depth,v,alfa,beta,line
    //log:off


******************************************************************************************
static function update_bestline(depth,pos,val,bestline)

local labtxt,n,rc,color,cx

    bestline::aiins(1,pos)

    if( depth==1 )

        labtxt:=" <span color='green'>("+val::str::alltrim+")</span>  "

        color:={"'black'","'white'"}
        cx:=if(turn_x(),0,1)
        for n:=1 to len(bestline)
            rc:=pos2rc(bestline[n])
            labtxt+="<span color="+color[cx+1]+">"+rc+"</span> "
            cx:=(cx+1)%2
        next

        if( abs(val)>9000 )
            labtxt::=strtran("green","red")
            if( val>0 )
                labtxt+="<span color='black'>#</span>"
            else
                labtxt+="<span color='white'>#</span>"
            end
        end
        label_bestline(labtxt)
    end

    return bestline


******************************************************************************************
static function enforced(cx,depth)
local enforced
    enforced := turn_x().and.fieldval_o(cx)>=PVALUE_EGY .or.;
                turn_o().and.fieldval_x(cx)>=PVALUE_EGY

    //if( enforced )
    //    ??  "ENFORCED",;
    //        turn(),;
    //        cx::pos2rc::padr(3),;
    //        fieldval_x(cx),"X",;
    //        fieldval_o(cx),"O",;
    //        movestack[1..depth-1]::line2str
    //        ""
    //    ?
    //end

    return enforced

static function line2str(line)
local x:="",n
    if( !empty(line) )
        x:=str(len(line),4)+":"
        x+=line[1]::pos2rc
        for n:=2 to len(line)
            x+=","+line[n]::pos2rc
        next
    end
    return x

******************************************************************************************

