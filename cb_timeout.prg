
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



#define MAXMOVE  100


static socket:=init_socket()
static first_move:=.f.
static first_player:=.f.


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
local p,s,c,e
    if( empty(p:=getenv("AMOEBA_PORT")) )
        return NIL
    end
    p::=val

    begin    
        c:=socketNew()
        c:connect("localhost",p)
        ? "client connection established"
        //first_move:=.t.
        return c // client socket
    recover e
        ? "connect failed, attempt to be the server..."
    end

    // nem tudtunk konnektálni
    // akkor szerver leszünk

    s:=socketNew()
    s:reuseaddress(.t.)
    s:bind("localhost",p) // server socket
    s:listen
    c:=s:accept
    s:close
    //first_move:=.f.
    ? "server connection established"
    
    return c  // client socket


******************************************************************************************
function cb_timeout(flag:=.f.)

local cx,buf

    //? "CB_TIMEOUT ",flag,first_move

    if( socket==NIL )
        return .f.
    end

    if( flag )
        first_move:=.t.
        //?? " SET-FIRST-ON"
        return .t.
    end

    if( first_move )
        first_move:=.f.
        first_player:=.t.
        //?? " SET-FIRST-OFF"
        move()
        cx:=topcell()
        socket:send( str(cx) )
        //?? " send", str(cx), cx::pos2rc 
    end

    buf:=socket:recvall

    if( !empty(buf) )
        cx:=buf::val
        //?? " recv",cx::pos2rc
        forw(cx)
        markmovecount()
        rating_store() //delete
        recalc_store() //delete
        drawtop()
        stabilize()
        label_move()
        label_turn()
        label_rate()
        bestline_store({})

        if( (movecount()>MAXMOVE .or. winner()!=32) .and. gamecount()+1<continuous_play() )
            // vesztett
            total_nodes()
            start_game()

        elseif( !game_over() )
            move()
            cx:=topcell()
            socket:send( str(cx) )

            if( movecount()>MAXMOVE .or. winner()!=32 )
                // nyert
                total_nodes()
                if( gamecount()+1<continuous_play() )
                    start_game()
                end
            end
        end
    else
        //?? "wait"
    end

    return .t.


******************************************************************************************
static function move()
    if( !game_over() )
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
    end


******************************************************************************************
static function start_game()
    if( first_player )
        savegame()
        first_move:=.t.
    end
    sleep(5000)
    c_cb_new()
    stabilize()
    label_bestline()
    label_move()
    label_turn()
    label_rate()
    gamecount(gamecount()+1)


******************************************************************************************
