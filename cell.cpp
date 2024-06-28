
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


#include <stdio.h>
#include <stdlib.h>
#include <cell.h>
#include <pvalue.h>
#include <pattern.h>


//--------------------------------------------------------------------------
cell::cell(int r, int c)  // konstruktor (inicializálja az objektumokat)
{
    row=r;
    col=c;
    count=row*cell::tablesize+col;
    figure=' ';

    layer=0;
    fieldval[0].white=0;
    fieldval[0].black=0;
    for( int d=0; d<4; d++ )
    {
        pattern[0].white[d]=0;
        pattern[0].black[d]=0;
    }

    calcdist(cell::tablesize/2,cell::tablesize/2);
    cell::cells[count]=this;
}


//--------------------------------------------------------------------------
static int bitrev(int b)
{
    int r=0;
    b&=0x0ff;
    b|=0x100;
    while( b&0x1fe )
    {
        r=r<<1;
        r|=(b&1);
        b=b>>1;
    }
    return r;
}

//--------------------------------------------------------------------------
void cell::initsiblings()
{
    int rowcol=cell::tablesize*cell::tablesize;

    // nezi a szomszed cellakat,
    // tehat csak azutan hivhato,
    // miutan minden cella elkeszult

    int sibx=0;

    wall[KELET]=0;
    for( int mask=1, i=-4; i<=4; i++ ) // → kelet
    {
        if( i==0 )
        {
            continue; // onmaga
        }
        cell *c;
        int x=count+i;
        if( 0<=x && x<rowcol && (c=cell::cells[x]) && c->row==row )
        {
            siblings[sibx].cx=c->count;
            siblings[sibx].mask=mask;
            siblings[sibx].direction=KELET;
            sibx++;
        }
        else
        {
            wall[KELET]|=mask;
        }
        mask=mask<<1;
    }
    wall[KELET]=bitrev(wall[KELET]);



    wall[EKELET]=0;
    for( int mask=1, i=-4; i<=4; i++ ) // ↗ észak-kelet
    {
        if( i==0 )
        {
            continue; // onmaga
        }
        cell *c;
        int x=count-i*(cell::tablesize-1);
        if( 0<=x && x<rowcol && (c=cell::cells[x]) && c->row+c->col==row+col )
        {
            siblings[sibx].cx=c->count;
            siblings[sibx].mask=mask;
            siblings[sibx].direction=EKELET;
            sibx++;
        }
        else
        {
            wall[EKELET]|=mask;
        }
        mask=mask<<1;
    }
    wall[EKELET]=bitrev(wall[EKELET]);


    wall[ESZAK]=0;
    for( int mask=1, i=-4; i<=4; i++ ) // ↑ észak
    {
        if( i==0 )
        {
            continue; // onmaga
        }
        cell *c;
        int x=count-i*(cell::tablesize);
        if( 0<=x && x<rowcol && (c=cell::cells[x]) && c->col==col )
        {
            siblings[sibx].cx=c->count;
            siblings[sibx].mask=mask;
            siblings[sibx].direction=ESZAK;
            sibx++;
        }
        else
        {
            wall[ESZAK]|=mask;
        }
        mask=mask<<1;
    }
    wall[ESZAK]=bitrev(wall[ESZAK]);


    wall[DKELET]=0;
    for( int mask=1, i=-4; i<=4; i++ ) // ↘ dél-kelet
    {
        if( i==0 )
        {
            continue; // onmaga
        }
        cell *c;
        int x=count+i*(cell::tablesize+1);
        if( 0<=x && x<rowcol && (c=cell::cells[x]) && c->row-c->col==row-col )
        {
            siblings[sibx].cx=c->count;
            siblings[sibx].mask=mask;
            siblings[sibx].direction=DKELET;
            sibx++;
        }
        else
        {
            wall[DKELET]|=mask;
        }
        mask=mask<<1;
    }
    wall[DKELET]=bitrev(wall[DKELET]);

    // sentinel
    siblings[sibx].cx=-1;
    siblings[sibx].mask=0;

}


//--------------------------------------------------------------------------
int cell::pushlayer()
{
    if( layer>=MAXLAYER-1 )
    {
        printf("\nLAYER OVERFLOW %d[%d:%d]\n",layer,row,col);
        extern void _clp_callstack(int);
        _clp_callstack(0);
        exit(1);
    }

    layer++;
    fieldval[layer].white=fieldval[layer-1].white;
    fieldval[layer].black=fieldval[layer-1].black;
    for( int d=0; d<4; d++ )
    {
        pattern[layer].white[d]=pattern[layer-1].white[d];
        pattern[layer].black[d]=pattern[layer-1].black[d];
    }
    return layer;
}

//--------------------------------------------------------------------------
int cell::poplayer()
{
    if( layer<=0 )
    {
        printf("\nLAYER UNDERFLOW %d[%d:%d]\n",layer,row,col);
        extern void _clp_callstack(int);
        _clp_callstack(0);
        exit(1);
    }

    layer--;
    return layer;
}


//--------------------------------------------------------------------------
static void setmap(int x,char fig)
{
    int mx=x>>2;
    int shift=(x&3)<<1;     // 0,           2,           4,           6
    char mask=~(3<<shift);  // fc=11111100, f3=11110011, cf=11001111, 3f=00111111
    cell::map[mx]=(cell::map[mx]&mask)|(fig<<shift);

    //test
    //extern unsigned int crc32(void *data, int size);
    //unsigned int crc=crc32(cell::map, cell::tablesize*cell::tablesize);
    //printf("CRC %08x x=%d fig=%d mx=%d, mask=%02x\n",crc, x,fig,mx,mask);
}

//--------------------------------------------------------------------------
cell *cell::unset()  // leveszi az utolsó figurát a tábláról (OSZTALY FUGGVENY)
{

    if( cell::movecount>0 )
    {
        cell::zobrist_update();
        cell::movecount--;
        cell *c=cell::cells[cell::movestack[cell::movecount]];

        c->figure=' ';
        cell::winner=' ';
        setmap(c->count,0);

        for( int sibx=0; c->siblings[sibx].mask; sibx++ )
        {
            cell *sibling=cell::cells[c->siblings[sibx].cx];
            if( sibling->figure==' ' )
            {
                sibling->poplayer();
            }
        }
        
        
        if( cell::movecount==0 )
        {
            // ellenorzes
            for( int cx=0; cx<cell::tablesize*cell::tablesize; cx++ )
            {
                cell *cc=cell::cells[cx];
                if( cc->layer )
                {
                    printf("LAYER ERROR %d[%d:%d]\n", c->layer,c->row,c->col);
                }
                else if( cc->fieldval[0].white!=0 )
                {
                    printf("FIELDVAL ERROR (white) %d[%d:%d]\n", c->fieldval[0].white,c->row,c->col);
                }
                else if( cc->fieldval[0].black!=0 )
                {
                    printf("FIELDVAL ERROR (black) %d[%d:%d]\n", c->fieldval[0].black,c->row,c->col);
                }
            }
        }
        return c;
    }
    return 0;
}

// set() forditottja miert nem objektum metodus?
// Mert a koveket csakis a felrakas sorrendjeben (visszafele)
// szabad leszedni, maskepp elromlananak a retegek.


//--------------------------------------------------------------------------
cell *cell::set() // felteszi magát a táblára (OBJEKTUM FUGGVENY)
{
    if( (cell::winner==' ') && (cell::movecount<(cell::tablesize*cell::tablesize)) && (this->figure==' ')  )
    {
        movestack[cell::movecount++]=count;
        cell::zobrist_update();

        if( (cell::movecount&1)==0 )
        {
            figure='O';
            if( fieldval[layer].white>=PVALUE_EGY )
            {
                cell::winner=figure;
            }
            setmap(count,1);
        }
        else
        {
            figure='X';
            if( fieldval[layer].black>=PVALUE_EGY )
            {
                cell::winner=figure;
            }
            setmap(count,2);
        }
        updatesiblings();
        return this;
    }
    return 0;
}


//--------------------------------------------------------------------------
void cell::updatesiblings() // újraszámolja a szomszéd cellák értékét
{
    for( int sibx=0; siblings[sibx].mask; sibx++ )
    {
        // vegigmegy az osszes szomszedon
        cell *sibling=cell::cells[siblings[sibx].cx];

        if( sibling->figure==' ' )
        {
            int lx=sibling->pushlayer();
            int mask=siblings[sibx].mask;
            int dir=siblings[sibx].direction;

            if( figure=='O' )
            {
                sibling->pattern[lx].white[dir]|=mask;
            }
            else //if( figure=='X' )
            {
                sibling->pattern[lx].black[dir]|=mask;
            }
            sibling->calcval();
        }
    }
}


//--------------------------------------------------------------------------
void cell::calcval() // kiszámítja a cella értékét
{
    fieldval[layer].white=0;
    fieldval[layer].black=0;

    PATTERN *p=pattern+layer;
    char *po=p->white;
    char *px=p->black;
    char *pw=this->wall;
    FLDVAL *fv=fieldval+layer;
    int v;
    for( int dir=0; dir<4; dir++ )
    {
        fv->white+=(v=ponttab(po[dir],px[dir]|pw[dir]));
        if( v>=PVALUE_KET1 )
        {
            fv->white|=1;  // enforce bit
        }
        fv->black+=(v=ponttab(px[dir],po[dir]|pw[dir]));
        if( v>=PVALUE_KET1 )
        {
            fv->black|=1;  // enforce bit
        }
    }
}

//--------------------------------------------------------------------------
