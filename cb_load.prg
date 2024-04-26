
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
function cb_load()

local dlg,selected_file

    if(gtk.main_depth()>1)
        return NIL
    end

    selected_file:=selfil()
    if( selected_file==NIL )
        // nem választott
    elseif( !file(selected_file) )
        dlg:=gtkmessagedialogNew(mainwindow(),;
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

local amoeba:="amoeba"+TABLESIZE::str::alltrim
local content,spiral,line,n,p

    if( selected_file==NIL )
        //? "nem választott"
        return NIL
    end

    ? "LOAD FROM", selected_file

    content:=memoread(selected_file)
    content::=strtran(chr(13),"")
    content::=split(chr(10))
    if( content::len<3 )
        ? "hibás formátum1"
        return NIL
    end
    if( at(amoeba,content[1])!=1  )
        ? "hibás formátum2"
        return NIL
    end

    c_cb_new()

    spiral:=content[2]::split
    for n:=1 to len(spiral)
        spiral(n,val(spiral[n]))
    next

    for n:=3 to len(content)-1  // utolso sor: 'X'/'O'/' '
        line:=content[n]::split
        if( len(line)>=2 )
            forw(rc2pos(line[2]))
        end
        
        if( len(line)>=3 )
            rating_store(line[3])
        end
        if( len(line)>=4 )
            recalc_store(line[4])
        end
        if( len(line)>=5 )
            line:=line[5..]
            p:=0;aeval(line,{||++p,line[p]::=rc2pos})
            bestline_store(line)
        end
       
    next

    markmovecount()

    drawall(.t.) // törli topcell/topfig-et
    drawtop()

    label_bestline()
    label_move()
    label_turn()
    label_rate()


******************************************************************************
