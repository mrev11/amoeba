
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



#include <string.h>
#include <cccapi.h>
#include <pattern.h>
#include <cell.h>
#include <pvalue.h>


//--------------------------------------------------------------------------
// CLIPPER interfész
//--------------------------------------------------------------------------
void _clp_movegen(int argno)
{
    CCC_PROLOG("movegen",2);
    int cnt=_parni(1);
    int flg=ISNIL(2)?0:_parl(2);
    cnt=cell::movegen(cnt,flg?1:0);
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
    CCC_PROLOG("posvalue",2);
    int total=_parni(1);
    int movflg=ISNIL(2)?0:_parni(2);
    cell::movegen(total,movflg);
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
void _clp_fieldval(int argno)
{
    CCC_PROLOG("fieldval",1);
    int cx=_parni(1);
    cell *c=cell::cells[cx];
    _retni(c->fieldval[c->layer].white+c->fieldval[c->layer].black);
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_hot_move(int argno)
{
    CCC_PROLOG("force",0);
    if( cell::movecount==0 )
    {
        _retl(0); 
    }
    else
    { 
        int cx=cell::movestack[cell::movecount-1]; // topcell
        cell *c=cell::cells[cx];
        int w=c->fieldval[c->layer].white;
        int b=c->fieldval[c->layer].black;
        int f=c->figure;
        
        if( f=='X' )
        {
            _retl( b>=PVALUE_KET1 || w>=PVALUE_KET2 );
        
        } 
        else if( f=='O' ) 
        {
            _retl( w>=PVALUE_KET1 || b>=PVALUE_KET2 );
        } 
        else
        {
            _retl(0); // ide nem johet
        }

        // a táblára feltett utolsó kő
        // kényszeítő vagy kényszerített lépés volt
        // (esetleg nyerő)
        
    }
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_enforced_move(int argno)
{
    CCC_PROLOG("enforced_move",0);
    if( cell::movecount==0 )
    {
        _retl(0); 
    }
    else
    { 
        int cx=cell::movestack[cell::movecount-1];
        cell *c=cell::cells[cx];
        int w=c->fieldval[c->layer].white;
        int b=c->fieldval[c->layer].black;
        int black=cell::movecount&1;

        _retl( (black?w:b)>=PVALUE_EGY ); // kényszerített lépés

        // ha black==1
        // akkor fekete lépett utoljára
        // a mezőn fehérnek PVALUE_EGY-nél erősebb fenyegetése volt
        // ezért fekete lépése kényszer volt
    }
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_enforcing_candidate(int argno)
{
    CCC_PROLOG("enforcing_candidate",1);
    int cx=_parni(1);
    cell *c=cell::cells[cx];
    int w=c->fieldval[c->layer].white;
    int b=c->fieldval[c->layer].black;
    int black=cell::movecount&1;

    _retl( (black?b:w)>=PVALUE_EGY ); // kényszerítő lépés

    // ha black==1
    // akkor fekete lépett utoljára, tehát most fehér lép
    // feketének PVALUE_EGY-nél erősebb fenyegetése van a mezőn
    // ezért fehér kénytelen oda lépni

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

//---------------------------------------------------------------------------
void _clp_print_posvalue(int argno)
{
    CCC_PROLOG("print_posvalue",0);

    printf( "turn:%c ",cell::movecount&1?'O':'X');
    printf( "posvalue=%d\n",cell::posvalue() );
    fflush(0);
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
void _clp_print_pattern(int argno)
{
    CCC_PROLOG("print_pattern",1);
    int cx=_parni(1);
    cell::print_pattern(cx);
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_print_table(int argno)
{
    CCC_PROLOG("print_table",0);
    printf("\n");

    char row[64];
    memset(row,'=',64);
    row[cell::tablesize+2]=0;
    printf("%s\n",row);
    
    for( int r=0; r<cell::tablesize; r++ )
    {
        row[0]='|';
        for( int c=0; c<cell::tablesize; c++ )
        {
            int fig=cell::cells[ r*cell::tablesize+c ]->figure;
            row[1+c]=fig==' '?'.':fig;
        }
        row[cell::tablesize+1]='|';
        row[cell::tablesize+2]=0;
        printf("%s\n",row);
    }

    memset(row,'=',64);
    row[cell::tablesize+2]=0;
    printf("%s\n",row);
    fflush(0);

    _ret();
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_print_map(int argno)
{
    CCC_PROLOG("print_map",0);
    printf("\n");

    char row[64];
    memset(row,' ',64);
    for( int i=1; i<=cell::tablesize; i++)
    {
        row[1+i]='0'+i%10;
        row[2+i]=0;
    }
    printf("%s\n",row);
    
    for( int r=0; r<cell::tablesize; r++ )
    {
        row[0]='a'+r;
        row[1]='|';
        for( int c=0; c<cell::tablesize; c++ )
        {
            int x=r*cell::tablesize+c;
            int mx=x>>2;
            int shift=(x&3)<<1;     // 0,           2,           4,           6
            char mask=~(3<<shift);  // fc=11111100, f3=11110011, cf=11001111, 3f=00111111
            int fig=cell::map[mx];
            fig=fig&~mask;
            fig=fig>>shift;

            if( fig==0 )
                fig='.';
            else if( fig==1 )
                fig='O';
            else if( fig==2 )
                fig='X';

            row[2+c]=fig;
        }
        row[cell::tablesize+2]='|';
        row[cell::tablesize+3]='a'+r;
        row[cell::tablesize+4]=0;
        printf("%s\n",row);
    }


    memset(row,' ',64);
    for( int i=1; i<=cell::tablesize; i++)
    {
        row[1+i]='0'+i%10;
        row[2+i]=0;
    }
    printf("%s\n",row);
    fflush(0);

    _ret();
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
