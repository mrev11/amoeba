
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
function printpid()
    set printer to pid
    set printer on
    ?? getpid()
    set printer to
    set printer off


******************************************************************************
function printexe()
    set printer to exe
    set printer on
    ?? exename()
    set printer to
    set printer off


******************************************************************************
function selfil(fname:="")
local fs, selected_file
    fs:=gtkfileselectionNew("File selection")
    //fs:liststruct
    //fs:show_fileop_buttons()
    fs:hide_fileop_buttons()
    fs:get_ok_button:signal_connect("clicked",{||selected_file:=fs:get_filename,fs:destroy})
    fs:get_cancel_button:signal_connect("clicked",{||fs:destroy})
    fs:set_filename(fname)
    fs:set_select_multiple(.f.)
    fs:set_position(GTK_WIN_POS_MOUSE)
    fs:run
    return selected_file


******************************************************************************
function gtkbuttonNew_with_mnemonic_from_stock(label_text,stock_id)
local button,box,label,image
    box:=gtkhboxNew(.f.,0)
    box:set_border_width(2)
    image:=gtkimageNew_from_stock(stock_id,1)
    label:=gtklabelNew(label_text)
    label:set_use_underline(.t.)
    box:pack_start(image, .f., .f., 3)
    box:pack_start(label, .f., .f., 3)
    button:=gtkbuttonNew()
    button:add(box)
    return button


******************************************************************************
class gtktwostateimagelabel(gtkhbox)
    method initialize
    attrib state
    attrib image
    attrib label
    attrib active_state_text
    attrib passive_state_text
    method set_state


static function gtktwostateimagelabel.initialize(this,state,text1,text2)
    this:gobject:=gtk.hbox.new(.f.,0)
    this:state:=state!=.f.
    this:active_state_text:=text1
    this:passive_state_text:=text2
    this:set_state(this:state)
    return this


static function gtktwostateimagelabel.set_state(this, state)

    this:state:=state

    if( this:image!=NIL )
        this:remove(this:image)
        this:image:=NIL
    end
    if( this:label!=NIL )
        this:remove(this:label)
        this:label:=NIL
    end

    if( state )
        this:label:=gtklabelNew(this:active_state_text)
        this:image:=gtkimageNew_from_stock("gtk-yes",1)
    else
        this:label:=gtklabelNew(this:passive_state_text)
        this:image:=gtkimageNew_from_stock("gtk-no",1)
    end

    this:pack_start(this:image, .f., .f., 3)
    this:pack_start(this:label, .f., .f., 3)
    this:image:show
    this:label:show
    gtk.main_stabilize()


******************************************************************************
