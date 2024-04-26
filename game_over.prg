
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

static maxmove:=ROWCOL
static maxdraw:=8


******************************************************************************
static function init_cp()
local env:=getenv("AMOEBA_CONTINUOUS_PLAY")
    //?  "AMOEBA_CONTINUOUS_PLAY", getenv("AMOEBA_CONTINUOUS_PLAY")
    if( empty(env) )
        return 0
    elseif( env=="true" )
        return 1
    else
        return val(env)
    end


******************************************************************************
function continuous_play(x)
static cp:=init_cp()
    if( x!=NIL )
        cp:=x
    end
    return cp


******************************************************************************
function gamecount(x)
static gc:=0
    if( x!=NIL )
        gc:=x
    end
    return gc


******************************************************************************
function drawmeter(x)
static meter:=0
    if( x!=NIL )
        meter:=x
    end
    return meter


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
local result

    if( movecount()<maxmove .and. winner()==32 .and. drawmeter()<maxdraw )
        return .f.
    end
    
    if( winner()==32 )
        ? "Draw - table is near full."
    elseif( winner()==asc("X") )
        ? "Black won."
    elseif( winner()==asc("O") )
        ? "White won."
    end

    if( 1<continuous_play() )
        log_stat(savegame())
    end

    if( gamecount()+1<continuous_play()  )
        sleep(3000)
        c_cb_new()
        drawall(.t.) // törli topcell/topfig-et
        label_bestline()
        label_move()
        label_rate()
        gamecount(gamecount()+1)
        drawmeter(0)
        return .f. // új játékot kezd
    end 

    result:=game_over_alert()

    gamecount(0)
    drawmeter(0)
    
    if( 0<continuous_play() )
        continuous_play(1)
    end

    return result


******************************************************************************
static function game_over_alert()

local dlg
local window:=mainwindow()
local text

    if( movecount()>=maxmove .or. drawmeter()>=maxdraw  )
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
