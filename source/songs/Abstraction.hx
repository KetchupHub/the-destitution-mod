package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Abstraction's song class.
 */
class Abstraction extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Abstraction';
        this.songHasSections = false;
        this.introType = 'Mark';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
        this.songDescription = "Experience the magic of Mark's very own self written television program firsthand!";
        this.startSwing = false;
        this.ratingsType = "";
        this.skipCountdown = true;
        this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
        this.startPpCam = false;
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