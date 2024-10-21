package songs;

import backend.TextAndLanguage;

/**
 * Countdown's song class.
 */
class Countdown extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'Countdown';
    this.playable = SPORTS;
    this.songHasSections = true;
    this.introType = 'Mark';
    // update these when the Sport Gameover later
    this.gameoverChar = 'bf-dead';
    this.gameoverMusicSuffix = '';
    this.songVariants = ["Normal"];
    this.songDescription = TextAndLanguage.getPhrase('desc_countdown',
      "It's a slice of life episode! Mark and the gang play sports with Nopeboy and his friends!");
    this.ratingsType = "";
    this.skipCountdown = false;
    this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
    this.introCardBeat = 0;
  }

  public override function stepHitEvent(curStep:Float)
  {
    // this is where step hit events go
    super.stepHitEvent(curStep);
  }

  public override function beatHitEvent(curBeat:Float)
  {
    // this is where beat hit events go
    super.beatHitEvent(curBeat);
  }
}