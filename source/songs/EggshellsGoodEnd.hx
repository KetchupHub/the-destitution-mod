package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Eggshells' song class.
 */
class EggshellsGoodEnd extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Eggshells (Good Ending)';
        this.songHasSections = false;
        this.introType = 'Eggshells';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal"];
        //songVariants doesnt matter for the ending classes (since theyre just loaded in by force at the end of eggshells)
        this.songDescription = "Mark's lonely cousin seems like he's not much for conversation, but that won't stop Nopeboy from trying!";
        this.ratingsType = "";
        this.skipCountdown = true;
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
    }
}