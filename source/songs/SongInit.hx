package songs;

/**
 * This class is used for generating a song's proper class. kinda hacky but whatever.
 */
class SongInit
{
	public static function genSongObj(songName:String):SongClass
    {
        var returnSong:SongClass;

        returnSong = new SongTemplate();

        switch (songName.toLowerCase())
        {
            case 'destitution':
                returnSong = new Destitution();
            case 'superseded':
                returnSong = new Superseded();
            case 'd-stitution':
                returnSong = new DStitution();
            case 'countdown':
                returnSong = new Countdown();
            case 'eggshells':
                returnSong = new Eggshells();
            case 'collapse':
                returnSong = new Collapse();
            case 'megamix':
                returnSong = new Megamix();
            case 'new-hampshire':
                returnSong = new NewHampshire();
            case 'abstraction':
                returnSong = new Abstraction();
            case 'three-of-them':
                returnSong = new ThreeOfThem();
        }

        return returnSong;
    }
}