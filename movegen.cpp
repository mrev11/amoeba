
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
#include <pattern.h>
#include <cell.h>


//#define MOVEGEN 0  
// ha MOVEGEN definialva van
//  - es erteke 0, akkor total-t boviti a PVALUE_KET1 mezokkel
//  - es erteke egy nagy szam, akkor a total-t nem boviti
// ha MOVEGEN nincs definialva
//  - akkor parameterekbol veszi az erteket  

//--------------------------------------------------------------------------
int cell::movegen(int total) //kikeresi a megadott szamu "legfontosabb" mezot
{
    if( cell::winner!=' ' )
    {
        return cell::bestcnt=0;
    }

    #ifndef MOVEGEN
    int MOVEGEN=0;
    if( (cell::moveforw&1)==0 )
    {
        MOVEGEN=cell::movegen_black;
    }
    else
    {
        MOVEGEN=cell::movegen_white;
    }
    #endif

    int turn=(cell::movecount&1)==0 ? 1:0;
    int oppo=(cell::movecount&1)==0 ? 0:1;

    int cnt=0;
    int minx=-1;
    int minv=-1;
    int maxturn=-1;
    int maxoppo=-1;

    for( int i=0; i<(cell::tablesize*cell::tablesize); i++ )
    {
        int  cx=cell::spiral[i]; //kozeprol kifele
        cell *c=cell::cells[cx];
        int  vo,vt,vs;

        if( c->figure!=' ')
        {
            continue;
        }

        vo=c->fieldval[oppo];
        vt=c->fieldval[turn];
        vs=vo+vt;

        if( vt>=PVALUE_EGY )
        {
            // azonnali nyerolepes
            cnt=1;
            cell::best[0].cx=cx;
            cell::best[0].vo=vo;
            cell::best[0].vt=vt;
            cell::best[0].vs=vs;
            cell::bestcnt=cnt;
            break;
        }

        if( maxoppo>=PVALUE_EGY )
        {
            // azonnali vesztes fenyeget
            // csak a nyerolepesek erdekesek
            continue;
        }

        if( vs<=minv && vt<PVALUE_KET1+MOVEGEN )
        {
            continue;
        }

        maxturn=max(maxturn,vt);
        maxoppo=max(maxoppo,vo);

        if( maxoppo>=PVALUE_EGY )
        {
            // azonnali vesztes fenyeget
            // ha nem talalunk azonnali nyerest
            // akkor kotelezo lesz ide rakni

            cnt=1;
            cell::best[0].cx=cx;
            cell::best[0].vo=vo;
            cell::best[0].vt=vt;
            cell::best[0].vs=vs;
            cell::bestcnt=cnt;
            continue;
        }

        if( vt>=PVALUE_KET1+MOVEGEN )
        {
            // kozbeiktathato lepes
            // eredmeny halmaz bovitve

            total++;
            cell::best[cnt].cx=cx;
            cell::best[cnt].vo=vo;
            cell::best[cnt].vt=vt;
            cell::best[cnt].vs=vs;
            cnt++;
        }
        else if( cnt<total )
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
                if( cell::best[n].vs<=minv )
                {
                    minx=n;
                    minv=cell::best[n].vs;
                }
            }
            if( vs>minv )
            {
                // ha jobb mint az eddigi minimum
                // akkor a minimalis helyere kerul
                cell::best[minx].cx=cx;
                cell::best[minx].vo=vo;
                cell::best[minx].vt=vt;
                cell::best[minx].vs=vs;
            }
        }
    }

    if( cnt>1 )
    {
        #ifdef HIBAS_OPTIMALIZACIO
            kihagyhat eletkepes mezoket
            a tanulsag kedveert nem torlom ki

            if( maxoppo>=PVALUE_KET2 )
            {
                int i=0;
                while(i<cnt)
                {
                    if( cell::best[i].vo<PVALUE_KET2 && cell::best[i].vt<PVALUE_KET1 )
                    {
                        memmove(&cell::best[i],&cell::best[i+1],(cnt-i)*sizeof(BEST)); //delete
                        --cnt;
                    }
                    else
                    {
                        ++i; // keep
                    }
                }
            }
        #endif

        qsort(cell::best,cnt,sizeof(BEST),cell::cmp_best);
    }

    return cell::bestcnt=cnt;
}

//--------------------------------------------------------------------------
















































