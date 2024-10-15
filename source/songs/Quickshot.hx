package songs;

import backend.TextAndLanguage;

/**
 * Quickshot's song class.
 */
class Quickshot extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'Quickshot';
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal", "Erect"];
    this.songDescription = TextAndLanguage.getPhrase('desc_quickshot', "Pearson faces the Rulez Battalion in combat!");
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