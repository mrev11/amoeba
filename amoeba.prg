
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

#define VERSION "Amoeba 1.3.0 for GTK+"

static area
static twostatelabel
static label_move
static label_turn
static label_rate

static EXPOSE:=.f.


*****************************************************************************
function main()
    //printpid()
    //printexe()
    rand(seconds())
    init_cells()
    amoeba_gui()


******************************************************************************
static function amoeba_gui()

local window
local wcolor
local hboxwin
local vboxlef,vboxsep,vboxrig

// vboxlef
local mask
local hboxsep
local hboxlab

// vboxrig
local hboxsep0
local button_move
local button_back
local button_forw
local hboxsep1
local button_check
local combo
local hboxsep2
local button_new
local button_load
local button_save
local hboxfill

    gtk.init()

    window:=gtkwindowNew()
    window:set_title(VERSION)
    window:signal_connect("destroy",{||quit()})
    window:set_border_width(16)
    window:set_resizable(.f.)
    window:set_position(1)
    wcolor:=gdk.color.new()
    gdk.color.parse("#c0c0c0",wcolor)
    window:modify_bg(GTK_STATE_NORMAL,wcolor)

    hboxwin:=gtkhboxNew(.f.,0)
    window:add(hboxwin)
    hboxwin:pack_start( vboxlef:=gtkvboxNew(.f.,0) )
    hboxwin:pack_start( vboxsep:=gtkvboxNew(.f.,0) )
    hboxwin:pack_start( vboxrig:=gtkvboxNew(.f.,0) )

    vboxsep:set_size_request(10,-1)


    //=============================
    // vboxlef
    //=============================

    vboxlef:pack_start( area:=gtkdrawingareaNew() )
    vboxlef:pack_start( hboxsep:=gtkhboxNew(.f.,0) )
    vboxlef:pack_start( hboxlab:=gtkhboxNew(.f.,0) )

    hboxlab:pack_start( label_move:=gtklabelNew() )
    hboxlab:pack_start( label_turn:=gtklabelNew() )
    hboxlab:pack_start( label_rate:=gtklabelNew() )


    area:set_size_request(CELLSIZE*TABLESIZE+1,CELLSIZE*TABLESIZE+1)
    area:signal_connect("expose_event",{|w,e|cb_expose(w,e)})
    area:signal_connect("button_press_event",{|w,e|cb_button_press(w,e)})
    area:signal_connect("button_release_event",{|w,e|cb_button_release(w,e)})
  //area:signal_connect("motion_notify_event",{|w,e|cb_motion_notify(w,e)})
    mask:=area:get_events
    mask:=numor(mask,GDK_BUTTON_PRESS_MASK)
    mask:=numor(mask,GDK_BUTTON_RELEASE_MASK)
    mask:=numor(mask,GDK_POINTER_MOTION_MASK)
    area:set_events(mask)

    hboxsep:set_size_request(0,10)

    label_move:set_size_request(150,-1)
    label_turn:set_size_request(150,-1)
    label_rate:set_size_request(150,-1)

    label_move:set_alignment(0.2,0.5) //balra
    label_turn:set_alignment(0.2,0.5) //balra
    label_rate:set_alignment(0.2,0.5) //balra
    label_move()
    label_rate(0)

    //=============================
    // vboxrig
    //=============================

    vboxrig:pack_start( twostatelabel:=gtktwostateimagelabelNew(.t.,"Ready","Thinking") )
    vboxrig:pack_start( hboxsep0:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_move:=gtkbuttonNew_with_mnemonic_from_stock("_Move","gtk-execute") )
    vboxrig:pack_start( button_back:=gtkbuttonNew_with_mnemonic_from_stock("_Back","gtk-go-back"))
    vboxrig:pack_start( button_forw:=gtkbuttonNew_with_mnemonic_from_stock("_Forward","gtk-go-forward"))
    vboxrig:pack_start( hboxsep1:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_check:=gtkcheckbuttonNew_with_mnemonic("_Teach") )
    vboxrig:pack_start( combo:=gtkcomboboxNew_text() )
    vboxrig:pack_start( hboxsep2:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_new:=gtkbuttonNew_with_mnemonic_from_stock("_New","gtk-new"))
    vboxrig:pack_start( button_load:=gtkbuttonNew_with_mnemonic_from_stock("_Load","gtk-open"))
    vboxrig:pack_start( button_save:=gtkbuttonNew_with_mnemonic_from_stock("_Save","gtk-save"))
    vboxrig:pack_start( hboxfill:=gtkhboxNew(.f.,0))



    button_move:signal_connect("clicked",{|w|cb_move(w)})
    button_back:signal_connect("clicked",{|w|cb_back(w)})
    button_forw:signal_connect("clicked",{|w|cb_forward(w)})

    button_check:signal_connect("clicked",{|w|cb_teach(w)})
    button_check:set_active(.t.)

    combo:signal_connect("changed",{|w|cb_power(w)})
    combo:set_size_request(100,-1)
    combo:append_text(POW0)
    combo:append_text(POW1)
    combo:append_text(POW2)
    combo:append_text(POW3)
    combo:append_text(POW4)
    combo:append_text(POW5)
    combo:append_text(POW6)
    combo:append_text(POW7)
    combo:append_text(POW8)
    combo:set_active(0)

    button_new:signal_connect("clicked",{|w|cb_new(w,combo)})
    button_load:signal_connect("clicked",{||cb_load(window)})
    button_save:signal_connect("clicked",{||cb_save(window)})

    hboxsep0:set_size_request(-1,10)
    hboxsep1:set_size_request(-1,10)
    hboxsep2:set_size_request(-1,10)
    hboxfill:set_size_request(-1,100)

    window:show_all
    gtk.main()
    ?


******************************************************************************
static function cb_button_release(area,event)
//local n
//    for n:=0 to ROWCOL-1
//        draw(n)
//    next


******************************************************************************
static function cb_button_press(area,event)
local x,y,but,cx,fm,n
    if(gtk.main_depth()>1);return NIL;end
    if( validpos(event,@x,@y,@but) )
        if( but==1 )
            //left-button
            cx:=y*TABLESIZE+x
            forw(cx)
            cb_move()
        elseif( teach() )
            //right-button
            ? "*";?
            drawall()
            fm:=movegen(5)
            for n:=1 to len(fm)
                draw(fm[n],,n)
                c_cb_button_press_stat(fm[n])
            next
            cx:=y*TABLESIZE+x
            c_cb_button_press_stat(cx)
            pos_stat()
        end
    end


******************************************************************************
static function cb_move()
    if(gtk.main_depth()>1);return NIL;end
    game_over()
    twostatelabel:set_state(.f.)
    area:set_sensitive(.f.)
    go()
    area:set_sensitive(.t.)
    twostatelabel:set_state(.t.)
    setmoveforw()
    label_move()


******************************************************************************
static function cb_back(w)
local cx:=topcell()
    if(gtk.main_depth()>1);return NIL;end
    if( cx!=NIL )
        c_cb_back()
        drawcell(cx)
        drawtop()
    end
    label_move()
    label_rate(0)


******************************************************************************
static function cb_forward(w)
local cx:=topcell()
    if(gtk.main_depth()>1);return NIL;end
    c_cb_forward()
    if( cx!=NIL )
        drawcell(cx)
    end
    drawtop()
    label_move()


******************************************************************************
static function cb_new(w,combo)
    //? "cb_new", gtk.main_depth()
    if(gtk.main_depth()>1);return NIL;end
    combo:set_active(0)
    c_cb_new()
    drawall()
    label_move()
    label_rate(0)


******************************************************************************
static function cb_load(window)
local dlg, selected_file,cells,n

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

    if( selected_file!=NIL .and. !empty(cells:=memoread(selected_file)) )
        if( cells::left(7)!="amoeba{" .or. cells::right(1)!="}" )
            // nem amoeba fajl
        else
            cells:=cells[8..cells::len-1]::split
            for n:=1 to len(cells)
                cells[n]::=val
            next
            c_cb_new(cells)
            drawall()
            label_rate(0)
        end
    end


******************************************************************************
static function cb_save(window)
local dlg,selected_file
local index:=0,cellid,cells:={},name

    if(gtk.main_depth()>1);return NIL;end

    while( NIL!=(cellid:=cell(index++)) )
        aadd(cells,cellid)
    end
    cells::=any2str
    cells:="amoeba"+cells
    name:="amoeba-"+cells::str2bin::crc32::l2hex::padl(8,"0")

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
        memowrit(selected_file,cells)
    end


******************************************************************************
static function cb_teach(w)
    //? "cb_teach", gtk.main_depth()
    //if(gtk.main_depth()>1);return NIL;end
    //engedni kell a rekurziót
    teach(w:get_active)


******************************************************************************
static function cb_power(w)
    //? "cb_power", gtk.main_depth()
    //if(gtk.main_depth()>1);return NIL;end
    //engedni kell a rekurziót
    power(w:get_active_text)


******************************************************************************
static function cb_motion_notify(area,event)
    //? "cb_motion_notify", gtk.main_depth()
    if(gtk.main_depth()>1);return NIL;end


******************************************************************************
function cb_expose(area,event)

    EXPOSE:=.t.

    // ? "EXPOSE", movecount(), topcell(), undercell()
    // 
    // callstack()
    // A GTK a program indulásakor kétszer hívja meg ezt kódot
    // a két esetben pontosan ugyanúgy
    //  - ha csak az elsőre futtatom -> üres marad a négyzetháló 
    //  - ha csak a másodikra futtatom -> üres marad a négyzetháló 
    //
    // később is rendszeresen meghívódik
    // a tapasztalat szerint 
    // - egér klikk után meghívódik
    // - move/back/forward után nem hívódik meg

    drawall()
 
    EXPOSE:=.f.

 
******************************************************************************
function label_move()
local m:=movecount()
    label_move:set_markup( "Move: <b>"+m::str::alltrim+"</b>" )
    label_turn()


******************************************************************************
function label_turn()
local m:=movecount()
    if( (m%2)==0 )
        label_turn:set_markup( "Turn: <span color='black'>"+SHAPE_X()+"</span>" )
    else
        label_turn:set_markup( "Turn: <span color='white'>"+SHAPE_O()+"</span>" )
    end


******************************************************************************
function label_rate(x)
    label_rate:set_markup( "Rating: <b>"+x::int::str::alltrim+"</b>" )


******************************************************************************
static function validpos(event,x,y,but)

local xy:=gdk.event.get_coords(event)

    x:=xy[1]
    y:=xy[2]
    but:=gdk.event_button.get_button(event) //1,2,3 -- bal,köz,jobb

    if( x%CELLSIZE<2 .or. x%CELLSIZE>CELLSIZE-2 )
        return .f.
    elseif( y%CELLSIZE<2 .or. y%CELLSIZE>CELLSIZE-2 )
        return .f.
    end

    x:=int(x/CELLSIZE)
    y:=int(y/CELLSIZE)

    if( x>=TABLESIZE )
        return .f.
    elseif( y>=TABLESIZE )
        return .f.
    elseif( figure(y*TABLESIZE+x)!=32 )
        return .f.
    end

    return  .t.


******************************************************************************
function drawingarea()
    return area


******************************************************************************
    