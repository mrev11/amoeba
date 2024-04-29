
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


#include <math.h>
#include <openssl/rand.h>

#include <amoeba.ch>
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
