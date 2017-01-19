module ships.scripting.script;

import ships.parts.tiles.tile;

import luad.all;

alias Packet = string[string];

class Script
{
public:
    bool hardwired;
    string instanceName;
    string luaName;
    Script[] inpoints;
    abstract Packet endpoint();
    string script;
protected:
    LuaState lua;
    Tile instance;

public:
    this( Tile instance )
    {
        this.instance = instance;
        lua = new LuaState();
        lua.openLibs();
        instance.regLuaCalls(lua);
    }
    string dothing()
    {
        lua.doString( script );
        return lua["endpoint"].to!string;
    }
protected:
    void loadWorkspace(bool from_scratch = false)
    {
        if( from_scratch )
        {
            lua = new LuaState;
            lua.openLibs();
            instance.regLuaCalls(lua);
        }
        foreach( point; inpoints )
            lua[point.instanceName] = point.endpoint();
        lua["instance"] = instance.hardpoint();
        Packet endpoint;
        lua["endpoint"] = endpoint;
    }
}