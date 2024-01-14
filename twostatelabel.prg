
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

static image_red   := circle_image(CELLSIZE*0.6, 0.7, 0  , 0, 3/4,3/4,3/4)
static image_green := circle_image(CELLSIZE*0.6, 0  , 0.7, 0, 3/4,3/4,3/4)

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
        this:image:=image_green
    else
        this:label:=gtklabelNew(this:passive_state_text)
        this:image:=image_red
    end

    this:pack_start(this:image, .f., .f., 3)
    this:pack_start(this:label, .f., .f., 3)
    gtk.widget.show_all(this:gobject)
    gtk.main_stabilize()


******************************************************************************
