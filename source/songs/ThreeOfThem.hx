package songs;

import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Three of Them's song class.
 */
class ThreeOfThem extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Three of Them';
        this.songHasSections = false;
        this.introType = 'Mark';
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
            case 80:
                //retro cynda beats
                PlayState.instance.epicCyndaBeats(false);
                FlxG.camera.flash();
            case 144:
                //no more retro cynda beats
                PlayState.instance.epicCyndaBeats(true);
                PlayState.instance.dad.canDance = false;
                PlayState.instance.dad.canSing = false;
                PlayState.instance.dad.playAnim('talk', true);
                FlxG.camera.flash();
            case 184:
                FlxG.camera.flash();
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
            case 320:
                //nyans
                var newFlxSpriteForAges:FlxSprite = new FlxSprite().loadGraphic(Paths.image('april/naysn'));
                newFlxSpriteForAges.scrollFactor.set(0, 0);
                newFlxSpriteForAges.cameras = [PlayState.instance.camHUD];
                PlayState.instance.add(newFlxSpriteForAges);
        }
    }
}