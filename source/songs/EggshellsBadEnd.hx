package songs;

import flixel.FlxG;
import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Eggshells' song class.
 */
class EggshellsBadEnd extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Eggshells (Bad Ending)';
        this.songHasSections = false;
        this.introType = 'Eggshells';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal"];
        //songVariants doesnt matter for the ending classes (since theyre just loaded in by force at the end of eggshells' dialogue)
        this.songDescription = "Well, that could've gone better.";
        this.ratingsType = "";
        this.skipCountdown = false;
        this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
        this.introCardBeat = 999999;
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

        /*switch (curBeat)
        {
            case 104 | 312:
                PlayState.instance.angelPulsing = true;
                PlayState.instance.angelPulseBeat = 1;
                FlxG.camera.flash();
            case 168:
                PlayState.instance.angelPulseBeat = 6;
            case 176:
                PlayState.instance.angelPulseBeat = 4;
                PlayState.instance.angelPulsing = false;
                FlxG.camera.flash();
            case 376:
                PlayState.instance.angelPulseBeat = 4;
                PlayState.instance.angelPulsing = false;
                FlxG.camera.flash();
        }*/
    }
}