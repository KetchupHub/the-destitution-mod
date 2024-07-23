package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Song class template.
 */
class SongTemplate extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Template Song';
        this.songHasSections = false;
        this.introType = 'Default';
        this.songVariants = ["Normal"];
        this.songDescription = "Placeholder";
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