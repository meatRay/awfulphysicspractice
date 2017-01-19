module ships.scripting.timedscript;

import ships.scripting.script;
import ships.parts.tiles.tile;

class TimedScript : Script
{
public:
    double delaytime;
    @property override Packet endpoint()
        { return _endpoint; }

public:
    this( Tile instance )
    {
        super(instance);
    }
    void update( double delta_time )
    {
        /+ Allocating new workspaces each execute will be expensive... 
         + Could try clearing them out.. or just dont delete them between updates? 
         + Investigate memory for having 200 open lua spaces lol +/
        if( (_delayedtime+=delaytime) > delaytime )
        {
            _delayedtime -= delaytime;
            loadWorkspace();
            /+Keep a local lua workspace execute environment?+/
            //lua.execute();
            //_endpoint = lua["endpoint"];
        }
    }

private:
    double _delayedtime;
    Packet _endpoint;
}
