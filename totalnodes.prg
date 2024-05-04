

******************************************************************************************
function total_nodes(n)

static nodes_white:=0
static nodes_black:=0

local nodes,sec


    if( n!=NIL )
        if( turn_x() )
            nodes_black+=n
        end
        if( turn_o() )
            nodes_white+=n
        end

    else
        nodes:=nodes_white+nodes_black
        ? "TOTAL_NODES="+numstr(nodes)
        ?? "  white="+numstr(nodes_white)
        ?? "  black="+numstr(nodes_black)

        sec:=process_utime()
        if( sec>0 )
            ?? "  time="+timestr(sec)
            ?? "  "+numstr(nodes/sec)+"/s"
        end
    end

    return nodes_white+nodes_black


******************************************************************************************
static function numstr(num)
    return transform(num,"999,999,999,999")::alltrim


******************************************************************************************
static function timestr(sec)
local s:=sec%60
local m:=(sec-s)/60
    return m::str::alltrim+"m"+s::str::alltrim+"s"


******************************************************************************************

