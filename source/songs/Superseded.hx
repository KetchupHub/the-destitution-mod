package songs;

import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;

/**
 * Superseded's song class.
 */
class Superseded extends SongClass
{
	public override function new()
    {
        super();
    }

    public override function stepHitEvent(curStep:Float)
    {
        //this is where step hit events go
        super.stepHitEvent(curStep);
    }
    
    public override function beatHitEvent(curBeat:Float)
    {
        //this is where beat hit events go
        super.beatHitEvent(curBeat);

        switch(curBeat)
        {
            case 28:
                PlayState.instance.supersededIntro.animation.play("open", true);
            case 29:
                PlayState.instance.defaultCamZoom += 15;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.crochet / 500, {ease: FlxEase.quadInOut});
                FlxTween.tween(PlayState.instance.supersededIntro, {y: PlayState.instance.supersededIntro.y - 75}, Conductor.crochet / 500, {ease: FlxEase.quadInOut});
            case 31:
                PlayState.instance.supersededIntro.y += 75;
                PlayState.instance.supersededIntro.visible = false;
                PlayState.instance.defaultCamZoom -= 15.1;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.crochet / 1000, {ease: FlxEase.circOut});
            case 32:
                PlayState.instance.tweeningCam = false;
        }
    }
}