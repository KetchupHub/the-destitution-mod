package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class FreeplaySongObject extends FlxSprite
{
    public var stinger:String = "destitution";

	public function new(x:Float, y:Float, song:String = '')
	{
		super(x, y);
        frames = Paths.getSparrowAtlas("destimodFreeplay");
        animation.addByPrefix(song.toLowerCase(), song.toLowerCase(), 24, true);
        animation.play(song.toLowerCase(), true);
        stinger = song.toLowerCase();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}