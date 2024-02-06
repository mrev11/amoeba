
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

#include "gdk.ch"
#include "gtk.ch"

#include "amoeba.ch"
#include "tabsize.ch"


******************************************************************************
function continuous_play()
static env:=getenv("AMOEBA_CONTINUOUS_PLAY")
    return env


******************************************************************************
static function log_stat(name)
local ch,w,pb,pw,mc

    w:=chr(winner())
    w::=strtran(" ","=")
    
    pb:="PB:"+power_black()::padr(4)
    pw:="PW:"+power_white()::padr(4)
    mc:=movecount()

    SET CHANNEL(ch) to amoeba-stat additive
    SET CHANNEL(ch) on 

    ?? w, pb , pw , mc, name, chr(10)

    SET CHANNEL(ch) off
    SET CHANNEL(ch) to


******************************************************************************
function game_over()

local master 

    if( movecount()<ROWCOL .and. winner()==32 )
        return .f.
    end

    if( "game"$continuous_play()  )

        master:=(rating_load(1)!=NIL) 
        // master == .t.
        // ha nem tandem módban játszik 
        // ha a tandemben ez a példány kezdett

        if( master )
            log_stat(save_game())
        end

        c_cb_new()
        drawall(.t.) // törli topcell/topfig-et
        label_bestline("")
        label_move()
        label_rate()
        tandem_truncate()

        if( empty(tandem_file()) )
            //nem tandem 
            sleep(1000)
        elseif( master )
            //tandem master
            sleep(5000)
        else
            //tandem slave
            sleep(10000)
        end

        return .f. // új játékot kezd
    end 

    return game_over_alert()


******************************************************************************
static function game_over_alert()

local dlg
local window:=mainwindow()
local text

    if( movecount()>=ROWCOL )
        dlg:=gtkmessagedialogNew(window,;
                GTK_DIALOG_MODAL,;
                GTK_MESSAGE_INFO,;
                GTK_BUTTONS_OK,;
                "Draw!" )
        dlg:set_title("TABLE IS FULL")
        dlg:set_size_request(300,100)
        dlg:signal_connect('response',{||dlg:destroy})
        dlg:set_position(GTK_WIN_POS_MOUSE)
        dlg:run
        return .t.
    end

    if( winner()==asc('X') )
        text:="Black won!"
    elseif( winner()==asc('O') )
        text:="White won!"
    else
        return .f.     
    end

    dlg:=gtkmessagedialogNew(window,;
            GTK_DIALOG_MODAL,;
            GTK_MESSAGE_ERROR,;
            GTK_BUTTONS_OK,;
            text )
    dlg:set_title("GAME OVER")
    dlg:set_size_request(300,100)
    dlg:signal_connect('response',{||dlg:destroy})
    dlg:set_position(GTK_WIN_POS_MOUSE)
    dlg:run

    return .t.     


******************************************************************************
function mainwindow(w)
static window
    if( w!=NIL )
        window:=w
    end
    return window


******************************************************************************
