
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


double tabcolor(int x)
{
    static double color[3]={0.77,0.66,0.22};
    static int init=0;
    if( !init )
    {
        init=1;
        const char *env=getenv("AMOEBA_COLOR");
        if( env && *env )
        {
            int r,g,b;
            if( 3==sscanf(env,"%d,%d,%d",&r,&g,&b) )
            {
                if( 0<=r && r<=100 )
                {
                    color[0]=r/100.0;
                }
                if( 0<=g && g<=100 )
                {
                    color[1]=g/100.0;
                }
                if( 0<=b && b<=100 )
                {
                    color[2]=b/100.0;
                }
            }
        }
    }
    return color[x];
}


