package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class EndingMuralState extends MusicBeatState
{
	var winScreen:FlxSprite;

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('breakfast'), 0.8);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		winScreen = new FlxSprite().loadGraphic(Paths.image('destitution/mural'));
		winScreen.screenCenter();
		add(winScreen);

		var textington:FlxSprite = new FlxSprite().loadGraphic(Paths.image('destitution/congrats'));
		add(textington);
	}

	override function update(elapsed:Float)
	{
		var back:Bool = controls.BACK;
		if (controls.ACCEPT || back)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(winScreen, {alpha: 0}, 1,
			{
				onComplete: function (twn:FlxTween) 
				{
					MusicBeatState.switchState(new MainMenuState());
				}
			});
		}
		super.update(elapsed);
	}
}