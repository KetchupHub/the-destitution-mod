package songs;

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