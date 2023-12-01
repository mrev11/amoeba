
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


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/rand.h>

#include <cccapi.h>

#include <amoeba.ch>
#include <pattern.h>
#include <cell.h>


//--------------------------------------------------------------------------
int     cell::init=cell::classinit();       // inicializálja az osztály adatokat
cell  * cell::cells[ROWCOL];                // az összes cella tömbje (ez maga a tábla)
int     cell::spiral[ROWCOL];               // cellák középről kifele sorendben
int     cell::movestack[ROWCOL];            // lépések
int     cell::movecount=0;                  // lépésszám
int     cell::moveforw=0;                   // eddig lehet előremenni (hátralépések után)
cell  * cell::best_move[2]={0,0};           // O és X legjobb lépése
cell  * cell::second_move[2]={0,0};         // O és X második legjobb lépése
char    cell::winner= ' ';                  // ' ' vagy 'O' vagy 'X'


//--------------------------------------------------------------------------
int cell::classinit() // inicializálja az osztály adatokat
{
    ponttab_init();

    int i,j;
    for( i=0; i<MAXROW; i++ )
    for( j=0; j<MAXCOL; j++ )
    {
        cell *c=new cell(i,j);
    }

    for(int n=0; n<ROWCOL; n++ )
    {
        cell::spiral[n]=n;
        cell::cells[n]->modval();
    }
    qsort(cell::spiral,ROWCOL,sizeof(int),cell::cmp_dist);

    return 1;
}

//--------------------------------------------------------------------------
cell::cell(int r, int c)  // konstruktor (inicializálja az objektumokat)
{
    row=r;
    col=c;
    figure=' ';
    count=row*MAXCOL+col;

    unsigned char d;
    RAND_bytes(&d,1); 
    dist=abs(row-TABLESIZE/2)+abs(col-TABLESIZE/2)+(int)d/256.0;

    for( int i=0; i<4; i++ )
    {
        for( int j=0;j<8;j++ )
        {
            pattern[i][j]='?';
        }
    }
    fieldval[0]=0;
    fieldval[1]=0;

    cell::cells[count]=this;
}

//--------------------------------------------------------------------------
cell *cell::set() // felteszi magát a táblára
{
    if( (cell::winner==' ') && (cell::movecount<ROWCOL) )
    {
        movestack[cell::movecount++]=count;

        if( (cell::movecount&1)==0 )
        {
            figure='O';
            if( fieldval[0]>=PVALUE_EGY ) //PONTOK!!
            {
                cell::winner=figure;
            }
        }
        else
        {
            figure='X';
            if( fieldval[1]>=PVALUE_EGY ) //PONTOK!!
            {
                winner=figure;
            }
        }
        modval();
        return this;
    }
    return 0;
}

//--------------------------------------------------------------------------
void cell::calcval() // kiszámítja a cella értékét
{
    fieldval[0]=0;
    fieldval[1]=0;
    valuedir[0]=-1;
    valuedir[1]=-1;

    int p0=0,p1=0,p;

    for( int dir=0; dir<4; dir++ )
    {
        p=ponttab(pattern[dir],'O');
        fieldval[0]+=p;
        if( p>p0 )
        {
            p0=p;
            valuedir[0]=dir;
        }

        p=ponttab(pattern[dir],'X');
        fieldval[1]+=p;
        if( p>p1 )
        {
            p1=p;
            valuedir[1]=dir;
        }
    }
}

//--------------------------------------------------------------------------
int cell::maxval()
{
    return max(fieldval[0],fieldval[1]); //X max, O min
}

//--------------------------------------------------------------------------
void cell::modval() // újraszámolja a szomszéd cellák értékét
{
    int i,j;
    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count+i;
        if( x<0 || ROWCOL<=x ) continue;
        cell *c=cell::cells[x];
        if( c->row!=row ) continue;
        c->pattern[0][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count-i*(MAXCOL-1) ;
        if( x<0 || ROWCOL<=x ) continue;
        cell *c=cell::cells[x];
        if( c->row+c->col!=row+col ) continue;
        c->pattern[1][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count-i*MAXCOL ;
        if( x<0 || ROWCOL<=x ) continue;
        cell *c=cell::cells[x];
        if( c->col!=col ) continue;
        c->pattern[2][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count+i*(MAXCOL+1) ;
        if( x<0 || ROWCOL<=x ) continue;
        cell *c=cell::cells[x];
        if( c->row-c->col!=row-col ) continue;
        c->pattern[3][j]=figure;
        if(c->figure==' ') c->calcval();
    }
}


//--------------------------------------------------------------------------
// osztály függvények
//--------------------------------------------------------------------------
cell *cell::unset()  // leveszi az utolsó figurát a tábláról
{
    if( cell::movecount>0 )
    {
        cell::movecount--;
        cell *c=cell::cells[cell::movestack[cell::movecount]];
        c->figure=' ';
        c->modval();
        cell::winner=' ';
        return c;
    }
    return 0;
}

//--------------------------------------------------------------------------
int cell::posvalue() //statikus állásértékelés
{
    if( cell::winner=='O' )
    {
        return -PVALUE_INFIN;
    }
    else if( cell::winner=='X' )
    {
        return  PVALUE_INFIN;
    }
    else
    {
        int oturn=((cell::movecount&1)==1);
        int xturn=((cell::movecount&1)==0);
        int bo=BVAL(0),so=SVAL(0);
        int bx=BVAL(1),sx=SVAL(1);
        int v=0;

#ifndef NOTDEF
        if( xturn )
        {
            if( sx>=bo )
            {
                return(bx+sx);
            }
            else if( bx>=bo )
            {
                return(bx);
            }
            else if( so>bx )
            {
                return(-bo-so);
            }
            else
            {
                return(-bo);
            }
        }
        else //if( oturn )
        {
            if( so>=bx )
            {
                return(-bo-so);
            }
            else if( bo>=bx )
            {
                return(-bo);
            }
            else
            {
                return(sx);
            }
        }
#else
        if( xturn )
        {
            if( bx>=bo )
            {
                v=bx;
                if( sx>=bo )
                {
                    v+=sx;
                }
            }
            else
            {
                v=-bo;
                if( so>bx )
                {
                    v-=so;
                }
            }
        }
        else
        {
            if( bo>=bx )
            {
                v=-bo;
                if( so>=bx )
                {
                    v-=so;
                }
            }
            else
            {
                v=bx;
                if( sx>bo )
                {
                    v+=sx;
                }
            }
        }
        return v;
#endif


    }
}

//--------------------------------------------------------------------------
void cell::store_best(cell *c) // tárolja a legjobb cellát
{
    for( int x=0; x<=1; x++ )
    {
        int v=c->fieldval[x];
        int d=c->valuedir[x];

        if( v>BVAL(x) )
        {
            cell::second_move[x]=cell::best_move[x];
            cell::best_move[x]=c;
        }
        else if( v>SVAL(x) )
        {
            cell::second_move[x]=c;
        }
    }
}

//--------------------------------------------------------------------------
int cell::cmp_value(void const *xp, void const *yp) // melyik cellában van értékesebb alakzat
{
    int *x=(int*)xp;
    int *y=(int*)yp;

    int res=0;

    if( *x<*y )
    {
        res=1;
    }
    else if( *x>*y )
    {
        res=-1;
    }
    return res;
}


//--------------------------------------------------------------------------
int cell::cmp_dist(void const *x, void const *y) // melyik cella van távolabb a középtől
{
    cell *a=cell::cells[ *(int*)x ];
    cell *b=cell::cells[ *(int*)y ];
    double da=a->dist;
    double db=b->dist;

    if( da>db )
    {
        return 1;
    }
    else if( db>da )
    {
        return -1;
    }
    return 0;
}


//--------------------------------------------------------------------------
// CLIPPER interfész
//--------------------------------------------------------------------------
void _clp_posvalue(int argno)
{
    CCC_PROLOG("posvalue",0);
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
        c->set();
    }
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
void _clp_c_cb_new( int argno )
{
    CCC_PROLOG("c_cb_new",1);
    cell *c;
    while( (c=cell::unset())!=0 );

    if( !ISNIL(1) )
    {
        int len=_paralen(1);
        for( int i=0; i<len; i++ )
        {
            VALUE *v=_parax(1,i);
            unsigned x=D2UINT(v->data.number);
            cell::cells[x]->set();
        }
        cell::moveforw=cell::movecount;
    }
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
