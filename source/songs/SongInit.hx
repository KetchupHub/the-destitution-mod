package songs;

import songs.*;

/**
 * This class is used for generating a song's proper class. kinda hacky but whatever.
 */
class SongInit
{
	public static function genSongObj(songName:String):SongClass
    {
        var returnSong:SongClass = null;

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
            case 'eggshells-bad':
                returnSong = new EggshellsBadEnd();
            case 'eggshells-good':
                returnSong = new EggshellsGoodEnd();
            case 'collapse':
                returnSong = new Collapse();
            case 'megamix':
                returnSong = new Megamix();
            case 'new-hampshire':
                returnSong = new NewHampshire();
            case 'abstraction':
                returnSong = new Abstraction();
            //erects
            case 'destitution-erect':
                returnSong = new Destitution();
            case 'superseded-erect':
                returnSong = new Superseded();
            case 'd-stitution-erect':
                returnSong = new DStitution();
            case 'eggshells-erect':
                returnSong = new Eggshells();
            case 'collapse-erect':
                returnSong = new Collapse();
            case 'new-hampshire-erect':
                returnSong = new NewHampshireErect();
            case 'abstraction-erect':
                returnSong = new Abstraction();
        }

        try
        {
            var fun:String = returnSong.introType;
        }
        catch (e:Dynamic)
        {
            throw "Error loading song object! Class is missing or not assigned in SongInit!";
        }

        return returnSong;
    }
}