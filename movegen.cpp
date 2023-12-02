
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
#include <pattern.h>
#include <cell.h>


//--------------------------------------------------------------------------
void _clp_movegen(int argno) //kikeresi a megadott számú "legfontosabb" mezőt
{
    CCC_PROLOG("movegen",1);
    int total=min(_parni(1),ROWCOL-cell::movecount);

    struct
    {
        int v;  //mezőérték
        int x;  //mezőindex
    }
    best[total];

    int turn=(cell::movecount&1)==0 ? 1:0;
    int oppo=(cell::movecount&1)==0 ? 0:1;

    int cnt=0;
    int minx=0;
    int minv=-1;
    int maxturn=-1;
    int maxoppo=-1;

    // első menet: az ellenfél lépései

    for(int i=0; i<ROWCOL; i++)
    {
        int x=cell::spiral[i]; //középről kifelé
        int v;
        cell *c=cell::cells[x];

        if( (c->figure==' ') && ((v=c->fieldval[oppo])>minv) )
        {
            maxoppo=max(v,maxoppo);

            if( cnt<total  )
            {
                minx=cnt;
                best[minx].x=x;
                best[minx].v=v;
                cnt++;
            }
            else
            {
                minx=0;
                minv=best[0].v;
                for( int n=1; n<total; n++ )
                {
                    if( best[n].v<minv  )
                    {
                        minx=n;
                        minv=best[n].v;
                    }
                }
                best[minx].x=x;
                best[minx].v=v;
            }
            
            if( maxoppo>=PVALUE_EGY )
            {
                break;
            }
        }
    }
    //qsort(best,cnt,2*sizeof(int),cell::cmp_value);
    
    //printf("\n");
    //for(int i=0; i<cnt; i++ )
    //{
    //    printf(">(%d[%d,%d],%d)\n", best[i].x, 
    //                                best[i].x/TABLESIZE, best[i].x%TABLESIZE,  
    //                                best[i].v );
    //}
    

    // második menet: saját lépések

    for(int i=0; i<ROWCOL; i++)
    {
        int x=cell::spiral[i]; //középről kifelé
        int v;
        cell *c=cell::cells[x];

        if( (c->figure==' ') && ((v=c->fieldval[turn])>minv) )
        {
            if( maxoppo>=PVALUE_EGY && v<PVALUE_EGY )
            {
                continue;
            }
            else if( maxoppo>=PVALUE_KET2 && v<PVALUE_KET1 )
            {
                continue;
            }

            maxturn=max(v,maxturn);

            if( cnt<total  )
            {
                minx=cnt;
                best[minx].x=x;
                best[minx].v=v;
                cnt++;
            }
            else
            {
                minx=0;
                minv=best[0].v;
                for( int n=1; n<total; n++ )
                {
                    if( best[n].x==x )
                    {
                        // már benn van
                        minx=n;
                        break;
                    }
                    else if( best[n].v<minv  )
                    {
                        minx=n;
                        minv=best[n].v;
                    }
                }
                best[minx].x=x;
                best[minx].v=v;
            }

            if( maxturn>=PVALUE_EGY )
            {
                break;
            }
        }
    }
    qsort(best,cnt,2*sizeof(int),cell::cmp_value);

    //printf("\n");
    //for(int i=0; i<cnt; i++ )
    //{
    //    printf("<(%d[%d,%d],%d)\n", best[i].x, 
    //                                best[i].x/TABLESIZE, best[i].x%TABLESIZE,  
    //                                best[i].v );
    //}


    cell::best_move[0]=0;
    cell::best_move[1]=0;
    cell::second_move[0]=0;
    cell::second_move[1]=0;
    int flag=best[0].v>=PVALUE_EGY;
    for( int n=0; n<cnt; n++ )
    {
        if( flag && best[n].v<PVALUE_EGY )
        {
            cnt=n;
            break;
        }
        cell::store_best(best[n].x);
        number(best[n].x);
    }
    array(cnt);
    _rettop();

    CCC_EPILOG();
}

//--------------------------------------------------------------------------
