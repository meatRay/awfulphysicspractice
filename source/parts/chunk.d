module ships.parts.chunk;

import ships.parts.tiles;
import ships.space;

import gl3n.linalg;

import dchip.all;

import std.array;
import std.container;
import std.conv;
import std.algorithm;

class Chunk
{
public:
	/+Find a way to return a Range from an Array..+/
	@property Tile[][] tiles(){ return _tiles; }
	@property bool functional(){ return _functional; }
	@property cpVect position()
	{
		return cpBodyGetPos(physics);
	}
	double rotation = 0.0;
	@property cpVect velocity()
	{
		return cpBodyGetVel(physics);
	}
	double targetspeed = 0.0;

	cpBody* physics;
	
	void begin()
	{
		foreach( tilech ; tiles )
			foreach( tile ; tilech )
				if( tile !is null )
					cpBodyAddShape(physics, tile.shape);
	}
	
	//Replace hard props with alias into Body access
	//Chunk managed bounding boxes -- relays impact to data .. allows for event handlers to refresh state of systems
	//If physics supports callbacks... impl instead
	/+PhysicsBody+/
	
	vec2i centre;
	@property const(vec2i[]) gyros(){ return _gyros; }
	@property const(vec2i[]) thrusts(){ return _thrusts; }
	@property const(vec2i[]) commands(){ return _commands; }
	
	static vec2i numtodir( int num )
	{
		if( num == 0 ) 
			return vec2i(1,0);
		else if( num == 1 ) 
			return vec2i(0,1);
		else if( num == 2 ) 
			return vec2i(-1,0);
		else
			return vec2i(0,-1);
	}
	static int dirtonum( vec2i dir )
	{
		if( dir == vec2i(1,0) ) 
			return 0;
		else if( dir == vec2i(0,1) )
			return 1;
		else if( dir == vec2i(-1,0) )
			return 2;
		else
			return 3;
	}

	this( Tile[][] tiles, vec2d position, double rotation, vec2i centre )
	{
		_tiles = tiles;
		SList!vec2i fnd_gy;
		SList!vec2i fnd_th;
		SList!vec2i fnd_cm;
		for( int y = 0; y < tiles.length; ++y )
			for( int x = 0; x < tiles[y].length; ++x )
			{
				if( tiles[y][x] is null )
					continue;

				if( cast(Gyro)tiles[y][x] )
					fnd_gy.insert( vec2i(x,y) );
				else if( cast(Thrust)tiles[y][x] )
					fnd_th.insert( vec2i(x,y) );
				else if( cast(Command)tiles[y][x] )
					fnd_cm.insert( vec2i(x,y) );
			}
		//auto moment = cpMomentForBox(/+tiles.map!"a.length".sum+/100, tiles.length, tiles[0].length );
		physics = cpBodyNew( 100, 0.1f );
		cpBodySetPos( physics, cpv(position.x, position.y) );
		cpBodySetAngle( physics, rotation );
		_gyros = array( fnd_gy[] );
		_thrusts = array( fnd_th[] );
		_commands = array( fnd_cm[] );
		//this.position = cpVect(position.x,position.y);
		this.centre = centre;
		double c_x = to!double(_gyros.map!"a.x".sum) / _gyros.length;
		double c_y = to!double(_gyros.map!"a.y".sum) / _gyros.length;
		this.centre = vec2i( to!int(c_x), to!int(c_y) );
		_functional = true;
	}
	this( Tile[][] tiles, vec2d position = vec2d(0,0), double rotation = 0.0 )
		//:this( tiles, position, estimateCentre(tiles) )
	{
		vec2i estimate = vec2i( tiles[0].length / 2, tiles.length / 2 );
		this( tiles, position, rotation, estimate );
	}

	void draw(RenderContext render)
	{
		for( int y = 0; y < _tiles.length; ++y )
			for( int x = 0; x < _tiles[y].length; ++x )
				if( _tiles[y][x] !is null )
				{
					Tile tile = _tiles[y][x];
					double ang = cpBodyGetAngle(physics) * 57.2958;
					int d_x = (x-centre.x)*32;
					d_x += to!int(physics.p.x*32);
					int d_y = (y-centre.y)*32;
					d_y += to!int(physics.p.y*32);
					tile.render.draw(render, d_x, d_y, ang, centre, to!int(physics.p.x*32), to!int(physics.p.y*32) );
					//_tiles[y][x].render.draw(render, (x*32) + to!int(position.x), (y*32) + to!int(position.y));
				}
		//foreach( chunk; objects )
			//chunk.draw(render);
	}
	double accum = 0.0;
	void update( cpSpace* space, double delta_time )
	{
		accum +=delta_time;
		auto speed = thrusts.map!(t => (cast(Thrust)(tileAt(t))).thrust).sum;
		/+auto cmd = tileAt(commands[0]).physics;+/
		auto rot = cpBodyGetRot(physics) * speed;
		cpBodyApplyImpulse( physics, rot, cpVect(0f,0f));

		auto ang = cpBodyGetAngle(physics);
		auto tor = gyros.map!(g => (cast(Gyro)(tileAt(g))).torque).sum;
		cpBodySetAngVel(physics, tor);

		// Really might not be worth it... caching will just make stuff feel slow
		if( _internalsTime += delta_time > internalsLifetime )
			updateInternals();	
		if( functional )
		{
			for( int y = 0; y < _tiles.length; ++y )
				for( int x = 0; x < _tiles[0].length; ++x )
				{
					auto tile = tileAt(x,y);
					if( tile is null )
						continue;

					tile.update(delta_time);
					if( tile.destroyed )
					{
						cpSpaceRemoveShape(space, tile.shape);
						cpShapeFree(tile.shape);
						if( cast(Thrust)tile )
							_thrusts = array( _thrusts.filter!(g => g != vec2i(x,y)) );
						if( cast(Gyro)tile )
							_gyros = array( _gyros.filter!(g => g != vec2i(x,y)) );
						if( cast(Command)tile )
							_commands = array( _commands.filter!(g => g != vec2i(x,y)) );

						tiles[y][x] = null;
					}
					/+auto asthr = cast(Thrust)tile;
					if( asthr )
						asthr.thrust =(velocity.y < targetspeed) ? asthr.maxThrust : 0.0;+/
				}/+
			foreach( thruster; thrusts.map!( t => (cast(Thrust)(tileAt(t)))) )
				thruster.thrust =(velocity.y < targetspeed) ? thruster.maxThrust : 0.0;+/
		}
	}
	void updateInternals()
	{
		_functional = filter!(a => tileAt(a).active)(_commands).any;
	}
	
	Tile tileAt( vec2i position )
	{
		return tileAt( position.x, position.y );
	}
	Tile tileAt( int x, int y )
	{
		return _tiles[y][x];
	}
	
	string textRender()
	{
		int tx_ln = _tiles.map!"a.length + 1".sum;
		auto tx_raw = new char[tx_ln];
		int at = 0;
		for( int i = 0; i < _tiles.length; ++i )
		{
			foreach( tile; _tiles[i] )
				tx_raw[at++] = tile is null ? ' ' : tile.character;
			tx_raw[at++] = '\n';
		}
		
		return to!string( tx_raw );
	}
private:
	const float internalsLifetime = 1f;

	Tile[][] _tiles;
	vec2i[] _gyros;
	vec2i[] _thrusts;
	vec2i[] _commands;
	float _internalsTime = 0.0f;
	bool _functional;
}