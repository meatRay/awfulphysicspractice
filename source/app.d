import ships.space;
import ships.parts;
import ships.parts.tiles;
import ships.scripting;

import gl3n.linalg;

import std.math;

//import std.stdio;

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

    auto thr1 = new Thrust;
    auto mover1 = new TimedScript(thr1, `
if Delay( 1.0 ) then
    ThrustScale( 0.0 )
    ResetDelay()
else
    ThrustScale( 1.0 );
end`, 0.1);
    thr1.scripts = [mover1];
    thr1.timedScripts = [mover1];

    auto gyr = new Gyro;
    auto mover2 = new TimedScript(gyr, `
if Delay(1.0) then
    Spin(0.0)
    ResetDelay()
else
    Spin(-0.25)
end`, 0.1);
    gyr.scripts = [mover2];
    gyr.timedScripts = [mover2];

	auto tiles = [ 
[thr1      , new Tile('#'), new Tile('#'), null         , new Tile('#')],
[null      , gyr          , new Tile('#'), new Tile('#'), new Command  ],
[new Thrust, new Tile('#'), new Tile('#'), null         , new Tile('#')]];
	auto ch = new Chunk( tiles, vec2d(2, 2.0), PI_4 );
	//writeln( ch.textRender() );

	auto tiles2 = [ 
[new Thrust, new Tile('#'), new Tile('#'), null         , new Tile('#')],
[null      , new Tile('#'), new Gyro     , new Tile('#'), new Command  ],
[new Thrust, new Tile('#'), new Tile('#'), null         , new Tile('#')]];
	auto ch2 = new Chunk( tiles2, vec2d(9.0, 4.0), PI_2 );

    auto wndw = new Renderer;
    wndw.space = new Space;
    wndw.space.objects.insert(ch);
    wndw.space.objects.insert(ch2);
    wndw.begin();
}
