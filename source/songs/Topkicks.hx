package songs;

import backend.TextAndLanguage;

/**
 * TopKicks' song class.
 */
class Topkicks extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'TopKicks';
    this.playable = PEAR;
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal"];
    this.songDescription = TextAndLanguage.getPhrase('desc_topkicks',
      "It seems like a couple of Pearson's friends haven't taken too kindly to not being invited...");
    this.ratingsType = "";
    this.skipCountdown = false;
    this.preloadCharacters = ["bf-mark", "gf", "stop-loading"];
    this.introCardBeat = 64;
    this.rpcVolume = "-pear";
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