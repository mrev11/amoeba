
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
function cb_save(window) // interaktív mentés

local dlg,selected_file,name
local content:=content(@name)

    selected_file:=selfil(name)
    if( selected_file==NIL )
        // nem választott
    elseif( file(selected_file) )
        dlg:=gtkmessagedialogNew(window,;
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
        ? "SAVE TO",selected_file
        memowrit(selected_file,content)
    end


******************************************************************************
function save_game() // mentés dialog nélkül
local content,name
    content:=content(@name)
    ? "SAVE TO",name
    memowrit(name,content)
    return name


******************************************************************************
static function content(name)

local index:=0,cellid
local cells:={},rates:={}
local amoeba:="amoeba"+TABLESIZE::str::alltrim
local content:=""

    if(gtk.main_depth()>1);return NIL;end

    while( NIL!=(cellid:=cell(index++)) )
        aadd(cells,cellid)
        aadd(rates,rating_string(index)+recalc_string(index))
    end

    //? "cells",cells::len, cells::any2str // számok
    //? "rates",rates::len, rates          // C stringek

    cells::=any2str
    rates::=any2str::strtran('"','')

    content:=amoeba+"("+VERSION+")"+chr(10)
    content+=cells+chr(10)
    content+=rates+chr(10)
    content+=chr(winner())+chr(10)

    name:=amoeba+"-"+content::str2bin::crc32::l2hex::padl(8,"0")

    return content


******************************************************************************






