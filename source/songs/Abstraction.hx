package songs;

/**
 * Abstraction's song class.
 */
class Abstraction extends SongClass
{
	public override function new()
    {
        super();
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