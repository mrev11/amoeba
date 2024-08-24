
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


#include "pvalue.h"

#define MAXMOVE  128

static socket
static blink:=init_blink()
static wtime:=200 //msec
static firstmove:=.t.
static color:=getenv("AMOEBA_CLIENT")


******************************************************************************************
#clang
#include <stdint.h>
#include <gtk/gtk.h>
#undef TRUE
#undef FALSE
#include <cccapi.h>

extern void _clp_cb_timeout(int);

static gboolean itt_az_ido(gpointer data)
{
    _clp_cb_timeout(0);
    int result=(TOP()->data.flag)!=0;
    pop();
    return result;
}

#cend

******************************************************************************************
function install_cb_timeout()
#clang
    gtk_timeout_add(500,itt_az_ido,0);
#cend


******************************************************************************************
static function init_socket()

local ip:=getenv("AMOEBA_IP")
local port:=getenv("AMOEBA_PORT")

local s,c,e

    if( socket!=NIL )
        socket:close
    end

    if( empty(ip).or.empty(port) )
        return NIL
    end
    port::=val

    c:=socketNew()
    c:connect(ip,port)
    ? "connection established"
    return c // client socket


******************************************************************************************
function cb_timeout()
static locked:=.f.
local buf,n,cx,v

    //? "CB_TIMEOUT"

    if( locked )
        return .t.
    end
    locked:=.t.

    begin
        if( movecount()==0 .and. socket==NIL )
            return game()
        end
      
        if( socket==NIL )
            return .f.
        end

        buf:=socket:recvall

        if( !empty(buf) )
            cx:=buf::val
            ? "recv",cx::pos2rc
            forw(cx)
            markmovecount()
            rating_store() //delete
            recalc_store() //delete

            for n:=1 to blink
                drawtop()
                stabilize()
                sleep(wtime)

                drawcell(cx)
                stabilize()
                sleep(wtime)
            next
            drawtop()
            stabilize()
            sleep(10)

            label_move()
            label_turn()
            //label_rate()
            bestline_store({})

            if( winner()!=32 )
                return game() // vesztett 
            else
                {cx,v}:=move()
                if( winner()!=32 )
                    return game()  // nyert
                elseif( movecount()>MAXMOVE .and. abs(v|PVALUE_INFIN)<300 )
                    return game() // döntetlen
                else
                    socket:send( str(cx) )
                    ? "send", cx::pos2rc
                end
            end
        end

    finally
        locked:=.f.
    end

    return .t.


******************************************************************************************
static function move()
local cx,v

    thinklabel():set_state(.f.)
    area():set_sensitive(.f.)

    v:=go_move()

    //area():set_sensitive(.t.)
    thinklabel():set_state(.t.)

    markmovecount()
    label_move()
    label_turn()

    cx:=topcell()
    return {cx,v}



******************************************************************************************
static function game()

local mc:=movecount()
local gc:=gamecount()
local play:=nextplay()
local cx,v
static playprev


    if( socket!=NIL )
        socket:close
        socket:=NIL
    end

    if( mc>0 )
        // mc<=0 elkezdett játék
        // mc> 0 befejezett játék

        if( mc>5  )
            if( playprev!=NIL )
                playprev+="-"+color::left(1)
                playprev+=if(winner()==32,"_",lower(chr(winner())))
            end
            savegame(basename(playprev))
            animate()
            total_nodes()
        end
        gamecount(++gc)
        sleep(5000)
    end

    if( play==NIL .and. gc>=continuous_play()  )
        return .f.
    end

    socket:=init_socket()
    if( socket==NIL )
        return .f.
    end

    c_cb_new()
    stabilize()
    label_bestline()
    label_move()
    label_turn()
    label_rate()
    
    
    if( color::left(1)$'bBxX' )
        // black
        if( play!=NIL )
            loadfile(play)
            playprev:=play
            socket:send( "?"+play )
            sleep(1000)
        end
        {cx,v}:=move()
        socket:send( str(cx) )
        ? "send", cx::pos2rc

    elseif( color::left(1)$'wWoO') 
        // white
        if( play!=NIL )
            loadfile(play)
            playprev:=play
            socket:send( "!"+play )
        end

    else
        break("invalid value of AMOEBA_CLIENT(xXbBoOwW)")    
    end
    return .t.



******************************************************************************************
static function nextplay()
static plays:=initplays()
    return apop(plays)


static function initplays()
local playdir:=getenv("AMOEBA_PLAYDIR")
local tabsiz:=tablesize()::str::alltrim
local plays,n
    plays:=directory(playdir+"/amoeba"+tabsiz+"-*")
    for n:=1 to len(plays)
        plays[n]:=playdir+"/"+plays[n][1]
    next
    plays::asort
    if( !plays::empty )
        continuous_play(plays::len)
    end
    return arev(plays)


******************************************************************************************
static function basename(fn)
    if( fn!=NIL )
        return substr(fn,rat(dirsep(),fn)+1)
    end


******************************************************************************************
