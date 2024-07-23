
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
#include "gdkkey.ch"
#include "gtk.ch"

#include "amoeba.ch"
#include "pvalue.h"

static hbox_best
static hbox_move
static hbox_turn
static hbox_rate

static area
static thinklabel

static semaphor_busy:=.f.

static bestnavig:=.f.
static beststack:={}
static bestline:=NIL
static bestvalue:=NIL
static bestturn:=NIL
static besttop:=NIL


******************************************************************************
function amoeba_gui(amoebafile)

local window
local wcolor
local vboxwin
local hbox_head
local hbox_body, vboxlef,vboxrig
local hbox_foot, vbox_move,vbox_turn,vbox_rate

local button_move
local button_back
local button_forw
local button_demo, label_demo
local button_check
local button_recalc
local combo
local button_new
local button_load
local button_save

local mask

    gtk.init()

    window:=gtkwindowNew()
    window:set_title(VERSION)
    window:set_icon(amoeba_pixbuf())
    window:signal_connect("destroy",{||quit()})
    window:signal_connect("key-press-event",{|*|cb_key_press(*)})
    window:signal_connect("key-release-event",{|*|cb_key_release(*)})
    window:set_border_width(24)
    window:set_resizable(.f.)
    window:set_position(1)
    wcolor:=gdk.color.new()
#ifndef DEBUG
    gdk.color.parse("#b8b8b8",wcolor)
    window:modify_bg(GTK_STATE_NORMAL,wcolor)
#endif

    vboxwin:=gtkvboxNew()
    window:add(vboxwin)
    hbox_head:=hbox(vboxwin)    // head : bestline
    hbox_body:=hbox(vboxwin)    // body : area buttons
    hbox_foot:=hbox(vboxwin)    // foot : move turn rate 

    // head

    hbox_head:set_size_request(-1,56)
    hbox_head:pack_start(gtklabelNew(" Best line: "),.f.)
    hbox_best:=hbox(hbox_head)


    // body

    vboxlef:=vbox(hbox_body)
    vboxrig:=vbox(hbox_body,,,5)

    // body-left

    drawingarea(area:=gtkdrawingareaNew())
    vboxlef:pack_start(area,.f.)
    area:set_size_request(CELLSIZE*(TABLESIZE+1)+10,CELLSIZE*(TABLESIZE+1)+10)
    area:signal_connect("expose_event",{|*|cb_expose(*)})
    area:signal_connect("button_press_event",{|*|cb_button_press(*)})
    area:signal_connect("button_release_event",{|*|cb_button_release(*)})
    area:signal_connect("motion_notify_event",{|*|cb_motion_notify(*)})
    mask:=area:get_events
    mask:=numor(mask,GDK_BUTTON_PRESS_MASK)
    mask:=numor(mask,GDK_BUTTON_RELEASE_MASK)
    mask:=numor(mask,GDK_POINTER_MOTION_MASK)
    area:set_events(mask)

    // body-right

    hbox(vboxrig,.t.,.t.) // expand, fill
    vboxrig:pack_start( thinklabel:=gtktwostateimagelabelNew(.t.,"Ready","Think"),.f.,,10)
    vboxrig:pack_start( button_move:=gtkbuttonNew_with_mnemonic_from_stock("_Move","gtk-execute"),.f.,,3)
    vboxrig:pack_start( button_back:=gtkbuttonNew_with_mnemonic_from_stock("_Back","gtk-go-back"),.f.,,3)
    vboxrig:pack_start( button_forw:=gtkbuttonNew_with_mnemonic_from_stock("_Forward","gtk-go-forward"),.f.,,3)
    vboxrig:pack_start( button_demo:=gtkbuttonNew_with_mnemonic_from_stock("_Demo","gtk-execute",@label_demo),.f.,,3)
    vboxrig:pack_start( button_check:=gtkcheckbuttonNew_with_mnemonic("_Info"),.f.,,10 )
    vboxrig:pack_start( button_recalc:=gtkbuttonNew_with_mnemonic_from_stock("_Recalc","gtk-execute"),.f.,,3)
    vboxrig:pack_start( combo:=gtkcomboboxNew_text(),.f.,,3)

    vboxrig:pack_start( gtkhboxNew(.f.,0),.f.,,10)

    vboxrig:pack_start( button_new:=gtkbuttonNew_with_mnemonic_from_stock("_New","gtk-new"),.f.,,3)
    vboxrig:pack_start( button_load:=gtkbuttonNew_with_mnemonic_from_stock("_Load","gtk-open"),.f.,,3)
    vboxrig:pack_start( button_save:=gtkbuttonNew_with_mnemonic_from_stock("_Save","gtk-save"),.f.,,3)
    hbox(vboxrig,.t.,.t.) // expand, fill
    hbox(vboxrig,.t.,.t.) // expand, fill


    button_move:signal_connect("clicked",{|*|cb_move(*)})
    button_back:signal_connect("clicked",{|*|cb_back(*)})
    button_forw:signal_connect("clicked",{|*|cb_forward(*)})
    button_demo:signal_connect("clicked",{||cb_demo(button_demo,label_demo)})
    button_recalc:signal_connect("clicked",{|*|cb_recalc(*)})

    button_check:signal_connect("clicked",{|*|cb_info(*)})
    button_check:set_active(.t.)

    combo:signal_connect("changed",{|*|cb_power(*)})
    combo:set_size_request(CELLSIZE*3,-1) // az osszes (!) button szelessege
    combo:append_text(POW0)
    combo:append_text(POW1)
    combo:append_text(POW2)
    combo:append_text(POW3)
    combo:append_text(POW4)
    combo:append_text(POW5)
    combo:append_text(POW6)
    combo:append_text(POW7)
    combo:append_text(POW8)
    combo:set_active(opt_power())

    button_new:signal_connect("clicked",{|*|cb_new(*)})
    button_load:signal_connect("clicked",{|*|cb_load(*)})
    button_save:signal_connect("clicked",{|*|cb_save(*)})


    // foot

    hbox_foot:set_size_request(-1,64)

    vbox_move:=vbox(hbox_foot,.f.) // do not expand horizontally
    vbox_turn:=vbox(hbox_foot,.f.) // do not expand horizontally
    vbox_rate:=vbox(hbox_foot)     // expand horizontally

    hbox_move:=hbox(vbox_move)
    hbox_move:set_size_request(CELLSIZE*TABLESIZE*0.4,-1)
    hbox_move:pack_start( gtkLabelNew(" Last move: "),.f. ) // no expand

    hbox_turn:=hbox(vbox_turn)
    hbox_turn:set_size_request(CELLSIZE*TABLESIZE*0.3,-1)
    hbox_turn:pack_start( gtkLabelNew(" Turn: "),.f. ) // no expand

    hbox_rate:=hbox(vbox_rate)
    hbox_rate:set_size_request(-1,-1)
    hbox_rate:pack_start( gtkLabelNew(" Rate: "),.f. ) // no expand

    label_bestline()
    label_move()
    label_turn()
    label_rate()


    // start

    mainwindow(window)
    window:show_all
    
    if( !empty(amoebafile) )
        loadfile(amoebafile)
    elseif( !empty(getenv("AMOEBA_PORT")) )
        install_cb_timeout()
    end

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
static function cb_key_press(window,keyevent)

local keyval:=gdk.event_key.get_keyval(keyevent)
local xb,xp

    //? "CB_KEY_PRESS",{*},keyval::l2hex
    if( semaphor_busy )
        return NIL
    end
   
    if( !bestnavig )
        // navigáció a teljes játszmában
    
        if( keyval==GDK_KEY_Escape )
            quit()
        elseif( keyval==GDK_KEY_Left )
            cb_back()
        elseif( keyval==GDK_KEY_Right )
            cb_forward()
        elseif( keyval==GDK_KEY_Home )
            cb_home()
        elseif( keyval==GDK_KEY_End )
            cb_end()
    
        elseif( keyval==GDK_KEY_Shift_L .or. keyval==GDK_KEY_Shift_R )
            bestnavig:=.t.
            if( !empty(bestline:=bestline_array()[..]) )
                cell_save()
                bestvalue:=recalc_value()|rating_value()
                bestturn:=if(turn_x(),1,0)
                besttop:=topcell()
                xb:=back()
                drawcell(xb)
                circle_normal(movecount())
                forw(bestline[1])
                drawtop()
                beststack::apush(bestline[1])
                label_bestline( bestline_format(bestline,bestvalue,bestturn,1) )
                stabilize()
            end
        end
    else
        // navigació a bestline-ban
        if( keyval==GDK_KEY_Right )
            cb_bestright()
        elseif( keyval==GDK_KEY_Left )
            cb_bestleft()
        end
    end


******************************************************************************
static function cb_bestright()
    if( len(beststack)+1<=len(bestline) )
        drawcell(topcell())
        if( !forw(bestline[len(beststack)+1]) )
            //break("bestline push error") // ez hogy
            ? "bestline push error"
            drawtop()
            return NIL
        end
        drawtop()
        beststack::apush( bestline[len(beststack)+1] )
        label_bestline( bestline_format(bestline,bestvalue,bestturn,len(beststack)) )
        stabilize()
    end


******************************************************************************
static function  cb_bestleft()
local xb,xp
    if( len(beststack)>1 )
        xb:=back()
        xp:=apop(beststack)
        if( xb!=xp )
            break("bestline pop error")
        end
        drawcell(xb)
        drawtop()
        label_bestline( bestline_format(bestline,bestvalue,bestturn,len(beststack)) )
        stabilize()
    end


******************************************************************************
static function cb_key_release(window,keyevent)
local keyval:=gdk.event_key.get_keyval(keyevent)
local xp,xb

    //? "CB_KEY_RELEASE",{*},keyval::l2hex
    if( semaphor_busy )
        return NIL
    end

    if( keyval==GDK_KEY_Shift_L .or. keyval==GDK_KEY_Shift_R )
        bestnavig:=.f.
        if( !empty(bestline) )
            circle_normal(-1)
            while( len(beststack)>0  )
                xb:=back()
                xp:=apop(beststack)
                if( xp!=xb )
                    break( "bestline pop all error" )
                end
                drawcell(xb)
            end
            forw(besttop)
            drawtop()
            label_bestline( bestline_format(bestline,bestvalue,bestturn,NIL) )
            bestline:=NIL
            bestvalue:=NIL
            bestturn:=NIL
            besttop:=NIL
            stabilize()
            cell_restore()
        end
    end


******************************************************************************
static function cb_button_press(area,event)
local x,y,but,cx,fm,n

    if(gtk.main_depth()>1)
        return NIL
    end
    if( bestnavig )
        return NIL
    end
    if( semaphor_busy )
        return NIL
    end

    if( validpos(event,@x,@y,@but) )
        cx:=y*TABLESIZE+x

        if( but==1 )
            //left-button

            if( !game_over() )
                forw(cx)
                markmovecount()
                rating_store() //delete
                recalc_store() //delete
                drawtop()
                stabilize()
                label_move()
                label_turn()
                label_rate()
                bestline_store({})
                if( winner()==32 )
                    cb_move()
                else
                    game_over() //?
                end
            end

        elseif( but==3 .and. infolevel()>0 )
            //right-button
            print_table()
            if( winner()==32 )
                fm:=movegen(9)
                ? "###"
                ?
                for n:=1 to len(fm)
                    drawnum(fm[n],n)
                    print_pattern(fm[n])
                    ?
                next
                print_pattern(cx)
                ?
                print_posvalue()
            end
        end
    end


******************************************************************************
static function cb_button_release(area,event)


******************************************************************************
static function cb_move(button)
local cp

    if(gtk.main_depth()>1)
        return NIL
    end
    if( bestnavig )
        return NIL
    end
    if( semaphor_busy )
        return NIL
    end
    semaphor_busy:=.t.

    cp:=(0<=continuous_play() .or. button!=NIL)
    while( cp .and. !game_over() )

        if( movecount()==0 )
            cell_randomize()
        elseif( movecount()==1 )
            cell_randomize(topcell())
        end

        thinklabel:set_state(.f.)
        area:set_sensitive(.f.)
        go_move()
        area:set_sensitive(.t.)
        thinklabel:set_state(.t.)
        markmovecount()
        label_move()
        label_turn()
        if( game_over() )
            exit
        end
        cp:=(0<continuous_play())
    end
    semaphor_busy:=.f.


******************************************************************************
static function cb_demo(button,label)

static demo:=.f.

    if( bestnavig )
        return NIL
    end

    if( game_over() )
        return NIL
    end

    demo:=!demo
    if( demo )
        label:set_text("_Stop")
        label:set_use_underline(.t.)
    end

    while( demo .and. !game_over() )
        if( movecount()==0 )
            cell_randomize()
        elseif( movecount()==1 )
            cell_randomize(topcell())
        end

        thinklabel:set_state(.f.)
        area:set_sensitive(.f.)
        go_move()
        area:set_sensitive(.t.)
        thinklabel:set_state(.t.)
        markmovecount()
        label_move()
        label_turn()

        //print_map();??cache_search()[1];?
    end

    demo:=.f.    
    label:set_text("_Demo")
    label:set_use_underline(.t.)


******************************************************************************
static function cb_end()
    if( semaphor_busy )
        return NIL
    end
    while( c_cb_forward() )
    end
    drawtop()
    stabilize()
    label_move()
    label_turn()
    label_rate()
    label_bestline()


******************************************************************************
static function cb_home()
    if( semaphor_busy )
        return NIL
    end
    while( back()!=NIL )
    end
    stabilize()
    label_move()
    label_turn()
    label_rate()
    label_bestline()


******************************************************************************
static function cb_back()
local cx:=topcell()
    if(gtk.main_depth()>1)
        return NIL
    end
    if( semaphor_busy )
        return NIL
    end
    if( bestnavig )
        cb_bestleft()
        return NIL
    end

    if( cx!=NIL )
        c_cb_back()
        drawtop()
        stabilize()
    end
    label_move()
    label_turn()
    label_rate()
    label_bestline()


******************************************************************************
static function cb_forward()
local cx:=topcell()
    if(gtk.main_depth()>1)
        return NIL
    end
    if( semaphor_busy )
        return NIL
    end
    if( bestnavig )
        cb_bestright()
        return NIL
    end

    c_cb_forward()
    drawtop()
    stabilize()
    label_move()
    label_turn()
    label_rate()
    label_bestline()

    //print_table()
    //print_map()
    //??cache_search()[1];?

******************************************************************************
static function cb_recalc()
    if(gtk.main_depth()>1)
        return NIL
    end
    if( bestnavig )
        return NIL
    end
    if( semaphor_busy )
        return NIL
    end
    semaphor_busy:=.t.

    thinklabel:set_state(.f.)
    area:set_sensitive(.f.)
    go_recalc()
    area:set_sensitive(.t.)
    thinklabel:set_state(.t.)

    semaphor_busy:=.f.


******************************************************************************
static function cb_new(button)
    //? "CB_NEW",{*}
    if(gtk.main_depth()>1)
        return NIL
    end
    if( bestnavig )
        return NIL
    end

    c_cb_new()
    stabilize()
    drawmeter(0)
    label_bestline()
    label_move()
    label_turn()
    label_rate()


******************************************************************************
static function cb_info(check)
    //? "CB_INFO",{*}
    //engedni kell a rekurziót

    infolevel(check:get_active)
    if( check:get_active )
        hbox_best:show_all
    else
        hbox_best:hide
    end


******************************************************************************
static function cb_power(combo)
    //? "CB_POWER",{*}
    setpower(combo:get_active_text)


******************************************************************************
static function cb_motion_notify(area,event)


******************************************************************************
function area()
    return area


******************************************************************************
function thinklabel()
    return thinklabel


******************************************************************************
function label_bestline(x)
static label
local v
    if( label==NIL )
        label:=gtklabelNew()
        hbox_best:pack_start(label,.f.)
    end
    if( x==NIL )
        if( !empty(v:=recalc_string()) )
            v::=val
        elseif( !empty(v:=rating_string()) )
            v::=val
        else
            v:=0
        end
        if( !empty(x:=bestline_array())  )
            x:=bestline_format(x,v,if(turn_x(),1,0))
        else
            x:=""
        end
    end
    if( CELLSIZE<40 )
        label:set_markup("<small>"+x+"</small>")
    else
        label:set_markup(x)
    end


******************************************************************************
function label_move()
static label
local m:=movecount()
local x:=topcell()

    if( label==NIL )
        label:=gtklabelNew()
        hbox_move:pack_start(label,.f.)
    end
    if( x!=NIL )
        x:=pos2rc(x)
        label:set_markup( " <b>"+m::str::alltrim+":"+x+"</b>" )
    else
        label:set_markup( "" )
    end


******************************************************************************
function label_turn()

static image
static black
static white

local mc:=movecount()

    if( image!=NIL )
        hbox_turn:remove(image) // destroy object
    else    
        black:=circle_image(CELLSIZE*0.8,0,0,0,0xb8/256,0xb8/256,0xb8/256)
        white:=circle_image(CELLSIZE*0.8,1,1,1,0xb8/256,0xb8/256,0xb8/256)
    end

    if( (mc%2)==0 )
        image:=black
    else
        image:=white
    end
    hbox_turn:pack_start(image,.f.)
    hbox_turn:show_all


******************************************************************************
function label_rate()

static label
local rating:=rating_string()
local recalc:=recalc_string()

    if( label==NIL )
        label:=gtklabelNew()
        hbox_rate:pack_start(label,.f.) 
    end

    if( !empty(recalc) )
        if( abs(val(recalc))>PVALUE_INFIN-100 )
            recalc:="<span color='red'>"+recalc+"</span>"
        else
            recalc:="<span color='green'>"+recalc+"</span>"
        end
        recalc:="<span color='#b8b8b8'>!</span>"+recalc // invisible !
    end
    label:set_markup( " <b>"+rating+recalc+"</b>" )


******************************************************************************

