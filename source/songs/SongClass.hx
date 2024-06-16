package songs;

/**
 * This class is used for storing song events, as opposed to crowding playstate.
 * each song has an override of it.
 * can probably even be used for storing extra data eventually! potentially?
 */
class SongClass
{
	public function new()
    {
        
    }

    public function stepHitEvent(curStep:Float)
    {
        //this is where step hit events will be overrided by the song class
    }
    
    public function beatHitEvent(curBeat:Float)
    {
        //this is where beat hit events will be overrided by the song class
    }
}