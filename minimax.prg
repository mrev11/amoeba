
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


#ifdef EROSITESEK
  (a normál 'negamax with transposition tables'-hoz képest)

  elemzőfa ága hosszabbodik,
    - ha az ág végére kényszerítő vagy kényszeritett lépés esne
    - a kényszeritett lépések után bármely mélységnél

  precalc_movegen()-nel generált lépések
     egy nagyobb választékból sekély mélységű kiértékelés sorrendjében

  movegen() pluszban beveheti az összes kényszerítő lépést
     mikor hasznos ez, kis vagy nagy mélységeknél?

  depth==1 esetén a kikényszerített lépés utáni állást nem értékeli (azonnal lép)

  a nyerőállást 2 lépésre megközelítve azonnal lép
#endif


#include "amoeba.ch"
#include "pvalue.h"

#define PRINT(x)    ? #x, any2str(x)
#define INDENT      space(4*(depth-1))

static node         // ennyi állást értékelt ki
static usecache     // hasznája-e a transposition table-t
static hit          // cache találatok száma
static fallback     // negascout visszalépés normál keresésre
static xbest        // minimax futása után a legjobb lépés
static ilevel       // info level
static maxenf       // ágak hosszabbításának maximuma
static movflg       // movegen paramétere (bevegye-e a kényszerítő lépéseket)
static posflg       // posvalue/movegen paramétere (milyen lépéseket vegyen be)
static width        // elemzőfa szélessége depth függvényében

static xresp
static vresp
static maxdepth

static ascx:=asc("X")
static asco:=asc("O")


#define EXACT           0
#define UPPERBOUND      1
#define LOWERBOUND      2

#define OPENING         8  // első néhány lépés

******************************************************************************************
function node()
    return node

******************************************************************************************
function cache_hit()
    return hit

******************************************************************************************
function fallback_count()
    return fallback

******************************************************************************************
function xbest()
    return xbest


******************************************************************************************
function minimax_config()

#ifdef NEGASCOUT
    ? "NEGASCOUT"
#else
    ? "NEGAMAX"
#endif

#ifdef CACHE
    ?? " cache"
#else
    ?? " without cache"
#endif
    ?

******************************************************************************************
function minimax_init(recalcflg:=.f.)

local mc,curlev

    curlev:=setwidth(mc:=movecount(),recalcflg)

    node:=0
    usecache:=!recalcflg
    hit:=0
    fallback:=0
    xbest:=NIL

    if( mc<=OPENING )
        width:={4}
        ilevel:=0
        maxenf:=0
        movflg:=.f.
        if( numand(mc,1)==0 )
            posflg:=4 // fekete lép (csak védekezik, nem számítja be a fekete alakzatokat)
        else                    
            posflg:=2 // fehér lép  (csak védekezik, nem számítja be a fehér alakzatokat)
        end
    else
        width:=width()
        ilevel:=infolevel()
        maxenf:=maxenf()
        movflg:=movflg()
        posflg:=NIL
    end

#ifdef PRINT_PARAMS
    PRINT(curlev)
    PRINT(node)
    PRINT(hit)
    PRINT(xbest)
    PRINT(ilevel)
    PRINT(maxenf)
    PRINT(movflg)
    PRINT(width)
    ?
#endif

    return curlev


******************************************************************************************
function minimax(depth,alfa,beta,forced_count,bestline)

local color 
local candidates,n,x
local xopt,vopt,lineopt

local value
local alfa_orig
local beta_orig
local cache
local cache_dep
local cache_val
local cache_flg
local bestline1

    node++
    depth++
    if( depth<=2 .or. maxdepth<depth )
        maxdepth:=depth
    end
    alfa_orig:=alfa
    beta_orig:=beta
    color:=if(turn_x(),1,-1)
    bestline:={}

    //? INDENT+">>MINIMAX ",depth, "", topcell()::pos2rc, " >> "

#ifdef CACHE // transposition table
    if( usecache) 
        cache:=cache_search()
    
        if( cache==NIL )
            // nincs találat
    
        elseif( depth<cache[1]   )
            // kisebb fával számolt találat
    
        else
            // használható találat
    
            hit++
    
            cache_dep:=cache[1] // depth
            cache_val:=cache[2] // value
            cache_flg:=cache[3] // flag
    
            hit_depth_histogram(cache_dep)
    
            if( cache_flg==EXACT )
                return cache_val
    
            elseif( cache_flg==LOWERBOUND )
                alfa::=max(cache_val)
    
            elseif( cache_flg==UPPERBOUND )
                beta::=min(cache_val)
            end
    
            if( alfa>=beta )
                return cache_val
            end
        end
    end
#endif

    if( depth-forced_count>len(width) )
        //elfogyott az elemzőfa

        if( .t. .and.  hot_move() .and. forced_count<maxenf+32 )
            // utolsó lépés kényszerítő vagy kényszerített, hosszabbítunk
            // print_map() 
            // ?? "FORCE-"+topcell()::figure::chr, topcell()::pos2rc::padr(3), fieldval_o(topcell()), fieldval_x(topcell());?  
            // inkey(0)

            forced_count++
        else
            // leállunk, heurisztikus érték
            vopt:=posvalue(POSVALUE,posflg)
            //? INDENT+">>RETURN-h", depth, vopt
            return color*vopt
        end

    elseif( .t. .and. enforced_move() .and. forced_count<maxenf )
        // print_map() 
        // ?? "ENFOR", topcell()::figure::chr, topcell()::pos2rc::padr(3), fieldval_o(topcell()), fieldval_x(topcell());?
        // inkey(0)
        forced_count++
    end

    if( depth<=2 .and. 10<=width[1] )
        // kétszer nagyobb halmazból
        // sekély mélységű elemzéssel választ
        candidates:=precalc_movegen(width[depth])
    else
        // movflg: beveszi a kényszerítő lépéseket
        candidates:=movegen(width[depth-forced_count], movflg.and.depth<5)
    end
    //show_candidates(depth, candidates)


    if( len(candidates)==0 )
        if( winner()==32  )
            //width=0+ eset
            vopt:=posvalue(POSVALUE)
        elseif( winner()==ascx )
            vopt:=PVALUE_INFIN
        elseif( winner()==asco )
            vopt:=-PVALUE_INFIN
        end
        //? INDENT+">>RETURN-w", depth, vopt
        return color*vopt
    end


    if( depth<=1 .and. enforcing_candidate(candidates[1]) )
        // kényszerhelyzet
        // nem értékeli az állást
        // azonnal válaszol
        xbest:=candidates[1]
        bestline:={xbest}
        //? INDENT+">>RETURN-f", depth, bestline::line2rc, vopt
        return NIL
    end

    //negamax/negascout
    vopt:=-PVALUE_INFIN
    for n:=1 to len(candidates)
        x:=candidates[n]
        forw(x)
        if( depth<=ilevel ) 
            // ezen gondolkodik (GUI)
            drawalt()
            stabilize()
            sleep(200)
        end

#ifdef NEGASCOUT
        if( n<=1 )
            value:=-minimax(depth,-beta,-alfa,forced_count,@bestline1)
        else
            value:=-minimax(depth,-alfa-1,-alfa,forced_count,@bestline1) // null window search
            if( alfa<value<beta )
                ++fallback
                value:=-minimax(depth,-beta,-alfa,forced_count,@bestline1) // mormal search
            end
        end
        vopt::=max(value)

#else //NEGAMAX
        vopt::=max(-minimax(depth,-beta,-alfa,forced_count,@bestline1))
#endif

        back()
        if( depth<=ilevel )
            // ezen gondolkodott (GUI)
            drawcell(x)
        end

        if( depth==1 )
            print_info(x,color*vopt)
            xresp:=NIL
            vresp:=NIL
        end

        if( alfa<vopt )
            alfa:=vopt
            xopt:=x
            lineopt:=bestline1
            if( depth==1 )
                // frissíti a bestline labelt (GUI)
                update_bestline(xopt,color*vopt,lineopt)
            end
            if( beta<=alfa )
                exit
            end
        end

        if( PVALUE_INFIN-vopt-depth<2 )
            // 2 lepes tavolsag a nyerestol
            // 1 lepes tavolsag -> ellenfel nyerolepese
            // 0 lepes tavolsag -> sajat nyerolepes
            // show_position(x,vopt,depth)
            exit
        end
    next


    if( vopt==PVALUE_INFIN )
        vopt-=(depth-1)
    end

    if( xopt==NIL )
        // pass
    elseif( lineopt==NIL )
        // pass
    else
        bestline:=lineopt
        bestline::aadd(xopt)
    end

    if( depth==1 )
        //? INDENT+">>RETURN-R", depth, bestline::line2rc, color*vopt
        arev(bestline)
        xbest:=xopt
        return color*vopt
    elseif( depth==2 )
        xresp:=xopt
        vresp:=color*vopt
    end


#ifdef CACHE // transposition table
    if( 2<depth )
        if( vopt<=alfa_orig )
            cache_flg:=UPPERBOUND
        elseif( beta_orig<=vopt )
            cache_flg:=LOWERBOUND
        else
            cache_flg:=EXACT
        end
        cache_insert(depth,vopt,cache_flg)
    end
#endif

    //? INDENT+">>RETURN-r", depth,  bestline::line2rc, color*vopt
    return vopt


******************************************************************************************
// debug/infó függvények
******************************************************************************************
static function print_info(x,v)
    ?? turn(),"["+v::int::str(5)+"]"
    print_pattern(x)
    if( vresp!=NIL )
        ??  vresp, pos2rc(xresp)::padr(3), maxdepth
    end
    ?


******************************************************************************************
static function update_bestline(xopt,vopt,lineopt)
local line:={xopt},n
local labtxt
    for n:=len(lineopt) to 1 step -1
        line::aadd(lineopt[n])
    next
    labtxt:=bestline_format(line,vopt,if(turn_x(),0,1))
    label_bestline(labtxt)


******************************************************************************************
static function line2rc(line)
local x:={},n
    for n:=1 to len(line)
        x::aadd(line[n]::pos2rc)
    next
    return x


******************************************************************************************
static function show_position(x,vopt,depth)

local dist

    // ha mar korabban elertuk az elemzofa levelet, akkor:

    // ilyen melyen vagyunk a faban (depth)  : depth
    // ilyen tavol vagyunk a leveltol (dist) : PVALUE_INFIN-vopt+1-depth
    // INVARIANS                             : depth+dist+vopt=PVALUE_INFIN+1

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
static function show_candidates(depth, candidates)
local n
    ?? turn(), "dep="+depth::str(1), "len="+candidates::len::str(2)+":"
    for n:=1 to len(candidates)
        ??  "",candidates[n]::pos2rc
        if( turn_x() .and. fieldval_x(candidates[n])::numand(1)==1 )
            ?? "+"
        end
        if( turn_o() .and. fieldval_o(candidates[n])::numand(1)==1 )
            ?? "+"
        end
    next
    ?

******************************************************************************************

