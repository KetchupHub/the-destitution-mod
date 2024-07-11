package songs;

/**
 * Megamix's song class.
 */
class Megamix extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'MEGAMIX (Credits)';
        this.songHasSections = true;
        this.introType = 'Mark';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
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