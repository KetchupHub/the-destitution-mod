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
        this.introType = 'Eggshells';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
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