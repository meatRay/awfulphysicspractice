import ships.space;
import ships.parts;
import ships.parts.tiles;
import ships.scripting;

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
    /*auto mover1 = new TimedScript(thr1, `
local thrust = tonumber(instance["thrust"])
do_run = true
if thrust <= 0.3 and do_run then
    ThrustScale( thrust+0.1 )
    do_run = false;
else
    ThrustScale( 0.0 );
end`, 0.1);
    thr1.scripts = [mover1];
    thr1.timedScripts = [mover1];*/

    auto thr2 = new Thrust;
    /+auto mover2 = new TimedScript(thr2, `
if Delay(3.0) then
    ThrustScale(100.0)
    ResetDelay()
end`, 0.1);
    thr2.scripts = [mover2];
    thr2.timedScripts = [mover2];+/

	auto tiles = [ 
[thr1, new Tile('#'), new Tile('#'), null         , new Tile('#')],
[null, new Tile('#'), new Gyro     , new Tile('#'), new Command  ],
[thr2, new Tile('#'), new Tile('#'), null         , new Tile('#')]];
	auto ch = new Chunk( tiles );
	//writeln( ch.textRender() );

    auto wndw = new Renderer;
    wndw.space = new Space;
    wndw.space.objects.insert(ch);
    wndw.begin();
}
