module ships.parts.tiles.thrust;

import ships.parts.tiles;
import ships.space;
import ships.scripting.script;

import dchip.all;

import luad.state;

import std.conv : to;

class Thrust : Tile
{
public:
	double maxThrust = 0.5;
	//cpVect thrustDir = cpVect(0f,1f);
	
	@property double thrust(){ return functional ? _atThrust : 0.0; }
	/+@property double thrustScale (){ return functional ? _atThrust : 0.0; }+/
	@property double thrust( double thrust )
	{
		if( thrust > maxThrust )
			_atThrust = maxThrust;
		else
			_atThrust = thrust;
		/+_atScale = maxThrust / _atThrust;+/
		return _atThrust;
	}
	@property double thrustScale()
	{
		//import std.stdio : writefln;
		//writefln("Thrust: %f, Max: %f, Value: %f", _atThrust, maxThrust, _atThrust / maxThrust);
		return _atThrust <= 0 ? 0.0 : _atThrust / maxThrust;
	}
	@property double thrustScale( double scale )
	{
		if( scale > 1 )
			scale = 1;
		_atThrust = maxThrust * scale;
		/+_atScale = scale;+/
		return scale;
	}
	//gimbal stats
	
	this()
	{
		super('T');
		/+auto bsc = cast(BlankRender)this.render;
		bsc.r = 0;
		bsc.g = 0;+/
	}
	
    override void regLuaCalls( LuaState lua )
    {
        lua["ThrustScale"] = &scriptSetThrust;
    }

	override void update( double delta_time )
	{
		super.update(delta_time);
	}

	override Packet hardpoint()
	{
		return["thrust":to!string(thrustScale)];
	}

private:
	void scriptSetThrust(double value)
	{
		thrustScale = value;
	}
	double _atThrust = 0.0;
	/+double _atScale;+/
}