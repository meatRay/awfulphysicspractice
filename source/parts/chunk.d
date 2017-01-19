module ships.parts.chunk;

import ships.parts.tiles;
import ships.space;

import gl3n.linalg;

import std.array;
import std.container;
import std.conv;
import std.algorithm;

class Chunk
{
public:
	@property const(Tile[][]) tiles(){ return _tiles; }
	@property bool functional(){ return _functional; }
	vec2d position;
	double rotation = 0.0;
	double speed = 0.0;
	double targetspeed = 10;
	
	//Replace hard props with alias into Body access
	//Chunk managed bounding boxes -- relays impact to data .. allows for event handlers to refresh state of systems
	//If physics supports callbacks... impl instead
	/+PhysicsBody+/
	
	vec2i centre;
	@property const(vec2i[]) gyros(){ return _gyros; }
	@property const(vec2i[]) thrusts(){ return _thrusts; }
	@property const(vec2i[]) commands(){ return _commands; }
	
	this( Tile[][] tiles, vec2d position, vec2i centre )
	{
		_tiles = tiles;
		SList!vec2i fnd_gy;
		SList!vec2i fnd_th;
		SList!vec2i fnd_cm;
		for( int y = 0; y < tiles.length; ++y )
			for( int x = 0; x < tiles[y].length; ++x )
			{
				if( cast(Gyro)tiles[y][x] )
					fnd_gy.insert( vec2i(x,y) );
				else if( cast(Thrust)tiles[y][x] )
					fnd_th.insert( vec2i(x,y) );
				else if( cast(Command)tiles[y][x] )
					fnd_cm.insert( vec2i(x,y) );
			}
		_gyros = array( fnd_gy[] );
		_thrusts = array( fnd_th[] );
		_commands = array( fnd_cm[] );
		this.position = position;
		this.centre = centre;

		_functional = true;
	}
	this( Tile[][] tiles, vec2d position = vec2d(0,0) )
		//:this( tiles, position, estimateCentre(tiles) )
	{
		vec2i estimate = vec2i( tiles[0].length / 2, tiles.length / 2 );
		this( tiles, position, estimate );
	}

	void draw(RenderContext render)
	{
		for( int y = 0; y < _tiles.length; ++y )
			for( int x = 0; x < _tiles[y].length; ++x )
				if( _tiles[y][x] !is null )
					_tiles[y][x].render.draw(render, x*64, y*64);
		//foreach( chunk; objects )
			//chunk.draw(render);
	}
	
	void update( float delta_time )
	{
		speed += thrusts.map!(t => (cast(Thrust)(tileAt(t))).thrust).sum;
		
		// Really might not be worth it... caching will just make stuff feel slow
		if( _internalsTime += delta_time > internalsLifetime )
			updateInternals();	
		if( functional )
		{
			foreach( thruster; thrusts.map!( t => (cast(Thrust)(tileAt(t)))) )
				thruster.thrust =(speed < targetspeed) ? thruster.maxThrust : 0.0;
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