
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
#include <pvalue.h>
#include <pattern.h>
#include <cell.h>


static void print_movegen(int cnt);


//--------------------------------------------------------------------------
int cell::movegen(int total, int movflg) //kikeresi a megadott szamu "legfontosabb" mezot
{
    // total      -> ennyi darab lépést keres
    // (movflg&1) -> total-on felül bevesz minden kényszerítő lépést
    // (movflg&2) -> nem számítja be fehér alakzatait
    // (movflg&4) -> nem számítja be fekete alakzatait
    
    // 0: minden alakzatot beszámít, a kényszerítőket nem kezeli külön
    // 1: minden alakzatot beszámít, a kényszerítőket pluszban hozzáveszi
    // 2: fehér alakzatait nem számítja be (fehér csak védekezik)
    // 4: fekete alakzatait nem számítja be (fekete csak védekezik)
  

    if( cell::winner!=' ' )
    {
        return cell::bestcnt=0;
    }

    int FORCE=((movflg&1)||(total==0))?1:0;

    int cnt=0;
    int minx=-1;
    int minv=-1;
    int maxturn=-1;
    int maxoppo=-1;

    for( int i=0; i<(cell::tablesize*cell::tablesize); i++ )
    {
        int  cx=cell::spiral[i]; //kozeprol kifele
        cell *c=cell::cells[cx];
        int  vo=0,vt=0,vs;

        if( c->figure!=' ')
        {
            continue;
        }

        if( (cell::movecount&1)==0 )
        {
            // fekete lep
            if(!(movflg&2)) vo=c->fieldval[c->layer].white; // oppo
            if(!(movflg&4)) vt=c->fieldval[c->layer].black; // turn
        }
        else//if( (cell::movecount&1)==1 )
        {
            // feher lep
            if(!(movflg&2)) vt=c->fieldval[c->layer].white; // turn
            if(!(movflg&4)) vo=c->fieldval[c->layer].black; // oppo
        }
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


        if( vs<=minv && !(vt&FORCE) )
        {
            continue;
        }

        if( vt&FORCE )
        {
            // kozbeiktathato lepes
            // eredmeny halmaz bovitve

            total++;
            cell::best[cnt].cx=cx;
            cell::best[cnt].vo=vo;
            cell::best[cnt].vt=vt;
            cell::best[cnt].vs=vs;
            cnt++;
            //print_movegen(think,cnt);
        }
        else if( cnt<total )
        {
            cell::best[cnt].cx=cx;
            cell::best[cnt].vo=vo;
            cell::best[cnt].vt=vt;
            cell::best[cnt].vs=vs;
            cnt++;
            //print_movegen(think,cnt);
        }
        else
        {
            minv=PVALUE_INFIN;
            for( int n=0; n<cnt; n++ )
            {
                if( cell::best[n].vs<minv  &&  (cell::best[n].vt&FORCE)==0 )
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
                //print_movegen(think,cnt);
            }
        }
    }

    if( cnt>1 )
    {
        qsort(cell::best,cnt,sizeof(BEST),cell::cmp_best);
    }

    //print_movegen(cnt);
    return cell::bestcnt=cnt;
}


//--------------------------------------------------------------------------
static void print_movegen(int cnt)
{
    printf("MOVEGEN %c %d ", cell::movecount&1?'X':'O', cnt);

    for(int i=0; i<cnt; i++)
    {
        int cx=cell::best[i].cx;
        int vs=cell::best[i].vs;
        int col=cx%cell::tablesize;
        int row=cx/cell::tablesize;
        printf(" (%c%d,%d)",'a'+row,1+col,vs);
    }
    printf("\n");
}


//--------------------------------------------------------------------------

