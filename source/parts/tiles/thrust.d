module ships.parts.tiles.thrust;

import ships.parts.tiles;
import ships.space;

import dchip.all;
import luad.state;

class Thrust : Tile
{
public:
	double maxThrust = 0.1;
	cpVect thrustDir = cpVect(0f,1f);
	
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
		auto bsc = cast(BlankRender)this.render;
		bsc.r = 0;
		bsc.g = 0;
	}
	
    override void regLuaCalls( LuaState lua )
    {
        lua["thrustscale"] = &thrustScale;
    }

	override void update( double delta_time )
	{
		super.update(delta_time);
		float ang = cpBodyGetAngle(physics);
		cpBodySetAngle(physics, ang+0.1);
		auto rot = /+thrustDir+/cpBodyGetRot( physics ) * thrust; 
		cpBodyApplyImpulse( physics, rot, cpVect(0f,0f));
	}

private:
	double _atThrust = 0.0;
	/+double _atScale;+/
}