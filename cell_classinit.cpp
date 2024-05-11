
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


#include <cell.h>
#include <pvalue.h>
#include <pattern.h>


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
int     cell::movegen_white=0;              // movegen paramétere, amikor white gondolkodik
int     cell::movegen_black=0;              // movegen paramétere, amikor black gondolkodik

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
        cell::cells[n]->initsiblings();
    }
    cell::randomize();

    return 1;
}


//--------------------------------------------------------------------------
// osztály függvények
//--------------------------------------------------------------------------
int cell::cmp_best(void const *xp, void const *yp) // melyik cellában van értékesebb alakzat
{
    BEST *x=(BEST*)xp;
    BEST *y=(BEST*)yp;

    return (y->vs-x->vs);
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

