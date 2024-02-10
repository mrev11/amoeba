
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


static hbox_bestline
static label_bestline

static area
static twostatelabel
static label_move
static label_turn
static label_rate
static power:=0


******************************************************************************
function amoeba_gui(amoebafile)

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
local hboxsep1
local button_move
local button_back
local button_forw
local hboxsep2
local button_check
local button_recalc
local combo
local hboxsep3
local button_new
local button_load
local button_save
local hboxfill

local lab


    gtk.init()

    window:=gtkwindowNew()
    window:set_title(VERSION)
    //window:set_icon_from_file("amoeba.png")
    window:set_icon(amoeba_pixbuf())
    window:signal_connect("destroy",{||quit()})
    window:set_border_width(16)
    window:set_resizable(.f.)
    window:set_position(1)
    wcolor:=gdk.color.new()
    gdk.color.parse("#b8b8b8",wcolor)
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

    vboxlef:pack_start(hbox_bestline:=gtkhboxNew())
    hbox_bestline:pack_start( lab:=gtklabelNew(),.f. ); lab:set_size_request(CELLSIZE,-1)
    hbox_bestline:pack_start( lab:=gtklabelNew(),.f. ); lab:set_text("Best line: "); lab:set_use_markup(.t.)
    hbox_bestline:pack_start( lab:=gtklabelNew(),.f. ); label_bestline:=lab
    hbox_bestline:pack_start( lab:=gtklabelNew(),.t. )  // expand

    vboxlef:pack_start( drawingarea(area:=gtkdrawingareaNew()) )
    vboxlef:pack_start( hboxsep:=gtkhboxNew(.f.,0) )
    vboxlef:pack_start( hboxlab:=gtkhboxNew(.f.,0) )

    hboxlab:pack_start( label_move:=gtklabelNew() )
    //hboxlab:pack_start( label_turn:=gtklabelNew() )
    hboxlab:pack_start( label_turn:=gtkhboxNew() )
    hboxlab:pack_start( label_rate:=gtklabelNew() )


    area:set_size_request(CELLSIZE*(TABLESIZE+1)+1,CELLSIZE*(TABLESIZE+1)+1)
    area:signal_connect("expose_event",{|w,e|cb_expose(w,e)})
    area:signal_connect("button_press_event",{|w,e|cb_button_press(w,e)})
    area:signal_connect("button_release_event",{|w,e|cb_button_release(w,e)})
    area:signal_connect("motion_notify_event",{|w,e|cb_motion_notify(w,e)})
    mask:=area:get_events
    mask:=numor(mask,GDK_BUTTON_PRESS_MASK)
    mask:=numor(mask,GDK_BUTTON_RELEASE_MASK)
    mask:=numor(mask,GDK_POINTER_MOTION_MASK)
    area:set_events(mask)

    hboxsep:set_size_request(0,10)

    label_move:set_size_request(CELLSIZE*(TABLESIZE-3)/2,-1)
    label_turn:set_size_request(CELLSIZE*2,-1)
    label_rate:set_size_request(CELLSIZE*(TABLESIZE-3)/2,-1)

    label_move()
    label_rate()

    //=============================
    // vboxrig
    //=============================

    vboxrig:pack_start( hboxsep0:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( twostatelabel:=gtktwostateimagelabelNew(.t.,"Ready","Think") )
    vboxrig:pack_start( hboxsep1:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_move:=gtkbuttonNew_with_mnemonic_from_stock("_Move","gtk-execute") )
    vboxrig:pack_start( button_back:=gtkbuttonNew_with_mnemonic_from_stock("_Back","gtk-go-back"))
    vboxrig:pack_start( button_forw:=gtkbuttonNew_with_mnemonic_from_stock("_Forward","gtk-go-forward"))
    vboxrig:pack_start( hboxsep2:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_check:=gtkcheckbuttonNew_with_mnemonic("_Info") )
    vboxrig:pack_start( button_recalc:=gtkbuttonNew_with_mnemonic_from_stock("_Recalc","gtk-execute") )
    vboxrig:pack_start( combo:=gtkcomboboxNew_text() )
    vboxrig:pack_start( hboxsep3:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_new:=gtkbuttonNew_with_mnemonic_from_stock("_New","gtk-new"))
    vboxrig:pack_start( button_load:=gtkbuttonNew_with_mnemonic_from_stock("_Load","gtk-open"))
    vboxrig:pack_start( button_save:=gtkbuttonNew_with_mnemonic_from_stock("_Save","gtk-save"))
    vboxrig:pack_start( hboxfill:=gtkhboxNew(.f.,0))

    button_move:signal_connect("clicked",{|w|cb_move(w)})
    button_back:signal_connect("clicked",{|w|cb_back(w)})
    button_forw:signal_connect("clicked",{|w|cb_forward(w)})
    button_recalc:signal_connect("clicked",{|w|cb_recalc(w)})

    button_check:signal_connect("clicked",{|w|cb_info(w)})
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
    combo:set_active(power)

    button_new:signal_connect("clicked",{|w|cb_new(w,combo)})
    button_load:signal_connect("clicked",{||cb_load(window)})
    button_save:signal_connect("clicked",{||cb_save(window)})

    hboxsep0:set_size_request(-1,40)
    hboxsep1:set_size_request(-1,10)
    hboxsep2:set_size_request(-1,10)
    hboxsep3:set_size_request(-1,10)
    hboxfill:set_size_request(-1,100)

    mainwindow(window)
    window:show_all
    loadfile(amoebafile)
    ?
    gtk.main()
    ?


******************************************************************************
function cb_expose(area,event)

    // tapasztalat szerint
    // gtk.main_stabilize()-ból
    // meghívódik cb_expose()
    // (akkor ez itt rekurzív?)

    drawall()


******************************************************************************
static function cb_button_press(area,event)
local x,y,but,cx,fm,n
    if(gtk.main_depth()>1);return NIL;end

    if( validpos(event,@x,@y,@but) )

        if( but==1 )
            //left-button

            if( !game_over() )
                if( topcell()!=NIL )
                    drawcell(topcell()) // -> normal shape
                end
                cx:=y*TABLESIZE+x
                forw(cx)
                drawtop()
                label_move()
                label_turn()
                rating_store() //delete
                label_rate()
                markmovecount()
                if( winner()==32 )
                    cb_move()
                end
            end

        elseif( but==3 .and. infolevel()>0 )
            //right-button
            if( winner()==32 )
                fm:=movegen(9)
                ? "###"
                ?
                for n:=1 to len(fm)
                    drawnum(fm[n],n)
                    c_cb_button_press_stat(fm[n])
                next
                cx:=y*TABLESIZE+x
                c_cb_button_press_stat(cx)
                c_cb_button_press_pos()
                drawclean(.t.)
            end
        end
    end


******************************************************************************
static function cb_button_release(area,event)


******************************************************************************
static function cb_move()
local cp:=.t.
    if(gtk.main_depth()>1);return NIL;end
    while( cp .and. !game_over() )

        if( movecount()==0 )
            cell_randomize()
        elseif( movecount()==1 )
            cell_randomize(topcell())
        end

        twostatelabel:set_state(.f.)
        area:set_sensitive(.f.)
        go_move()
        area:set_sensitive(.t.)
        twostatelabel:set_state(.t.)
        markmovecount()
        label_move()

        cp:=!empty(continuous_play())
    end


******************************************************************************
static function cb_back(w)
local cx:=topcell()
    if(gtk.main_depth()>1);return NIL;end
    drawclean()
    if( cx!=NIL )
        c_cb_back()
        drawcell(cx)
        drawtop()
    end
    label_move()
    label_rate()


******************************************************************************
static function cb_forward(w)
local cx:=topcell()
    if(gtk.main_depth()>1);return NIL;end
    drawclean()
    c_cb_forward()
    if( cx!=NIL )
        drawcell(cx)
    end
    drawtop()
    label_move()
    label_rate()


******************************************************************************
static function cb_recalc()
    drawclean()
    twostatelabel:set_state(.f.)
    area:set_sensitive(.f.)
    go_recalc()
    area:set_sensitive(.t.)
    twostatelabel:set_state(.t.)


******************************************************************************
static function cb_new(w,combo)
    //? "cb_new", gtk.main_depth()
    if(gtk.main_depth()>1);return NIL;end
    //combo:set_active(0)
    c_cb_new()
    drawall(.t.) // törli topcell/topfig-et
    label_bestline("")
    label_move()
    label_rate()


******************************************************************************
static function cb_info(w)
    //? "cb_info", gtk.main_depth()
    //if(gtk.main_depth()>1);return NIL;end
    //engedni kell a rekurziót
    infolevel(w:get_active)
    if( w:get_active )
        label_bestline:show
    else
        label_bestline:hide
    end


******************************************************************************
static function cb_power(w)
    setpower(w:get_active_text)


******************************************************************************
static function cb_motion_notify(area,event)


******************************************************************************
function label_bestline(x)
    if( CELLSIZE>=40 )
        label_bestline:set_markup("<b>"+x+"</b>")
    else
        label_bestline:set_markup(x)
    end


******************************************************************************
function label_move()
local m:=movecount()
local x:=topcell()
    if( x!=NIL )
        x:=pos2rc(x)
        label_move:set_markup( "Last move: <b>"+m::str::alltrim+":"+x+"</b>" )
    else
        label_move:set_markup( "Last move: <b>"+m::str::alltrim+"</b>" )
    end
    label_turn()


******************************************************************************
function label_turn()

static label
static image
static black
static white

local mc:=movecount()

    if( label==NIL )
        label:=gtklabelNew("Turn:")
        label_turn:pack_start(label)

        //black:=gtk.image.new_from_file("black.png")
        //white:=gtk.image.new_from_file("white.png")
        //gtk.gobject.ref(black) // increase ref number
        //gtk.gobject.ref(white) // increase ref number

        black:=circle_image(CELLSIZE,0,0,0,0xb8/256,0xb8/256,0xb8/256)
        white:=circle_image(CELLSIZE,1,1,1,0xb8/256,0xb8/256,0xb8/256)
    end

    if( image!=NIL )
        label_turn:remove(image) // destroy object
    end
    if( (mc%2)==0 )
        image:=black
    else
        image:=white
    end
    label_turn:pack_end(image)
    label_turn:show_all


******************************************************************************
function label_rate()
local rating:=rating_string()
local recalc:=recalc_string(),r
    if( !empty(recalc) )
        r:=recalc_load()[1]
        if( abs(r)>PVALUE_INFIN-100 )
            recalc:="<span color='red'>"+recalc+"</span>"
        else
            recalc:="<span color='green'>"+recalc+"</span>"
        end
        recalc:="<span color='#b8b8b8'>!</span>"+recalc // invisible !
    end
    label_rate:set_markup( "Rating: <b>"+rating+recalc+"</b>" )


******************************************************************************

