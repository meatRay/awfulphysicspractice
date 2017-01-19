import ships.space;
import ships.parts;
import ships.parts.tiles;

import std.stdio;

void main()
{
	/+auto sensor = new LiveScript( tile );
    sensor.script = `
    endpoint["rslt"] = "FALSE"
    if tonumber(instance["prox"]) > 10 then 
        endpoint["rslt"] = "TRUE"
        fire()
    end`;

    tile.scripts = [ sensor ];+/


	auto tiles = [ 
cast(Tile[])[ new Thrust, null, new Thrust ] ,
[ new Tile('#'), new Tile('#'), new Tile('#') ],
[ new Tile('#'), new Gyro, new Tile('#') ],
[ null, new Tile('#'), null ],
[ new Tile('#'), new Command, new Tile('#') ]];
	auto ch = new Chunk( tiles );
	writeln( ch.textRender() );

    auto wndw = new Renderer;
    wndw.space = new Space;
    wndw.space.objects.insert(ch);
    wndw.begin();
}
