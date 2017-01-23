module ships.scripting.hardscript;

import ships.scripting.script;
import ships.parts.tiles.tile;

class HardScript : Script
{
public:
    override Packet endpoint()
    {
        loadWorkspace();
        script();
        return lua["endpoint"].to!Packet;
    }

    this( Tile instance )
    {
        super(instance, ``);
    }
}