module ships.parts.tiles.gyro;

import ships.parts.tiles;
import ships.space;

import dchip.all;

class Gyro : Tile
{
public:
	double torque = 0.0;

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
}