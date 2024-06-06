
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


#include "amoeba.ch"


static rating:=array(ROWCOL)
static recalc:=array(ROWCOL)
static bestline:=array(ROWCOL)

static color:={"'black'","'white'"}

******************************************************************************************
function rating_store( rp )
local mc:=movecount()
    if( mc>0 )
        rating[mc]:=rp
    end

function rating_string( mc:=movecount() )
local rp
    if( 1 <= mc <=movecount() )
        rp:=rating[mc]
    end
    return rp|""


function rating_value(mc:=movecount())
local value,v
    if( 1<=mc<=movecount() )
        v:=rating[mc]
        if( v!=NIL )
            v::=split("/")
            if( !empty(v) )
                v:=val(v[1])
                value:=v
            end
        end
    end
    return value


******************************************************************************************
function recalc_store( rpm )
local mc:=movecount()
    if( mc>0 )
        recalc[mc]:=rpm
    end


function recalc_string( mc:=movecount() )
local rpm
    if( 1 <= mc <= movecount() )
        rpm:=recalc[mc]
    end
    return rpm|""


function recalc_value(mc:=movecount())
local value,v
    if( 1<=mc<=movecount() )
        v:=recalc[mc]
        if( v!=NIL )
            v::=split("/")
            if( !empty(v) )
                v:=val(v[1])
                value:=v
            end
        end
    end
    return value


******************************************************************************************
function bestline_store( line )
local mc:=movecount()
    if( mc>0 )
        bestline[mc]:=aclone(line)
    end


function bestline_array( mc:=movecount() )
local line
    if( 1 <= mc <= movecount() )
        line:=bestline[mc]
    end
    return line|{}


function bestline_string( mc:=movecount() )
local line,n,x
    if( 1 <= mc <= movecount() )
        line:=bestline[mc]
        if( !empty(line) )
            x:=pos2rc(line[1])
            for n:=2 to len(line)
                x+=","+pos2rc(line[n])
            next
        end
    end
    return x|""


function bestline_format(bestline, val, cx, big)

local labtxt,sp,rc,n

    if( !empty(bestline) .and. val!=NIL )
        sp:="<span color='#b8b8b8'>.</span>"
        labtxt:=sp+"<span color='green'>("+val::str::alltrim+")</span>"+sp
    
        for n:=1 to len(bestline)
            rc:=pos2rc(bestline[n])
            if( big==n )
                rc:='<big><big><b>'+rc+'</b></big></big>'
            end
            labtxt+=" <span color="+color[cx+1]+">"+rc+"</span> "
            cx:=(cx+1)%2
        next
    
        if( abs(val)>9000 )
            labtxt::=strtran("green","red")
            if( val>0 )
                labtxt+="<span color='black'>#</span>"
            else
                labtxt+="<span color='white'>#</span>"
            end
        end
    end
    
    return labtxt


******************************************************************************************
