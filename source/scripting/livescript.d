module ships.scripting.livescript;

import ships.scripting.script;
import ships.parts.tiles.tile;

class LiveScript : Script
{
public:
    override Packet endpoint()
    {
        loadWorkspace();
        script();
        return lua["endpoint"].to!Packet;
    }

    this( Tile instance, string script_text )
    {
        super(instance, script_text);
    }
}