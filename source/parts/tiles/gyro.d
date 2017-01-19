module ships.parts.tiles.gyro;

import ships.parts.tiles;
import ships.space;

class Gyro : Tile
{
public:
	this()
	{
		super('@');
		auto bsc = cast(BlankRender)this.render;
		bsc.r = 0;
		bsc.b = 0;
	}
}