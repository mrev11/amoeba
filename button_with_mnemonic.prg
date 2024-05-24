
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
function gtkbuttonNew_with_mnemonic_from_stock(label_text,stock_id,label)
local button,box,image
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
