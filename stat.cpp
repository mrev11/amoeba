
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
#include <cccapi.h>

#include <amoeba.ch>
#include <tabsize.h>
#include <pattern.h>
#include <cell.h>


// ezek nem kellenek a játékhoz
// csak debugoláshoz hasznos adatokat írnak ki

#ifdef WINDOWS
  typedef  wint_t  ARROW_T;
#else
  typedef  int     ARROW_T;
#endif


//--------------------------------------------------------------------------
static int arrow(int direction)
{
    static int a[4]={8594, 8599, 8593, 8600};
    if( direction<0 || 3<direction )
    {
        return ' ';
    }
    return a[direction];
}

//--------------------------------------------------------------------------
static void print_pattern(int dir, XPATTERN pat)
{
    printf(" %lc(",(ARROW_T)arrow(dir));
    for( int i=0; i<4; i++ )
    {
        printf("%c",pat[i]==32?'-':pat[i]);

    }
    printf(".");
    for( int i=4; i<8; i++ )
    {
        printf("%c",pat[i]==32?'-':pat[i]);
    }
    printf(")");
}

//--------------------------------------------------------------------------
static const char* num0(const char *format, int num)
{
    static int x=-1;
    static const char *ptr[16];
    if( x==-1 )
    {
        x=0;
        for(int i=0; i<16; i++)
        {
            ptr[i]=0;
        }
    }
    const char *p;
    if( num )
    {
        char buf[128];
        sprintf(buf,format,num);
        p=strdup(buf);

        if( ptr[x] )
        {
            free( (char*)ptr[x] );
        }
        ptr[x]=p;
        x++;
        x%=16;
    }
    else
    {
        p="";
    }
    return p;
}

//--------------------------------------------------------------------------
static void print_value( XPATTERN pat)
{
    const char *so=num0("%4d",ponttab(pat,'O'));
    const char *sx=num0("%4d",ponttab(pat,'X'));
    printf(" %4s %4s   ",so,sx);
}


//--------------------------------------------------------------------------
void _clp_c_cb_button_press_pos(int argno)
{
    CCC_PROLOG("c_cb_button_press_pos",0);
    
    printf( "turn:%c ",cell::movecount&1?'O':'X');
    printf( "posvalue=%d\n",cell::posvalue() );
    fflush(0);
    _ret();
    CCC_EPILOG();
}


//--------------------------------------------------------------------------
void _clp_c_cb_button_press_stat(int argno)
{
    CCC_PROLOG("c_cb_button_press_stat",1);
    int x=_parni(1);

    cell *c=cell::cells[x];

    if( c->figure==' ' )
    {
        printf(" %c",'a'+x/MAXCOL);
        printf("%-2d",x%MAXCOL);

        print_pattern( 0, c->pattern[0] );
        print_pattern( 1, c->pattern[1] );
        print_pattern( 2, c->pattern[2] );
        print_pattern( 3, c->pattern[3] );

        const char *vo=num0("%4d",c->fieldval[0]);
        const char *vx=num0("%4d",c->fieldval[1]);
        int ao=arrow(c->valuedir[0]);
        int ax=arrow(c->valuedir[1]);
        printf(" %4s%lc %4s%lc",vo,(ARROW_T)ao,vx,(ARROW_T)ax);

        printf("\n");
        fflush(0);
    }
    _ret();
    CCC_EPILOG();
}

//--------------------------------------------------------------------------
