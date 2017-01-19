module ships.space;

import ships.parts;

import derelict.sdl2.sdl;
import derelict.sdl2.types;

import std.container;

import core.thread;

public alias RenderContext = SDL_Renderer*;

class Renderer
{
public:
	Space space;
	bool running;
	double updaterate = 0.16;

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

		scope( failure )
			destroy( this );

		running = true;
	}

	void begin()
	{
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
			Thread.sleep(delaytime);
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
		SDL_Quit();
	}
}

abstract class Render
{
public:
	abstract void draw(SDL_Renderer* renderer, int x, int y);
}
class BlankRender : Render
{
public:
	override void draw(SDL_Renderer* render, int x, int y)
	{
		auto rect = SDL_Rect(x,y,64,64);
		SDL_SetRenderDrawColor( render, 0, 0, 255, 255 );
		SDL_RenderFillRect( render, &rect );
	}
}

class Space
{
public:
	SList!Chunk objects;
	this() {}
	
	void update( float delta_time )
	{
		foreach( object; objects )
			object.update(delta_time);
	}

	void draw(SDL_Renderer* render)
	{
		foreach( chunk; objects )
			chunk.draw(render);
	}
}