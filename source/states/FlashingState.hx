package states;

import backend.ClientPrefs;
import util.CoolUtil;
import flixel.tweens.FlxEase;
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

	var warnText:FlxText;
	var warnMark:FlxSprite;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, 640,
			"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press ENTER to disable them now.\n
			Press ESCAPE to ignore this message.\n
			(You can turn them off later in the options menu either way.)\n
			You've been warned!",
			32);
		warnText.setFormat(Paths.font("BAUHS93.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		warnMark = new FlxSprite(640).loadGraphic(Paths.image('options/flashing'));
		warnMark.scale.set(2, 2);
		warnMark.updateHitbox();
		warnMark.antialiasing = false;
		warnMark.setPosition(640, 0);
		add(warnMark);

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState)
		{
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back)
			{
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				if(!back)
				{
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker)
					{
						new FlxTimer().start(0.5, function (tmr:FlxTimer)
						{
							MusicBeatState.switchState(new TitleState());
						});
					});
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnMark, {y: 800}, 0.75,
					{
						ease: FlxEase.circOut
					});
					FlxTween.tween(warnText, {alpha: 0}, 1,
					{
						onComplete: function (twn:FlxTween)
						{
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}