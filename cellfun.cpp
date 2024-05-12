
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



#include <cccapi.h>
#include <pattern.h>
#include <cell.h>


//--------------------------------------------------------------------------
// CLIPPER interfész
//--------------------------------------------------------------------------
void _clp_movegen(int argno)
{
    CCC_PROLOG("movegen",2);
    int total=_parni(1);
    int turn=ISNIL(2)?' ':_parni(2);
    int cnt=cell::movegen(total,turn);
    for(int i=0;i<cnt; i++)
    {
        number( cell::best[i].cx );
    }
    array(cnt);
    _rettop();
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_posvalue(int argno)
{
    CCC_PROLOG("posvalue",1);
    if( !ISNIL(1) )
    {
        _clp_movegen(1);
        pop();
    }
    _retni(cell::posvalue());
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_forw(int argno)
{
    CCC_PROLOG("forw",1);
    int x=_parni(1);
    _retl(cell::cells[x]->set());
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_back(int argno)
{
    CCC_PROLOG("back",0);
    cell *c=cell::unset();
    if( c )
    {
        _retni(c->count);
    }
    else
    {
        _ret();
    }
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_fieldval_x(int argno)
{
    CCC_PROLOG("fieldval_x",1);
    int cx=_parni(1);
    cell *c=cell::cells[cx];
    _retni(c->fieldval[c->layer].black);
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_fieldval_o(int argno)
{
    CCC_PROLOG("fieldval_o",1);
    int cx=_parni(1);
    cell *c=cell::cells[cx];
    _retni(c->fieldval[c->layer].white);
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_turn_x(int argno)
{
    CCC_PROLOG("turn_x",0);
    _retl( (cell::movecount&1)==0 );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_turn_o(int argno)
{
    CCC_PROLOG("turn_o",0);
    _retl( cell::movecount&1 );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_turn(int argno)
{
    CCC_PROLOG("turn",0);
    _retc( cell::movecount&1?L"O":L"X" );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_movecount(int argno)
{
    CCC_PROLOG("move",0);
    _retni( cell::movecount );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_markmovecount(int argno)
{
    CCC_PROLOG("markmovecount",0);
    cell::moveforw=cell::movecount;
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_figure(int argno)
{
    CCC_PROLOG("figure",1);
    int x=_parni(1);
    _retni( cell::cells[x]->figure );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_winner(int argno)
{
    CCC_PROLOG("winner",0);
    _retni( cell::winner );
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_topcell(int argno)
{
    CCC_PROLOG("topcell",0);
    if( cell::movecount>0 )
    {
        _retni(cell::movestack[cell::movecount-1]);
    }
    else
    {
        _ret();
    }
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_cell(int argno)
{
    CCC_PROLOG("cell",1);
    int index=_parni(1);
    if( 0<=index && index<cell::movecount )
    {
        _retni(cell::movestack[index]);
    }
    else
    {
        _ret();
    }
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_c_cb_back(int argno)
{
    CCC_PROLOG("c_cb_back",0);
    cell *c=cell::unset();
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_c_cb_forward(int argno)
{
    CCC_PROLOG("c_cb_forward",0);
    if( cell::movecount<cell::moveforw )
    {
        cell *c=cell::cells[cell::movestack[cell::movecount]];
        _retl(c->set());
    }
    else
    {
        _retl(0);
    }
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_c_cb_new( int argno )
{
    CCC_PROLOG("c_cb_new",0);
    while( cell::unset()!=0 );
    _ret();
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_cell_classinit(int argno)
{
    CCC_PROLOG("cell_classinit",0);
    cell::classinit();
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_cell_save(int argno)
{
    CCC_PROLOG("cell_save",0);
    cell::save();
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_cell_restore(int argno)
{
    CCC_PROLOG("cell_restore",0);
    cell::restore();
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_cell_randomize(int argno)
{
    CCC_PROLOG("cell_randomize",2);
    if( argno==0 )
    {
        cell::randomize();
    }
    else if( argno==1 )
    {
        int cx=_parni(1);
        cell::randomize(cx);
    }
    else
    {
        int r=_parni(1);
        int c=_parni(2);
        cell::randomize(r,c);
    }
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_movegen_white(int argno)
{
    CCC_PROLOG("movegen_white",1);
    if( !ISNIL(1) )
    {
        cell::movegen_white=_parni(1);
    }
    _retni(cell::movegen_white);
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_movegen_black(int argno)
{
    CCC_PROLOG("movegen_black",1);
    if( !ISNIL(1) )
    {
        cell::movegen_black=_parni(1);
    }
    _retni(cell::movegen_black);
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_spiral(int argno)
{
    CCC_PROLOG("spiral",2);
    int x=_parni(1)-1;
    if( ISNIL(2) )
    {
        _retni(cell::spiral[x]);
    }
    else
    {
        int cx=_parni(2);
        cell::spiral[x]=cx;
        _ret();
    }
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
