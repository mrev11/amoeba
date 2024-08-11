
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
#include <wchar.h>
#include <utf8conv.h> // CCC-bol
#include <cccapi.h>

#include <cell.h>
#include <pattern.h>
#include <pvalue.h>

extern const char* numformat(const char *format, int num);

#ifdef WINDOWS
  typedef  wint_t  ARROW_T;
#else
  typedef  int     ARROW_T;
#endif


//----------------------------------------------------------------------------------------
static ARROW_T arrow(int direction)
{
    static ARROW_T a[4]={8594, 8599, 8593, 8600};
    if( direction<0 || 3<direction )
    {
        return (ARROW_T)' ';
    }
    return a[direction];
}


//----------------------------------------------------------------------------------------
static char row2r(int row)
{
    return 'a'+row;
}

static int col2c(int col)
{
    return 1+col;
}


//----------------------------------------------------------------------------------------
static char* ppatdir(cell *c, int dir)
{
    static char buf[32];

    XPATTERN *p=c->pattern+c->layer;

    int pos=0;
    int mask=1;

    for( int i=0; i<8; i++ )
    {
        if( i==4 )
        {
            buf[8-pos++]='.';
        }

        if( c->wall[dir]&mask )
        {
            buf[8-pos++]='?';
        }
        else if( p->white[dir]&mask )
        {
            buf[8-pos++]='O';
        }
        else if( p->black[dir]&mask )
        {
            buf[8-pos++]='X';
        }
        else
        {
            buf[8-pos++]='-';
        }
        mask=mask<<1;
    }
    buf[pos]=0;
    return buf;
}


//----------------------------------------------------------------------------------------
char *ppat(cell *c)
{
    static char buf[256];
    XPATTERN *p=c->pattern+c->layer;

    int offs=0;
    offs+=sprintf( buf+offs, "%lc(%s) ", arrow(0), ppatdir(c,0));
    offs+=sprintf( buf+offs, "%lc(%s) ", arrow(1), ppatdir(c,1));
    offs+=sprintf( buf+offs, "%lc(%s) ", arrow(2), ppatdir(c,2));
    offs+=sprintf( buf+offs, "%lc(%s) ", arrow(3), ppatdir(c,3));

    buf[offs]=0;
    return buf;
}

//----------------------------------------------------------------------------------------
static char *ppatx(cell *c)
{
    static char buf[256];
    XPATTERN *p=c->pattern+c->layer;

    int offs=0;
    offs+=sprintf( buf+offs, "%lc(%s) %02x %02x %02x ", arrow(0), ppatdir(c,0), p->white[0], p->black[0], c->wall[0]  );
    offs+=sprintf( buf+offs, "%lc(%s) %02x %02x %02x ", arrow(1), ppatdir(c,1), p->white[1], p->black[1], c->wall[1]  );
    offs+=sprintf( buf+offs, "%lc(%s) %02x %02x %02x ", arrow(2), ppatdir(c,2), p->white[2], p->black[2], c->wall[2]  );
    offs+=sprintf( buf+offs, "%lc(%s) %02x %02x %02x ", arrow(3), ppatdir(c,3), p->white[3], p->black[3], c->wall[3]  );
    buf[offs]=0;                                                                                                               
    return buf;                                                                                                                
}                                                                                                                              

//----------------------------------------------------------------------------------------
void cell::print()
{
    char dir[8]={'-','/','|','\\'};

    printf("\n----------------------------------------------------------------------------\n");
    printf("cell=%d[%c:%d] fig='%c'\n",count,row2r(row),col2c(col),figure);
    
    if( figure==' ' )
    {
        XPATTERN *p=pattern+layer;
        char *po=p->white;
        char *px=p->black;
        char *pw=wall;
        

        for( int d=0; d<4; d++)
        {
            int vo=ponttab(po[d],px[d]|pw[d]);
            int vx=ponttab(px[d],po[d]|pw[d]);

            printf("    %c (%s)",dir[d],ppatdir(this,d));
            printf(" %02x %02x %02x",po[d],px[d],pw[d]);
            printf(" vo=%d vx=%d",vo,vx);
            printf("\n");
        }
    }

    for( int sibx=0; siblings[sibx].mask; sibx++ )
    {
        int  cx=siblings[sibx].cx;
        int  mask=siblings[sibx].mask;
        cell *sib=cell::cells[cx];

        if( sib->figure==' ' )
        {
            printf( "  sib=%-3d[%c,%2d] layer=%-2d ", sib->count,row2r(sib->row),col2c(sib->col),sib->layer);
            printf(" %s ", ppatx(sib) );
            printf("\n");
        }
    }
}

//----------------------------------------------------------------------------------------
void cell::print_pattern(int cx)
{
    cell *c=cell::cells[cx];

    if( c->figure==' ' )
    {
        printf(" %c",'a'+c->row);
        printf("%-2d ",1+c->col);
        printf("%s",ppat(c));

        const char *vo=numformat("%4d",c->fieldval[c->layer].white);
        const char *vx=numformat("%4d",c->fieldval[c->layer].black);
        const char *vs=numformat("%3d",c->fieldval[c->layer].black+c->fieldval[c->layer].white);

        int force=' ';
        if( (cell::movecount&1)==1 && (1 & c->fieldval[c->layer].white) )
        {
            force='+';
        }
        if( (cell::movecount&1)==0 && (1 & c->fieldval[c->layer].black) )
        {
            force='+';
        }

        printf(" %4s %4s [%3s]%c",vo,vx,vs,force);
        fflush(0);
    }
}


//----------------------------------------------------------------------------------------
