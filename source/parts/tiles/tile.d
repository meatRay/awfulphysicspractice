module ships.parts.tiles.tile;

import ships.scripting;

import luad.state;

class Tile
{
public:
	Script[] scripts;
    TimedScript[] timedScripts;
	char character;
	bool enabled;
	
	@property int durability(){ return _durability; }
	@property int strength(){ return _durability - _damage; }
	@property int damageThreshold(){ return _damageThreshold; }
	@property bool destroyed(){ return _damage < _durability; }
	@property bool functional(){ return _damage < _damageThreshold; }
	@property bool active(){ return functional && enabled; }
	
	this( char tile_char )
	{
		this( tile_char, 10, 5 );
	}

	this( char tile_char, int durability, int damage_threshold )
	{
		scripts = [];
        timedScripts = [];
		character = tile_char;
		_durability = durability;
		_damageThreshold = damage_threshold;		
	}

	void update( double delta_time )
    {
        foreach( script; timedScripts )
            script.update(delta_time); 
    }
    void regLuaCalls( LuaState lua )
    {
        lua["fire"] = &fire;
    }

private:
    void fire()
    {
        //writeln("BOOM");
    }

protected:
	public/+abstract+/ Packet hardpoint(){ return null; }
	
	public void damage( int damage )
	{
		_damage += damage;
		if( _damage > _durability )
			_damage = _durability;
		else if( _damage < 0 )
			_damage = 0;
		//Alter sprite / state
	}
	
private:
	int _damageThreshold;
	int _durability;
	int _damage;
	
	//override string toString(){ return to!string(character); }
}