
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


******************************************************************************
function cb_save() // interaktív mentés
local dlg,selected_file,name

    if(gtk.main_depth()>1)
        return NIL
    end

    name:=uniquename()

    selected_file:=selfil(name)
    if( selected_file==NIL )
        // nem választott
    elseif( file(selected_file) )
        dlg:=gtkmessagedialogNew(mainwindow(),;
                GTK_DIALOG_MODAL,;
                GTK_MESSAGE_WARNING,;
                GTK_BUTTONS_YES_NO,;
                selected_file)
        dlg:set_title("File exists, do you want to replace it?")
        dlg:signal_connect('response',{|w,r|if(r==GTK_RESPONSE_NO,selected_file:=NIL,NIL),dlg:destroy})
        dlg:set_position(GTK_WIN_POS_MOUSE)
        dlg:run
    end

    if( selected_file!=NIL )
        savefile(selected_file)
    end


******************************************************************************
function savegame(filename:=uniquename()) // mentés dialog nélkül
    savefile(filename)
    return filename


******************************************************************************
static function savefile(filename)

local channel
local n,cellid
local move,rate,calc,line

    ? "SAVE TO",filename

    channel:=channelNew(filename)
    channel:open
    channel:on

    ?? "amoeba"+TABLESIZE::str::alltrim+"("+VERSION+")";?
    
    
    ?? spiral(1)::str::alltrim
    for n:=2 to TABLESIZE**2
        ?? ","+spiral(n)::str::alltrim
    next
    ?
    
    
    n:=0
    while( NIL!=(cellid:=cell(n++)) )
        move:=pos2rc(cellid)
        rate:=rating_string(n)::strtran("n.a.","")
        calc:=recalc_string(n)::strtran("n.a.","")
        line:=bestline_string(n)

        ??  n::str::alltrim+","+move
        if( !empty(rate) .or. !empty(calc) .or. !empty(line) )
            ?? ","+rate
        end
        if( !empty(calc) .or. !empty(line) )
            ?? ","+calc
        end
        if( !empty(line) )
            ?? ","+line
        end
        ?
    end
    ?? chr(winner())

    channel:off
    channel:close


******************************************************************************
static function uniquename()
local amoeba:="amoeba"+TABLESIZE::str::alltrim
local game:="",cellid,n
    n:=0
    while( NIL!=(cellid:=cell(n++)) )
        game+=pos2rc(cellid)
    end
    for n:=1 to ROWCOL
        game+=spiral(n)::str::alltrim
    next
    return amoeba+"-"+game::str2bin::crc32::l2hex::padl(8,"0")


******************************************************************************
