package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Countdown's song class.
 */
class Countdown extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Countdown';
        this.songHasSections = true;
        this.introType = 'Mark';
        //update these when the Sport Gameover later
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal"];
        this.songDescription = "It's a slice of life episode! Mark and the gang play sports with Nopeboy and his friends!";
        this.ratingsType = "";
        this.skipCountdown = false;
        this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
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