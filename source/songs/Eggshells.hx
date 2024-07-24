package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Eggshells' song class.
 */
class Eggshells extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Eggshells';
        this.songHasSections = false;
        this.introType = 'Eggshells';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
        this.songDescription = "Mark's lonely cousin seems like he's not much for conversation, but that won't stop Nopeboy from trying!";
        this.startSwing = true;
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