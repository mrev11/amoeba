
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


static area
static twostatelabel
static label_move
static label_turn
static label_rate
static power:=0
static rating

*****************************************************************************
function main(*)

local args:={*},n
local size
local file
local game

    for n:=1 to len(args)
        if( args[n]=="-t" .and. n<len(args) )
            size:=args[++n]::val

        elseif( args[n]=="-p" .and. n<len(args) )
            power:=args[++n]::val::max(0)::min(8)

        elseif( file(args[n]) )
            file:=args[n]

        else
            usage()
        end
    next

    if( file!=NIL )
        size:=memoread(file)::strtran("amoeba","")::val
    end

    if( size!=NIL )
        tablesize(size)
        cell_classinit()
    end

    rating:=array(ROWCOL+1)
    rating::afill(0)

    amoeba_gui(file)


******************************************************************************
static function usage()
    ?
    ? "Usage: amoeba.exe [-t <tablesize>] [-p <power>] [<amoebafile>]  "
    ?
    ? "defaults:"
    ? "     tablesize  - 16"
    ? "     power      - 0 (=auto)"
    ? "     amoebafile - empty"
    ?
    quit


******************************************************************************
static function amoeba_gui(amoebafile)

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
local button_eval
local combo
local hboxsep3
local button_new
local button_load
local button_save
local hboxfill

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

    label_move:set_size_request(250,-1)
    label_turn:set_size_request(50,-1)
    label_rate:set_size_request(250,-1)

    label_move()
    label_rate(0)

    //=============================
    // vboxrig
    //=============================

    vboxrig:pack_start( hboxsep0:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( twostatelabel:=gtktwostateimagelabelNew(.t.,"Ready","Thinking") )
    vboxrig:pack_start( hboxsep1:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_move:=gtkbuttonNew_with_mnemonic_from_stock("_Move","gtk-execute") )
    vboxrig:pack_start( button_back:=gtkbuttonNew_with_mnemonic_from_stock("_Back","gtk-go-back"))
    vboxrig:pack_start( button_forw:=gtkbuttonNew_with_mnemonic_from_stock("_Forward","gtk-go-forward"))
    vboxrig:pack_start( hboxsep2:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_check:=gtkcheckbuttonNew_with_mnemonic("_Info") )
    vboxrig:pack_start( button_eval:=gtkbuttonNew_with_mnemonic_from_stock("_Eval","gtk-execute") )
    vboxrig:pack_start( combo:=gtkcomboboxNew_text() )
    vboxrig:pack_start( hboxsep3:=gtkhboxNew(.f.,0))
    vboxrig:pack_start( button_new:=gtkbuttonNew_with_mnemonic_from_stock("_New","gtk-new"))
    vboxrig:pack_start( button_load:=gtkbuttonNew_with_mnemonic_from_stock("_Load","gtk-open"))
    vboxrig:pack_start( button_save:=gtkbuttonNew_with_mnemonic_from_stock("_Save","gtk-save"))
    vboxrig:pack_start( hboxfill:=gtkhboxNew(.f.,0))

    button_move:signal_connect("clicked",{|w|cb_move(w)})
    button_back:signal_connect("clicked",{|w|cb_back(w)})
    button_forw:signal_connect("clicked",{|w|cb_forward(w)})
    button_eval:signal_connect("clicked",{|w|cb_eval(w)})

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

            if( movecount()==0 )
                ? "RANDOMIZE",y,x
                cell_randomize(y,x)
            end

            if( !game_over() )
                if( topcell()!=NIL )
                    drawcell(topcell()) // -> normal shape
                end
                cx:=y*TABLESIZE+x
                forw(cx)
                drawtop()
                label_turn()
            end
            if( winner()==32 )
                cb_move()
             end

        //elseif( but==2 )
        //    // middle-button
        //    go_eval()

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
        twostatelabel:set_state(.f.)
        area:set_sensitive(.f.)
        go()
        area:set_sensitive(.t.)
        twostatelabel:set_state(.t.)
        markmovecount()
        label_move()
        cp:=getenv("AMOEBA_CONTINUOUS_PLAY")=="true"
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
static function cb_eval()
    drawclean()
    go_eval()

******************************************************************************
static function cb_new(w,combo)
    //? "cb_new", gtk.main_depth()
    if(gtk.main_depth()>1);return NIL;end
    //combo:set_active(0)
    c_cb_new()
    drawall()
    label_move()
    label_rate(0)


******************************************************************************
static function cb_load(window)
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


static function loadfile(selected_file)
local content
local cells,rates,n
local amoeba:="amoeba"+TABLESIZE::str::alltrim

    if( selected_file==NIL )
        //? "nem választott"
        return NIL
    end   
    
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
    
    if( content::len<3  )
        ? "hibás formátum1"
        return NIL
    end
    
    cells:=content[2]
    rates:=content[3]

    if( cells::left(1)!="{" .or. cells::right(1)!="}" )
        ? "hibás formátum2"
        return NIL
    end
    cells::=substr(2,len(cells)-2)::split
    for n:=1 to len(cells)
         cells[n]::=val
    next

    if( rates::left(1)!="{" .or. rates::right(1)!="}" )
        ? "hibás formátum3"
        return NIL
    end
    rates::=substr(2,len(rates)-2)::split
    for n:=1 to len(rates)
         rates[n]::=val
    next

    for n:=1 to len(rates)
        rating[n]:=rates[n]
    next
    c_cb_new(cells)
    drawall()

    label_move()
    label_turn()
    label_rate()


******************************************************************************
static function cb_save(window)
local dlg,selected_file,name
local index:=0,cellid,cells:={}
local rates:=rating[1..movecount()+1]
local amoeba:="amoeba"+TABLESIZE::str::alltrim
local content:=""

    if(gtk.main_depth()>1);return NIL;end

    while( NIL!=(cellid:=cell(index++)) )
        aadd(cells,cellid)
    end

    cells::=any2str
    rates::=any2str

    content:=amoeba+chr(10)
    content+=cells+chr(10)
    content+=rates+chr(10)
    content+=chr(winner())+chr(10)

    name:=amoeba+"-"+content::str2bin::crc32::l2hex::padl(8,"0")

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
        memowrit(selected_file,content)
    end


******************************************************************************
static function cb_info(w)
    //? "cb_info", gtk.main_depth()
    //if(gtk.main_depth()>1);return NIL;end
    //engedni kell a rekurziót
    infolevel(w:get_active)


******************************************************************************
static function cb_power(w)
    //? "cb_power", gtk.main_depth()
    //if(gtk.main_depth()>1);return NIL;end
    //engedni kell a rekurziót
    setpower(w:get_active_text)


******************************************************************************
static function cb_motion_notify(area,event)
local x,n
    //? "cb_motion_notify", gtk.main_depth()
    if(gtk.main_depth()>1);return NIL;end

    // mozgásra hunyorog
    // (nem annyira jó ötlet)
    //if( (x:=topcell())!=NIL )
    //    drawcell(x)
    //    sleep(200)
    //    drawtop(x)
    //    sleep(200)
    //end



******************************************************************************
function label_move()
local m:=movecount()
    label_move:set_markup( "Move: <b>"+m::str::alltrim+"</b>" )
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

        black:=circle_image(CELLSIZE,0,0,0,3/4,3/4,3/4)
        white:=circle_image(CELLSIZE,1,1,1,3/4,3/4,3/4)
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


function old_label_turn()
local mc:=movecount()
local circle:=chr(0x25cf)
local text:="Turn: <span size='x-large' color='COLOR'>"+circle+"</span>"
    if( (mc%2)==0 )
        text::=strtran("COLOR","black" )
    else
        text::=strtran("COLOR","white" )
    end
    label_turn:set_markup( text )


******************************************************************************
function label_rate(x)
local mc1:=movecount()+1
    if( x!=NIL )
        rating[mc1]:=x
    else
        x:=rating[mc1]
    end
    label_rate:set_markup( "Rating: <b>"+x::int::str::alltrim+"</b>" )


******************************************************************************
static function validpos(event,x,y,but)

static cellsize  := DRAW_CELLSIZE
static orig_x    := DRAW_ORIGO_X
static orig_y    := DRAW_ORIGO_Y

local xy:=gdk.event.get_coords(event)

    x:=xy[1]
    y:=xy[2]
    but:=gdk.event_button.get_button(event) //1,2,3 -- bal,köz,jobb

    if( x%cellsize<2 .or. x%cellsize>cellsize-2 )
        return .f.
    elseif( y%cellsize<2 .or. y%cellsize>cellsize-2 )
        return .f.
    end

    x:=int(x/cellsize)-1
    y:=int(y/cellsize)-1

    if( x<0 .or. tablesize()<=x )
        return .f.
    elseif( y<0 .or. tablesize()<=y )
        return .f.
    elseif( figure(y*tablesize()+x)!=32 )
        return .f.
    end

    return  .t.


******************************************************************************
function mainwindow(w)
static window
    if( w!=NIL )
        window:=w
    end
    return window


******************************************************************************
function drawingarea()
    return area


******************************************************************************
function tablesize(ts)
static tablesize:=DRAW_TABSIZE
    if( ts!=NIL .and. 12<=ts .and. ts<=24 )
        tablesize:=ts
        cairo_settabsize(ts)
        cell_settabsize(ts)
    end
    return tablesize


******************************************************************************
