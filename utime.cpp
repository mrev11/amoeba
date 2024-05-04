

#include <sys/resource.h>
#include <sys/time.h>
#include <cccapi.h>

void _clp_utime(int argno)
{
    stack-=argno;
    struct rusage usage;
    usage.ru_utime.tv_sec=0;
    int r=getrusage(RUSAGE_SELF,&usage); // success=0, error=-1 (errno)
    number(usage.ru_utime.tv_sec);
}