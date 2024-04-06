
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
#include <math.h>
#include <openssl/rand.h>

#include <cccapi.h>

#include <amoeba.ch>
#include <draw.ch>
#include <pattern.h>
#include <cell.h>


//--------------------------------------------------------------------------
cell  * cell::cells[MAXCELLS];              // az összes cella tömbje (ez maga a tábla)
int     cell::spiral[MAXCELLS];             // cellák középről kifele sorendben
int     cell::movestack[MAXCELLS];          // lépések
int     cell::movecount=0;                  // lépésszám
int     cell::moveforw=0;                   // eddig lehet előremenni (hátralépések után)
char    cell::winner= ' ';                  // ' ' vagy 'O' vagy 'X'
BEST    cell::best[MAXBEST];                // movegen után a legjobb lépések
int     cell::bestcnt;                      // lépések száma best-ben
int     cell::tablesize=0;                  // táblaméret, később kap értéket

int     cell::save_move[MAXCELLS];          // lépések
int     cell::save_count=0;                 // lépésszám
int     cell::save_forw=0;                  // eddig lehet előremenni (hátralépések után)

//--------------------------------------------------------------------------
int cell::classinit() // inicializálja az osztály adatokat
{
    extern int tablesize();
    cell::tablesize=tablesize(); // csak a CCC inicializálása után hívható

    ponttab_init();

    int i,j;
    for( i=0; i<cell::tablesize; i++ )
    for( j=0; j<cell::tablesize; j++ )
    {
        cell *c=new cell(i,j);
    }

    for(int n=0; n<(cell::tablesize*cell::tablesize); n++ )
    {
        cell::spiral[n]=n;
        cell::cells[n]->modval();
    }
    cell::randomize();

    return 1;
}

//--------------------------------------------------------------------------
void cell::randomize() // újragenerálja a dist tagokat és rendezi a spirált
{
    int r=cell::tablesize/2;
    int c=cell::tablesize/2;
    cell:randomize(r,c);
}

//--------------------------------------------------------------------------
void cell::randomize(int cx) // újragenerálja a dist tagokat és rendezi a spirált
{
    int r=cx/cell::tablesize;
    int c=cx%cell::tablesize;
    cell:randomize(r,c);
}

//--------------------------------------------------------------------------
void cell::randomize(int r, int c) // újragenerálja a dist tagokat és rendezi a spirált
{
    for( int cx=0; cx<(cell::tablesize*cell::tablesize); cx++ )
    {
        cell::cells[cx]->calcdist(r,c);
    }
    qsort(cell::spiral,(cell::tablesize*cell::tablesize),sizeof(int),cell::cmp_dist);
}

//--------------------------------------------------------------------------
cell::cell(int r, int c)  // konstruktor (inicializálja az objektumokat)
{
    row=r;
    col=c;
    figure=' ';
    count=row*cell::tablesize+col;
    calcdist(cell::tablesize/2,cell::tablesize/2);

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
double cell::calcdist(int r, int c) // távolság a cx cellától
{
    unsigned char d;
    RAND_bytes(&d,1);
    dist=sqrt((row-r)*(row-r)+(col-c)*(col-c))+(int)d/256.0; //+[0,1)
    return dist;
}

//--------------------------------------------------------------------------
cell *cell::set() // felteszi magát a táblára
{
    if( (cell::winner==' ') && (cell::movecount<(cell::tablesize*cell::tablesize)) )
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
                cell::winner=figure;
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
void cell::modval() // újraszámolja a szomszéd cellák értékét
{
    int i,j;
    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count+i;
        if( x<0 || (cell::tablesize*cell::tablesize)<=x ) continue;
        cell *c=cell::cells[x];
        if( c->row!=row ) continue;
        c->pattern[0][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count-i*(cell::tablesize-1) ;
        if( x<0 || (cell::tablesize*cell::tablesize)<=x ) continue;
        cell *c=cell::cells[x];
        if( c->row+c->col!=row+col ) continue;
        c->pattern[1][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count-i*cell::tablesize ;
        if( x<0 || (cell::tablesize*cell::tablesize)<=x ) continue;
        cell *c=cell::cells[x];
        if( c->col!=col ) continue;
        c->pattern[2][j]=figure;
        if(c->figure==' ') c->calcval();
    }

    for(j=8,i=-4; i<=4; i++)
    {
        if( i==0 ) continue;
        j--;
        int x=count+i*(cell::tablesize+1) ;
        if( x<0 || (cell::tablesize*cell::tablesize)<=x ) continue;
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
int cell::cmp_best(void const *xp, void const *yp) // melyik cellában van értékesebb alakzat
{
    BEST *x=(BEST*)xp;
    BEST *y=(BEST*)yp;

    return (y->vs-x->vs);                   // passziv -> lassú
    return (y->vs-x->vs) + (y->vt-x->vt);   // aktivabb -> gyorsabb
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
void cell::save()
{
    for( int i=0; i<MAXCELLS; i++ )
    {
        cell::save_move[i]=cell::movestack[i];
    }
    cell::save_count=cell::movecount;
    cell::save_forw=cell::moveforw;
}

//--------------------------------------------------------------------------
void cell::restore()
{
    for( int i=0; i<MAXCELLS; i++ )
    {
        cell::movestack[i]=cell::save_move[i];
    }
    cell::movecount=cell::save_count;
    cell::moveforw=cell::save_forw;
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
void _clp_movegen(int argno)
{
    CCC_PROLOG("movegen",1);
    int total=_parni(1);
    int cnt=0;
    if( (cell::movecount&1)==0 )
    {
        cnt=cell::movegen(total); // black
    }
    else
    {
        cnt=cell::movegen(total); // white
    }
    for(int i=0;i<cnt; i++)
    {
        number( cell::best[i].cx );
    }
    array(cnt);
    _rettop();
    CCC_EPILOG();
}

// megjegyzés:
// a különböző lépésgenerálások egymás ellen játszathatók
// ehhez bele kell itt nyúlni a forrásba és újrafordítani

//--------------------------------------------------------------------------
void _clp_movegen1(int argno) //alternatív movegen (egymás ellen játszathatók)
{
    CCC_PROLOG("movegen1",1);
    int total=_parni(1);
    int cnt=cell::movegen1(total);
    for(int i=0;i<cnt; i++)
    {
        number( cell::best[i].cx );
    }
    array(cnt);
    _rettop();
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
    int x=_parni(1);
    _retni(cell::cells[x]->fieldval[1]); // index 1
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_fieldval_o(int argno)
{
    CCC_PROLOG("fieldval_o",1);
    int x=_parni(1);
    _retni(cell::cells[x]->fieldval[0]); // index 0
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
void _clp_c_markmovecount(int argno)
{
    CCC_PROLOG("c_markmovecount",0);
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
