module ships.parts.tiles.target;

import ships.parts.tiles;
import ships.space;

class Target : Tile
{
public:
	this()
	{
		super('T');
		/+auto bsc = cast(BlankRender)this.render;
		bsc.b = 0;
		bsc.g = 0;+/
	}

	override Packet hardpoint()
	{
		return _hardpoint;
	}
}