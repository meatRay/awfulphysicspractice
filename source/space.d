module ships.space;

import ships.parts;

import derelict.sdl2.sdl;
import derelict.sdl2.types;
import derelict.sdl2.image;

import dchip.all;

import gl3n.linalg;

import std.container;
import std.algorithm;

import core.thread;

public alias RenderContext = SDL_Renderer*;

class Renderer
{
public:
	Space space;
	bool running;
	double updaterate = 0.016;

	this()
	{
		DerelictSDL2.load();
		if( SDL_Init(SDL_INIT_VIDEO) )
			throw new Exception("SDL Failed to Initialize.");

		_window = SDL_CreateWindow("SHIPS", 100, 100, 640, 480, SDL_WINDOW_SHOWN);
		if( _window is null )
			throw new Exception("SDL Failed to Create a Window.");

		_render = SDL_CreateRenderer( _window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		if( _render is null )
			throw new Exception("SDL Failed to Create a Renderer.");

		DerelictSDL2Image.load();
		if( !( IMG_Init( IMG_INIT_PNG ) & IMG_INIT_PNG ) )
			throw new Exception( "SDL_image could not initialize! SDL_image Error: %s\n" );

		scope( failure )
			destroy( this );

		running = true;
	}

	void begin()
	{
		space.begin(_render);
		auto delaytime = dur!"msecs"(cast(long)(updaterate*1000));
		SDL_Event event;
		while( running )
		{
			while( SDL_PollEvent(&event) )
			{
				switch( event.type )
				{
					case SDL_QUIT:
						running = false;
						break;
					default: break;
				}
			}
			draw();
			update();
			core.thread.Thread.sleep(delaytime);
		}
	}

private:
	SDL_Window* _window;
	SDL_Renderer* _render;

	void update()
	{
		if( space !is null )
			space.update(updaterate);
	}

	void draw()
	{
		SDL_SetRenderDrawColor( _render, 0, 0, 0, 255 );
		SDL_RenderClear(_render);
		space.draw(_render);
		SDL_RenderPresent(_render);
	}

	~this()
	{
		if( _render !is null )
			SDL_DestroyRenderer(_render);
		if( _window !is null )
			SDL_DestroyWindow(_window);
		IMG_Quit();
		SDL_Quit();
	}
}

abstract class Render
{
public:
	abstract void draw(SDL_Renderer* render, int x, int y, double angle, vec2i centre, int r_x, int r_y);
	abstract void load(SDL_Renderer* renderer);
}
class TexRender : Render
{
public:
	@property string filepath(){ return _filepath; }

	this(string path)
	{
		_filepath = path;
	}

	override void load(SDL_Renderer* render)
	{
		import std.string: toStringz;
		SDL_Surface* loadedSurface = IMG_Load( toStringz(_filepath) );
		if( loadedSurface is null )
			throw new Exception( "Unable to load image %s! SDL_image Error: %s\n" );
		else
		{
			//Create texture from surface pixels
			_tex = SDL_CreateTextureFromSurface( render, loadedSurface );
			if( _tex is null )
				throw new Exception( "Unable to create texture from %s! SDL Error: %s\n" );

			//Get rid of old loaded surface
			SDL_FreeSurface( loadedSurface );
		}
	}

	override void draw(SDL_Renderer* render, int x, int y, double angle, vec2i centre, int r_x, int r_y)
	{
		auto rect = SDL_Rect(x,y,32,32);
		SDL_Rect* othr = null;
		//SDL_Point ayy = SDL_Point(x-(centre.x*32),y-(centre.y*32));
		//SDL_Point ayy = SDL_Point(x+(centre.x*32),y+(centre.y*32));
		SDL_Point ayy = SDL_Point(16-x + r_x,16-y + r_y);
		SDL_RenderCopyEx(render,
			_tex,
			othr,
			&rect,
			-angle,
			&ayy,
			SDL_FLIP_NONE );
	}

private:
	SDL_Texture* _tex;
	string _filepath;
}
class BlankRender : Render
{
public:
	byte r, g, b;
	this()
	{
		this(cast(byte)255,cast(byte)255,cast(byte)255);
	}
	this( byte r, byte g, byte b )
	{
		this.r = r;
		this.g = g;
		this.b = b;
	}

	override void load(SDL_Renderer* render)
	{}
	override void draw(SDL_Renderer* render, int x, int y, double angle, vec2i centre, int r_x, int r_y)
	{
		auto rect = SDL_Rect(x,y,32,32);
		SDL_SetRenderDrawColor( render, r, g, b, 255 );
		SDL_RenderFillRect( render, &rect );
	}
}

class Space
{
public:
	SList!Chunk objects;
	this() 
	{
		_space = cpSpaceNew();
		cpSpaceSetGravity(_space, cpv(0f, 9.8f));
	}

	void begin(SDL_Renderer* render)
	{
		cpShape* ground = cpSegmentShapeNew(_space.staticBody, cpv(-10, 6), cpv(10, 11), 0);
		cpShapeSetFriction(ground, 0.5);
		cpShapeSetElasticity(ground, 0.5f);
		cpSpaceAddShape(_space, ground);
		/+I failed my LINQfu... please  forgive me+/
		foreach( chunk; objects )
		{
			for( int y = 0; y < chunk.tiles.length; ++y )
				for( int x = 0; x < chunk.tiles[y].length; ++x )
				{
					auto tile = chunk.tiles[y][x];
					if( tile !is null )
					{
						tile.physicsInit(chunk.physics, x-chunk.centre.x,y-chunk.centre.y);
						tile.render.load(render);
						cpSpaceAddShape(_space, tile.shape);
						
						/+foreach( pin; tile.pins )
							if( pin !is null )
								if( cpConstraintGetSpace(pin) is null )
									cpSpaceAddConstraint(_space, pin);
						foreach( pin; tile.locks )
							if( pin !is null )
								if( cpConstraintGetSpace(pin) is null )
									cpSpaceAddConstraint(_space, pin);+/
					}
				}
			chunk.begin();
			cpSpaceAddBody(_space, chunk.physics);
		}
	}

	void update( float delta_time )
	{
		cpSpaceStep(_space, delta_time);
		foreach( object; objects )
			object.update(delta_time);
	}

	void draw(SDL_Renderer* render)
	{
		foreach( chunk; objects )
			chunk.draw(render);
	}

private:
	cpSpace* _space;
}