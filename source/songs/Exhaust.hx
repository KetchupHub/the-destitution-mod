package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Song class template.
 */
class Exhaust extends SongClass
{
  public override function new()
  {
    super();
    this.songNameForDisplay = 'Exhaust';
    this.songHasSections = false;
    this.introType = 'Default';
    this.songVariants = ["Normal", "Erect"];
    this.songDescription = "SAVE The Car Kidz from an evil spell!";
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