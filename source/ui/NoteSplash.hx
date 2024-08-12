package ui;

import util.CoolUtil;
import backend.ClientPrefs;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import visuals.ColorSwap;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'ui/splashes/';

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		loadAnims(skin, Std.string(note));

		scale.set(2, 2);
		updateHitbox();
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0)
	{
		setPosition((x - Note.swagWidth * 0.95) + 106, (y - Note.swagWidth) + 128);
		alpha = 0.6;

		if (texture == null)
		{
			texture = 'ui/splashes/';

			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
				texture = PlayState.SONG.splashSkin;
		}

		if (textureLoaded != texture)
		{
			loadAnims(texture, Std.string(note));
		}

		scale.set(2, 2);
		updateHitbox();

		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(8, 8);

		var animNum:Int = CoolUtil.randomVisuals.int(0, 1);
		animation.play(Std.string(animNum), true);

		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + CoolUtil.randomVisuals.int(-2, 2);
	}

	function loadAnims(skin:String, arrow:String)
	{
		frames = Paths.getSparrowAtlas(skin + arrow);

		animation.addByPrefix("0", "splash1", 24, false);
		animation.addByPrefix("1", "splash2", 24, false);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				kill();

		super.update(elapsed);
	}
}