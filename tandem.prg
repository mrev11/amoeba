
#include "fileio.ch"

static fd_tandem:=tandem_init()

******************************************************************************************
static function tandem_init() 

local fd

    if( !empty(tandem_file()) )
        fd:=fopen(tandem_file(),FO_CREATE+FO_READWRITE)
        if( fd<0 )
            ? "ERROR cannot open ", tandem_file()
            ?
            quit
        end
    end
    return fd


******************************************************************************************
function tandem_file()
static dcfile:=getenv("AMOEBA_TANDEM")
    return dcfile


******************************************************************************************
function tandem_truncate()
    if( fd_tandem!=NIL )
        run( "truncate 2>/dev/null --size=0 "+tandem_file())
        ? "TRUNCATE", tandem_file(), len(memoread(tandem_file()))
    end


******************************************************************************************
function tandem_read()
local buf,cx,n

    if( fd_tandem!=NIL)

        drawall()
        ? "wait for lock";?

        while(.t.)
 
            buf:=replicate(bin(32),32)
            fwaitlock(fd_tandem,0,1,.t.)
            fseek(fd_tandem,0,FS_SET)
            fread(fd_tandem,@buf,32)
    
            if( empty(buf) )
                funlock(fd_tandem,0,1)
                ?? "empty";?
                exit
            end

            cx:=val(buf)
            ?? "read",pos2rc(cx)

            if( figure(cx)!=32 )
                ?? " still wait";?
                funlock(fd_tandem,0,1)
                sleep(2000)
            else
                if( topcell()!=NIL )
                    drawcell(topcell())
                end
                forw(cx)
                label_move()
                for n:=1 to 3
                    drawcell(cx)
                    sleep(200)
                    drawtop()
                    sleep(200)
                next
                exit
            end
        end
    end


******************************************************************************************
function tandem_write()
local cx
    if( fd_tandem!=NIL )
        cx:=topcell()
        ? "write",pos2rc(cx);?
        fseek(fd_tandem,0,FS_SET)
        fwrite(fd_tandem,str(cx))
        funlock(fd_tandem,0,1) // itt engedi ell
        return .t.
    end
    return .f.


******************************************************************************************
