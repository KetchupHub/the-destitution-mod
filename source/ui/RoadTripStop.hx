package ui;

import backend.ClientPrefs;
import visuals.PixelPerfectSprite;

class RoadTripStop extends PixelPerfectSprite
{
  public var songName:String;

  public var hovered(default, set):Bool = false;

  public function new(x:Float = 0, y:Float = 0, song:String)
  {
    super(x, y);

    songName = song;

    frames = Paths.getSparrowAtlas('story/stop');

    animation.addByPrefix('idle', 'stop idle', 24, true);
    animation.addByPrefix('hovered', 'stop hovered', 24, true);

    animation.play('idle', true);

    antialiasing = ClientPrefs.globalAntialiasing;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
  }

  public function set_hovered(value:Bool):Bool
  {
    if (value)
    {
      if (animation.curAnim.name != 'hovered' && animation.curAnim.name != 'hovered')
      {
        animation.play('hovered', true);
        //offset.set(-119, -131);
        centerOrigin();
      }
    }
    else if (animation.curAnim.name != 'idle' && animation.curAnim.name != 'idle')
    {
      animation.play("idle", true);
      //offset.set(0, 0);
    }

    return value;
  }
}