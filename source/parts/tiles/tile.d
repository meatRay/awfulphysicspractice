module ships.parts.tiles.tile;

import ships.scripting;
import ships.space;

import dchip.all;

import luad.state;

import std.conv : to;

class Tile
{
public:
	//cpBody* physics;
	cpShape* shape;
	//cpConstraint*[4] pins;
	//cpConstraint*[4] locks;
	Render render;
	Script[] scripts;
    TimedScript[] timedScripts;
	char character;
	bool enabled;
	
	@property int durability(){ return _durability; }
	@property int strength(){ return _durability - _damage; }
	@property int damageThreshold(){ return _damageThreshold; }
	@property bool destroyed(){ return _damage >= _durability; }
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

		render = new TexRender("box.png");
	}

	void physicsInit(cpBody* physics, int x, int y)
	{
		//auto moment = cpMomentForBox(1, 1, 1 );
		//physics = cpBodyNew( 1, moment );
		auto bb = cpBB(x-0.5, y-0.5, x+0.5, y+0.5);
		shape = cpBoxShapeNew2(physics, bb);
		cpShapeSetFriction(shape, 0.5f);
		cpShapeSetElasticity(shape, 0.5f);
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
	Packet hardpoint(){ return null; }

private:
    void fire()
    {
        //writeln("BOOM");
    }

//protected:	
	public void damage( int damage )
	{
		_damage += damage;
		if( _damage > _durability )
			_damage = _durability;
		else if( _damage < 0 )
			_damage = 0;
		double hlth = to!double(strength) / to!double(_durability);

		TexRender rndr = cast(TexRender)render;

		rndr.b = cast(byte)(255.0 * hlth);
		rndr.g = cast(byte)(255.0 * hlth);
	}
	
private:
	int _damageThreshold;
	int _durability;
	int _damage;
	
	//override string toString(){ return to!string(character); }
}