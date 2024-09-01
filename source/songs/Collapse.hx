package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Collapse's song class.
 */
class Collapse extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Collapse';
        this.songHasSections = true;
        this.introType = 'Mark';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
        this.songDescription = "It's the end of the Marketing family business when footage of Mark killing Nopeboy leaks. Now it's time to fight off bankruptcy!";
        this.ratingsType = "";
        this.skipCountdown = false;
        this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
        this.introCardBeat = 0;
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