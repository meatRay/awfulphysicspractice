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
    this( Tile instance, string script_text, double delay_time )
    {
        super(instance, script_text);
        delaytime = delay_time;
    }
    void update( double delta_time )
    {
        /+ Allocating new workspaces each execute will be expensive... 
         + Could try clearing them out.. or just dont delete them between updates? 
         + Investigate memory for having 200 open lua spaces lol +/
        if( (_delayedtime+=delta_time) > delaytime )
        {
            foreach( ref delay; _delays )
                delay -= _delayedtime;
            _delayedtime -= delaytime;
            /+Keep a local lua workspace execute environment?+/
            //lua.execute();
            if( lua !is null )
            {
                loadWorkspace();
                script();
                auto rslt = lua["endpoint"];
                if( !rslt.isNil )
                    _endpoint = rslt.to!Packet;
            }
        }
    }
protected:
    override void loadWorkspace(bool from_scratch = false)
    {
        super.loadWorkspace(from_scratch);
        if( from_scratch )
        {
            lua["Delay"] = &scriptDelay;
            lua["ResetDelay"] = &scriptReset;
            lua["DelayN"] = &scriptDelayFor;
            lua["ResetDelayN"] = &scriptResetFor;
        }
    }

private:
    double _delayedtime = 0.0;
    Packet _endpoint;

    double[string] _delays;
    void scriptReset()
    {
        _delays.remove("default");
    }
    void scriptResetFor(string name)
    {
        _delays.remove(name);
    }
    bool scriptDelay(double time)
    {
        return scriptDelayFor(time, "default");
    }
    bool scriptDelayFor(double time, string name)
    {
        double* rm = name in _delays;
        if( rm is null )
            _delays[name] = time;
        else
            return _delays[name] <= 0.0;
        return false;
    }
}
