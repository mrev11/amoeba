
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
function cb_load(window)

local dlg,selected_file

    if(gtk.main_depth()>1);return NIL;end

    selected_file:=selfil()
    if( selected_file==NIL )
        // nem választott
    elseif( !file(selected_file) )
        dlg:=gtkmessagedialogNew(window,;
                GTK_DIALOG_MODAL,;
                GTK_MESSAGE_WARNING,;
                GTK_BUTTONS_OK,;
                selected_file)
        dlg:set_title("File does not exist!")
        dlg:signal_connect('response',{||dlg:destroy})
        dlg:set_position(GTK_WIN_POS_MOUSE)
        dlg:run
        selected_file:=NIL
    end
    loadfile(selected_file)


******************************************************************************
function loadfile(selected_file)
local content
local cells,rates,n
local amoeba:="amoeba"+TABLESIZE::str::alltrim
local rp,rpm

    if( selected_file==NIL )
        //? "nem választott"
        return NIL
    end

    ? "LOAD FROM", selected_file

    content:=memoread(selected_file)

    if( empty(content) )
        ? "nem létezik vagy üres"
        return NIL
    end

    if( at(amoeba,content)!=1  )
        ? "nem amoeba fájl"
        return NIL
    end

    // if( content::str2bin::crc32::l2hex::padl(8,"0")!=selected_file::right(8)  )
    //  hibás CRC32
    //  így lehetne ellenőrizni a tartalom sértetlenségét
    //  de akkor kötelező volna a CRC32-es neveket használni
    //  return NIL
    // end

    content::=strtran(chr(13),"")
    content::=split(chr(10))

    if( content::len<3 )
        ? "hibás formátum1"
        return NIL
    end


    cells:=content[2]
    if( cells::left(1)!="{" .or. cells::right(1)!="}" )
        ? "hibás formátum2"
        return NIL
    end
    cells::=substr(2,len(cells)-2)::split
    for n:=1 to len(cells)
         cells[n]::=val
    next
    //? "cells",cells::len, cells::any2str


    rates:=content[3]
    if( rates::left(1)!="{" .or. rates::right(1)!="}" )
        ? "hibás formátum3"
        return NIL
    end
    rates::=substr(2,len(rates)-2)::split
    if( rates::len>cells::len )
        //compatibility
        rates::addel(1)
    end
    //? "rates",rates::len,rates
    for n:=1 to len(rates)
        rates[n]::=ratstr2numdat
    next

    c_cb_new()
    for n:=1 to len(cells)
        forw(cells[n])
        {rp,rpm}:=rates[n]
        rating_store(rp) 
        recalc_store(rpm) 
    next
    markmovecount()
    

    drawall(.t.) // törli topcell/topfig-et
    drawtop()

    label_bestline("")
    label_move()
    label_turn()
    label_rate()


******************************************************************************
static function ratstr2numdat(rs)

local rp,rpm
local rpm1,rpm2
local r,p,m
local parpos:=at("(",rs)

    if( parpos==0 )
        rp:=rs
        rpm:=""
    else
        rp:=rs[1..parpos-1]
        rpm:=rs[parpos+1..len(rs)-1]
    end

    if( empty(rp) )
        rp:={}
    else
        rp::=split("/") 
        rp::aadd("0") // compatibility
        rp[1]::=val
        rp[2]::=val
    end

    if( empty(rpm) )
        rpm:={}
    else
        {rpm1,rpm2}:=split(rpm,":")
        rpm1::=split("/")
        rpm1::aadd("0") // compatibility
        rpm1[1]::=val
        rpm1[2]::=val
        r:=rpm1[1]
        p:=rpm1[2]
        m:=rc2pos(rpm2)
        rpm:={r,p,m}
    end
    
    return {rp,rpm}


******************************************************************************
