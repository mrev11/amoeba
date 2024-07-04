
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



#define MAXMOVE  128

static socket
static blink:=init_blink()
static wtime:=200 //msec
static firstmove:=.t.
static color:=getenv("AMOEBA_COLOR")


******************************************************************************************
#clang
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
local cx,buf,n

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

            if( winner()!=32 .or. movecount()>MAXMOVE   )
                return game() // vesztett vagy döntetlen
            else
                move()
                if( winner()!=32 .or. movecount()>MAXMOVE   )
                    return game() // nyert vagy döntetlen
                end
            end
        end

    finally
        locked:=.f.
    end

    return .t.


******************************************************************************************
static function move()
local cx

    if( movecount()==0 )
        cell_randomize()
    elseif( movecount()==1 )
        cell_randomize(topcell())
    end

    thinklabel():set_state(.f.)
    area():set_sensitive(.f.)

    go_move()

    //area():set_sensitive(.t.)
    thinklabel():set_state(.t.)

    markmovecount()
    label_move()
    label_turn()

    cx:=topcell()
    socket:send( str(cx) )
    ? "send", cx::pos2rc



******************************************************************************************
static function game()

local mc:=movecount()
local gc:=gamecount()

    if( socket!=NIL )
        socket:close
        socket:=NIL
    end

    if( mc>0 )
        // mc==0 elkezdett káték
        // mc>=1 befejezett játék
        gamecount(++gc)
        total_nodes()
        sleep(5000)
    end

    if( gc>=continuous_play()  )
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

    if( color::left(1)=='b' )
        move()
    end
    return .t.



******************************************************************************************
