package songs;

/**
 * Fundamentals' song class.
 */
class Fundamentals extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'Fundamentals';
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal", "Erect"];
    this.songDescription = "Learn to sing in this new world with Girlspeaks' help!";
    this.ratingsType = "";
    this.skipCountdown = false;
    this.preloadCharacters = ["bf-mark", "gf-fundamentals", "yuu-fundamentals", "stop-loading"];
    this.introCardBeat = 16;
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