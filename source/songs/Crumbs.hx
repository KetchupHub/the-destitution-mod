package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Song class template.
 */
class Crumbs extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'CRUMBS...';
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal", "Erect"];
    this.songDescription = "Darnit! Look what just crawled out of Mark's Time Machine!";
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