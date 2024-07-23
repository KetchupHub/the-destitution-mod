package visuals;

import backend.ClientPrefs;
import util.CoolUtil;
import flixel.math.FlxMath;
import flixel.FlxSprite;

using StringTools;

class BucksGraphBar extends FlxSprite
{
    public var curPos:Int = 9;

    var targetPos:Int = 9;

	public function new(x:Float, y:Float)
    {
        super(x, y);
        frames = Paths.getSparrowAtlas('bucks/graph_bar');
        animation.addByPrefix('idle', 'graph bar', 0, false);
        animation.play('idle', true, false, 9);
        antialiasing = ClientPrefs.globalAntialiasing;
        alpha = 0.5;
    }

    public function changeGraphPos(newPos:Int)
    {
        targetPos = newPos;
    }

	override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(curPos != targetPos)
        {
            curPos = Std.int(FlxMath.lerp(targetPos, curPos, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1)));
            animation.play('idle', true, false, curPos);
        }
    }
}