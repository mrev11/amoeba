
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

