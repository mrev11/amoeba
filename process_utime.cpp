

#ifdef WINDOWS

#include <windows.h>
#include <cccapi.h>

void _clp_process_utime(int argno)
{
    stack-=argno;
    int sec=0;
    FILETIME cre,ext,ker,usr;
    if( GetProcessTimes(GetCurrentProcess(),&cre,&ext,&ker,&usr) )
    {
	SYSTEMTIME st;
	FileTimeToSystemTime(&usr,&st);
	sec=st.wHour;
	sec=sec*60+st.wMinute;
	sec=sec*60+st.wSecond;
    }
    number(sec);
}


#else

#include <sys/resource.h>
#include <sys/time.h>
#include <cccapi.h>

void _clp_process_utime(int argno)
{
    stack-=argno;
    struct rusage usage;
    usage.ru_utime.tv_sec=0;
    int r=getrusage(RUSAGE_SELF,&usage); // success=0, error=-1 (errno)
    number(usage.ru_utime.tv_sec);
}

#endif