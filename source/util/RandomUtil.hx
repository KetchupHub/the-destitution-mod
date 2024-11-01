package util;

import flixel.math.FlxRandom;

class RandomUtil
{
  // using the same FlxRandom for everything can cause a lot of predictability so im not doing that anymore

  /**
   * Use for VISUALS, as in the ACTUAL ASSETS THEMSELVES, and ANIMATIONS! not POSITIONING! use the logic one for that
   */
  public static var randomVisuals:FlxRandom = new FlxRandom();

  /**
   * Use for AUDIO, and VOLUMES, and such
   */
  public static var randomAudio:FlxRandom = new FlxRandom();

  /**
   * Use for CODE STUFF, BACKEND STUFF, SECRETS, MOST RPG THINGS
   */
  public static var randomLogic:FlxRandom = new FlxRandom();

  public static function rerollRandomness()
  {
    randomVisuals.resetInitialSeed();
    randomAudio.resetInitialSeed();
    randomLogic.resetInitialSeed();
  }
}