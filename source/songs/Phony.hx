package songs;

/**
 * phony class template.
 */
class Phony extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'Phony';
    this.playable = BF;
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal"];
    this.songDescription = "like phoneyx?"
    this.ratingsType = "";
    this.skipCountdown = false;
    this.preloadCharacters = ["bf-this", "gf", "stop-loading", "this"];
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
