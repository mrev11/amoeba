
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


//--------------------------------------------------------------------------
int cell::movegen(int total) //kikeresi a megadott számú "legfontosabb" mezőt
{
    int maxtotal=min(MAXBEST,ROWCOL-cell::movecount);
    total=min(total,maxtotal);

    int turn=(cell::movecount&1)==0 ? 1:0;
    int oppo=(cell::movecount&1)==0 ? 0:1;

    int cnt=0;
    int minx=-1;
    int minv=-1;
    int maxturn=-1;
    int maxoppo=-1;
    int maxoppo_cx=-1;

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

        if( vs<=minv && vt<PVALUE_KET1 )
        {
            continue;
        }
        
        if( vt>=PVALUE_EGY )
        {
            // azonnali nyerés
            cell::best[0].cx=cx;
            cell::best[0].vo=vo;
            cell::best[0].vt=vt;
            cell::bestcnt=1;
            return 1;
        }

        if( maxoppo_cx>=0 )
        {
            // azonnali vesztés lehetősége
            // miatt semmi más nem érdekes
            continue;
        }
        if( vo>=PVALUE_EGY && maxoppo_cx<0 )
        {
            // azonnali vesztés lehetősége
            maxoppo_cx=cx;
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
        else if( vt>=PVALUE_KET1 && cnt<maxtotal )
        {
            // közbeiktatható lépés
            // eredmény halmaz bővítve

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
                if( cell::best[n].vs<=minv )
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

    if( maxoppo_cx>=0 )
    {
        // azonnali vesztés hárítása
        cell::best[0].cx=maxoppo_cx;
        cell::best[0].vo=maxoppo;
        cell::best[0].vt=0; //közömbös
        cell::bestcnt=1;
        return 1;
    }



//#define  NOTDEF
#ifdef   NOTDEF
if( total>=7 )
{
    printf("\n??TOTAL<%d> cnt=%d maxoppo=%d minv=%d\n",total,cnt,maxoppo,minv);
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
}
#endif

    for( int i=0; i<cnt; )
    {
        if( maxoppo>=PVALUE_KET2 && cell::best[i].vs<PVALUE_KET1 )
        {
            memmove(&cell::best[i],&cell::best[i+1],(cnt-i)*sizeof(BEST)); //delete
            --cnt;
        }
        else
        {
            ++i;
        }
    }
    qsort(cell::best,cnt,sizeof(BEST),cell::cmp_best);
    cell::bestcnt=cnt;

#ifdef NOTDEF
if( total>=7 )
{
    printf("\n!!TOTAL<%d> cnt=%d maxoppo=%d minv=%d\n",total,cnt,maxoppo,minv);
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
}
#endif

    return cell::bestcnt;
}

//--------------------------------------------------------------------------
