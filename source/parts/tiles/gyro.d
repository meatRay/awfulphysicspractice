module ships.parts.tiles.gyro;

import ships.parts.tiles;
import ships.space;

import luad.state;

import dchip.all;

import std.math;

class Gyro : Tile
{
public:
	double maxTorque = PI_4;
	@property double torque(){ return functional ? _torque : 0.0; }

	@property double torqueScale(double scale)
	{
		if( scale > 1 )
			scale = 1;
		_torque = maxTorque * scale;
		return scale;
	}

	this()
	{
		super('@');
		/+auto bsc = cast(BlankRender)this.render;
		bsc.r = 0;
		bsc.b = 0;+/
	}

	override void update(double delta_time)
	{
		super.update(delta_time);
		//torque = ;
		/+float ang = cpvtoangle(cpBodyGetRot(physics)) +0.001;
		import std.stdio: writeln;
		writeln(ang);
		cpBodySetAngle(physics, ang);+/
	}

	override void regLuaCalls( LuaState lua )
    {
        lua["Spin"] = &scriptSpin;
    }

private:
	double _torque = 0.0;
	void scriptSpin( double torque )
	{
		torqueScale(torque);
	}
}