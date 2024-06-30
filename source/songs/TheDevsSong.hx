package songs;

/**
 * The Devs Song!'s song class.
 */
class TheDevsSong extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'THE DEVS SONG!';
        this.songHasSections = true;
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