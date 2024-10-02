package states;

import util.EaseUtil;
import visuals.PixelPerfectSprite;
import ui.MarkHeadTransition;
import backend.ClientPrefs;
import util.CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
  public static var leftState:Bool = false;

  public var warnText:FlxText;
  public var warnMark:PixelPerfectSprite;

  override function create()
  {
    #if DEVELOPERBUILD
    var perf = new Perf("Total FlashingState create()");
    #end

    MarkHeadTransition.nextCamera = FlxG.camera;

    super.create();

    var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    add(bg);

    warnText = new FlxText(0, 0, 640, "Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press ENTER to disable them now.\n
			Press ESCAPE to ignore this message.\n
			(You can turn them off later in the options menu either way.)\n
			You've been warned!", 32);
    warnText.setFormat(Paths.font("BAUHS93.ttf"), 32, FlxColor.WHITE, CENTER);
    warnText.screenCenter(Y);
    warnText.antialiasing = ClientPrefs.globalAntialiasing;
    add(warnText);

    warnMark = new PixelPerfectSprite(640).loadGraphic(Paths.image('options/flashing'));
    warnMark.scale.set(2, 2);
    warnMark.updateHitbox();
    warnMark.antialiasing = false;
    warnMark.setPosition(640, 0);
    add(warnMark);

    #if DEVELOPERBUILD
    var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width,
      "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
    versionShit.scrollFactor.set();
    versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    versionShit.antialiasing = ClientPrefs.globalAntialiasing;
    add(versionShit);
    #end

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  override function update(elapsed:Float)
  {
    if (!leftState)
    {
      var back:Bool = controls.BACK;
      if (controls.ACCEPT || back)
      {
        leftState = true;

        if (!back)
        {
          ClientPrefs.flashing = false;
          ClientPrefs.saveSettings();
          FlxG.sound.play(Paths.sound('confirmMenu'));
          FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
            new FlxTimer().start(0.5, function(tmr:FlxTimer) {
              FlxTransitionableState.skipNextTransIn = false;
              FlxTransitionableState.skipNextTransOut = false;
              MarkHeadTransition.nextCamera = FlxG.camera;
              MusicBeatState.switchState(new TitleState());
            });
          });
        }
        else
        {
          FlxG.sound.play(Paths.sound('cancelMenu'));
          FlxTween.tween(warnMark, {alpha: 0}, 0.95,
            {
              ease: EaseUtil.stepped(8)
            });
          FlxTween.tween(warnText, {alpha: 0}, 1,
            {
              ease: EaseUtil.stepped(8),
              onComplete: function(twn:FlxTween) {
                FlxTransitionableState.skipNextTransIn = false;
                FlxTransitionableState.skipNextTransOut = false;
                MarkHeadTransition.nextCamera = FlxG.camera;
                MusicBeatState.switchState(new TitleState());
              }
            });
        }
      }
    }
    super.update(elapsed);
  }
}