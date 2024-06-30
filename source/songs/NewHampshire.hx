package songs;

/**
 * New Hampshire's song class.
 */
class NewHampshire extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'New Hampshire';
        this.songHasSections = false;
        this.introType = 'Default';
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