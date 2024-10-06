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
      case 'fundamentals':
        returnSong = new Fundamentals();
      case 'destitution':
        returnSong = new Destitution();
      case 'superseded':
        returnSong = new Superseded();
      case 'quickshot':
        returnSong = new Quickshot();
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
      case 'topkicks':
        returnSong = new Topkicks();
      case 'quanta':
        returnSong = new Quanta();
      case 'abstraction':
        returnSong = new Abstraction();
      // erects
      case 'fundamentals-erect':
        returnSong = new Fundamentals();
      case 'destitution-erect':
        returnSong = new Destitution();
      case 'superseded-erect':
        returnSong = new Superseded();
      case 'quickshot-erect':
        returnSong = new Quickshot();
      case 'd-stitution-erect':
        returnSong = new DStitution();
      case 'eggshells-erect':
        returnSong = new Eggshells();
      case 'collapse-erect':
        returnSong = new Collapse();
      case 'topkicks-erect':
        returnSong = new Topkicks();
      case 'quanta-erect':
        returnSong = new Quanta();
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