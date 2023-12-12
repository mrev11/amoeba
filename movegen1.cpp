
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
#include <tabsize.h>
#include <pattern.h>
#include <cell.h>

// egyszerűbb változat
// nem bővíti az eredmény halmazt
// a közbeiktatható lépésekkel

//--------------------------------------------------------------------------
int cell::movegen1(int total) //kikeresi a megadott számú "legfontosabb" mezőt
{
    int turn=(cell::movecount&1)==0 ? 1:0;
    int oppo=(cell::movecount&1)==0 ? 0:1;

    int cnt=0;
    int minx=-1;
    int minv=-1;
    int maxturn=-1;
    int maxoppo=-1;

    for( int i=0; i<ROWCOL; i++ )
    {
        int  cx=cell::spiral[i]; //középről kifelé
        cell *c=cell::cells[cx];
        int  vo,vt,vs;

        if( c->figure!=' ')
        {
            continue;
        }

        vo=c->fieldval[oppo];
        vt=c->fieldval[turn];
        vs=vo+vt;
        if( vs<=minv  )
        {
            continue;
        }

        maxturn=max(maxturn,vt);
        maxoppo=max(maxoppo,vo);

        if( cnt<total )
        {
            cell::best[cnt].cx=cx;
            cell::best[cnt].vo=vo;
            cell::best[cnt].vt=vt;
            cell::best[cnt].vs=vs;
            cnt++;
        }
        else
        {
            minv=PVALUE_INFIN;
            for( int n=0; n<cnt; n++ )
            {
                if( cell::best[n].vs<=minv  )
                {
                    minx=n;
                    minv=cell::best[n].vs;
                }
            }

            if( vs>minv )
            {
                cell::best[minx].cx=cx;
                cell::best[minx].vo=vo;
                cell::best[minx].vt=vt;
                cell::best[minx].vs=vs;
            }
        }
    }


    for( int i=0; i<cnt; )
    {
        if( maxoppo>=PVALUE_EGY && cell::best[i].vs<PVALUE_EGY )
        {
            memmove(&cell::best[i],&cell::best[i+1],(cnt-i)*sizeof(BEST)); //del
            --cnt;
        }
        else if( maxoppo>=PVALUE_KET2 && cell::best[i].vs<PVALUE_KET1 )
        {
            memmove(&cell::best[i],&cell::best[i+1],(cnt-i)*sizeof(BEST)); //del
            --cnt;
        }
        else
        {
            ++i;
        }
    }

    qsort(cell::best,cnt,sizeof(BEST),cell::cmp_best);
    cell::bestcnt=cnt;

/*
    printf("\n================================================\n");
    for( int i=0; i<cnt; i++ )
    {
        printf("%2d   cx=%3d{%2d,%2d}   vo=%4d   vt=%4d   vs=%4d\n"
            ,i
            ,cell::best[i].cx
            ,cell::best[i].cx/TABLESIZE
            ,cell::best[i].cx%TABLESIZE
            ,cell::best[i].vo
            ,cell::best[i].vt
            ,cell::best[i].vs
            );
    }
*/

    return cnt;
}

//--------------------------------------------------------------------------
