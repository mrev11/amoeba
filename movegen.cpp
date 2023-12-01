
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

    int turn=cell::movecount&1; // 0=X, 1=O
    int oppo=turn?0:1;

    int cnt=0;
    int minx=0;
    int minv=-1;
    int maxv=-1;

    // első menet: az ellenfél lépései

    for(int i=0; i<ROWCOL; i++)
    {
        int x=cell::spiral[i]; //középről kifelé
        int v;
        cell *c=cell::cells[x];

        if( (c->figure==' ') && ((v=c->fieldval[oppo])>minv) )
        {
            maxv=max(v,maxv);

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
        }
    }

    // második menet: saját lépések

    int maxoppo=maxv;

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
            else if( maxoppo>=PVALUE_KET2 && v<PVALUE_KET2 )
            {
                continue;
            }

            maxv=max(v,maxv);

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
        }
    }

    qsort(best,cnt,2*sizeof(int),cell::cmp_value);

    cell::best_move[0]=0;
    cell::best_move[1]=0;
    cell::second_move[0]=0;
    cell::second_move[1]=0;

    for( int n=0; n<cnt; n++ )
    {
        cell *c=cell::cells[best[n].x];
        cell::store_best(c);
        number( c->count );
    }

    array(cnt);
    _rettop();

    CCC_EPILOG();
}

//--------------------------------------------------------------------------
