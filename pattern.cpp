
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
#include <pattern.h>
#include <pvalue.h>


#define TABLESIZE 0x10000
static int table[TABLESIZE]; 
 

static char const *egy[]={
"    XXXX",
"   XXXX ",
"  XXXX  ",
" XXXX   ",
"XXXX    ",
0};

static char const *ket2[]={
"_XXX_   ", 
" _XXX_  ", 
"  _XXX_ ", 
"   _XXX_", 
"XXX__XXX", 
" XX_X_XX", 
"XX_X_XX ", 
"  X_XX_X", 
" X_XX_X ", 
"X_XX_X  ", 
0};


static char const *ket1[]={
"    _XXX",
"    X_XX",
"    XX_X",
"    XXX_",
"   _XXX ",
"   X_XX ",
"   XX_X ",
"   XXX_ ",
"  _XXX  ",
"  X_XX  ",
"  XX_X  ",
"  XXX_  ",
" _XXX   ",
" X_XX   ",
" XX_X   ",
" XXX_   ",
"_XXX    ",
"X_XX    ",
"XX_X    ",
"XXX_    ",
0};


static char const *harom2[]={
"__XX_   ", 
"_X_X_   ", 
"_XX__   ", 
" __XX_  ", 
" _X_X_  ", 
" _XX__  ", 
"  __XX_ ", 
"  _X_X_ ", 
"  _XX__ ", 
"   __XX_", 
"   _X_X_", 
"   _XX__", 
" XX___XX", 
"XX___XX ", 
"  X__X_X", 
"  X_X__X", 
" X__X_X ", 
" X_X__X ", 
"X__X_X  ", 
"X_X__X  ", 
0};


static char const *harom1[]={
"    __XX",
"    _X_X",
"    _XX_",
"    X__X",
"    X_X_",
"    XX__",
"   __XX ",
"   _X_X ",
"   _XX_ ",
"   X__X ",
"   X_X_ ",
"   XX__ ",
"  __XX  ",
"  _X_X  ",
"  _XX_  ",
"  X__X  ",
"  X_X_  ",
"  XX__  ",
" __XX   ",
" _X_X   ",
" _XX_   ",
" X__X   ",
" X_X_   ",
" XX__   ",
"__XX    ",
"_X_X    ",
"_XX_    ",
"X__X    ",
"X_X_    ",
"XX__    ",
0};
 

static char const *negy2[]={
"___X_   ", 
"__X__   ", 
"_X___   ", 
" ___X_  ", 
" __X__  ", 
" _X___  ", 
"  ___X_ ", 
"  __X__ ", 
"  _X___ ", 
"   ___X_", 
"   __X__", 
"   _X___", 
0};


static char const *negy1[]={
"X___    ",
" X___   ",
"  X___  ",
"   X___ ",
"    X___",
"_X__    ",
" _X__   ",
"  _X__  ",
"   _X__ ",
"    _X__",
"__X_    ",
" __X_   ",
"  __X_  ",
"   __X_ ",
"    __X_",
"___X    ",
" ___X   ",
"  ___X  ",
"   ___X ",
"    ___X",
0};



//--------------------------------------------------------------------------
static char* bin(int x) // byte bitenkenti kiirasa debugolashoz
{
    static char buf[32];
    for( int pos=0,i=0;  i<8;  i++ )
    {
        buf[pos++]= (x&0x80) ?'1':'0';
        if( pos==4 )
        {
            buf[pos++]=' ';
        }
        x=x<<1;
    }
    return buf;
}

 
//--------------------------------------------------------------------------
static void ponttab_feltolt( char const *xpattern[], int value )
{
    for(int n=0; xpattern[n]!=0; n++ )
    {
        int x=0;
        int w=0;
        
        for( int i=0; i<8; i++ )
        {
            if( xpattern[n][i]=='X' )
            {
                x=x<<1; x|=1;
                w=w<<1; w|=1;
            }
            else if( xpattern[n][i]=='_' )
            {
                x=x<<1; x|=0;
                w=w<<1; w|=1;
            }
            else //if( xpattern[n][i]==' ' )
            {
                x=x<<1;
                w=w<<1;
            }
        }


        //           "    __XX"
        // x=00000000 00000011
        // w=00000000 00001111

        w=((~w)&0xff);   // w=00000000 11110000
        w|=(w<<8);       // w=11110000 11110000

        for(int i=0; i<TABLESIZE; i++)
        {
            int k=i;
            k&=w;
            k|=x;

            table[k]=value;
        }
    }
}


//--------------------------------------------------------------------------
void ponttab_init()
{
    for(int i=0; i<TABLESIZE; i++)
    {
        table[i]=0;
    }

    // a nagyob ertekek
    // felulirjak a kisebbeket
    
    ponttab_feltolt(negy1  , PVALUE_NEGY1);
    ponttab_feltolt(negy2  , PVALUE_NEGY2);
    ponttab_feltolt(harom1 , PVALUE_HAR1);
    ponttab_feltolt(harom2 , PVALUE_HAR2);
    ponttab_feltolt(ket1   , PVALUE_KET1);
    ponttab_feltolt(ket2   , PVALUE_KET2);
    ponttab_feltolt(egy    , PVALUE_EGY);


    /*
    for(int i=0; i<TABLESIZE; i++)
    {
        printf("[%04x]  ",i);
        printf("[%s]  ",bin(i>>8));
        printf("[%s]  ",bin(i&255));
        printf("value=%d  ",table[i]);
        printf("\n");
    }
    */
}


//--------------------------------------------------------------------------
int ponttab(int x, int w)
{
    int index=0xffff & ((w<<8)|x);

    /*    
    printf("PONTTAB: ");
    printf("  w=%s ",bin(w));
    printf("  x=%s ",bin(x));
    printf("  index=%04x(%d)",index,index);
    printf("  value=%d",table[index]);
    printf("\n");
    */

    return table[ index ];
}

//--------------------------------------------------------------------------
