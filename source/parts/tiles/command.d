module ships.parts.tiles.command;

import ships.parts.tiles;
import ships.space;

class Command : Tile
{
public:
	this()
	{
		super('C');
		auto bsc = cast(BlankRender)this.render;
		bsc.b = 0;
		bsc.g = 0;
	}
}