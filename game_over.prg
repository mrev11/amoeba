
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
function game_over()

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
