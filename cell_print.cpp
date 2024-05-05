
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

    xPATTERN *p=c->pattern+c->layer;

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
    xPATTERN *p=c->pattern+c->layer;

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
    xPATTERN *p=c->pattern+c->layer;

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
        xPATTERN *p=pattern+layer;
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
void _clp_print_cell_pattern(int argno)
{
    CCC_PROLOG("print_cell_pattern",1);
    int x=_parni(1);

    cell *c=cell::cells[x];

    if( c->figure==' ' )
    {
        printf(" %c",'a'+c->row);
        printf("%-2d ",1+c->col);
        printf("%s",ppat(c));

        const char *vo=numformat("%4d",c->fieldval[c->layer].white);
        const char *vx=numformat("%4d",c->fieldval[c->layer].black);
        const char *vs=numformat("%3d",c->fieldval[c->layer].black+c->fieldval[c->layer].white);

        int force=' ';
        if( (cell::movecount&1)==1 && cell::movegen_white==0 && c->fieldval[c->layer].white>=PVALUE_KET1)
        {
            force='+';
        }
        if( (cell::movecount&1)==0 && cell::movegen_black==0 && c->fieldval[c->layer].black>=PVALUE_KET1)
        {
            force='+';
        }

        printf(" %4s %4s [%3s]%c",vo,vx,vs,force);
        printf("\n");
        fflush(0);
    }
    _ret();
    CCC_EPILOG();
}

//----------------------------------------------------------------------------------------
void _clp_print_posvalue(int argno)
{
    CCC_PROLOG("print_posvalue",0);

    printf( "turn:%c ",cell::movecount&1?'O':'X');
    printf( "posvalue=%d\n",cell::posvalue() );
    fflush(0);
    _ret();
    CCC_EPILOG();
}


//----------------------------------------------------------------------------------------




