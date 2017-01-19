module ships.scripting.livescript;

import ships.scripting.script;
import ships.parts.tiles.tile;

class LiveScript : Script
{
public:
    override Packet endpoint()
    {
        loadWorkspace();
        lua.doString( script );
        return lua["endpoint"].to!Packet;
    }

    this( Tile instance )
    {
        super(instance);
    }
}