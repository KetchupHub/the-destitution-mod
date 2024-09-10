package flixel.system.ui;

import openfl.utils.Assets;
import openfl.display.BitmapData;
#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	var capsule:Bitmap;

	var _defaultScale:Float = 1;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = 'volume_up';

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'volume_down';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	//main capsule pos is 504, 34
	//bar x is 532
	//multiply all by 2 for scale
	public var barPosses:Array<Float> = [98, 120, 142, 164, 186, 208, 230, 252, 274, 296];

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		x = (504 * 2);
		y = 68;

		var theDeFucking = Assets.getBitmapData(Paths.getPath('images/soundtray/capsule.png', IMAGE));
		//just for testing since the assets were being an ass
		//theDeFucking = new BitmapData(264, 584, false, 0xFFFF0000);
		capsule = new Bitmap(theDeFucking);
		capsule.visible = true;
		//capsule.scaleX = 2;
		//capsule.scaleY = 2;
		capsule.x = 0;
		capsule.y = 0;
		capsule.alpha = 0;
		addChild(capsule);

		_bars = new Array();

		var barToPush:Bitmap;

		barPosses.reverse();

		for (i in 0...10)
		{
			var theFucking = Assets.getBitmapData(Paths.getPath('images/soundtray/bar.png', IMAGE));
			//just for testing since the assets were being an ass
			//theFucking = new BitmapData(156, 42, false, 0xFF0400FF);
			barToPush = new Bitmap(theFucking);
			barToPush.visible = true;
			//barToPush.scaleX = 2;
			//barToPush.scaleY = 2;
			barToPush.x = (532 - 504) * 2;
			barToPush.y = (barPosses[i] * 2) - 68;
			barToPush.alpha = 0;
			addChild(barToPush);
			_bars.push(barToPush);
		}
	}

	/**
	 * This function updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
		}
		else
		{
			capsule.alpha = 0;

			for (i in 0..._bars.length)
			{
				_bars[i].alpha = 0;
			}

			#if FLX_SAVE
			if (FlxG.save.isBound)
			{
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
			#end

			active = false;
		}
	}

	public function show(up:Bool = false):Void
	{
		#if DEVELOPERBUILD
		trace('haha i am SHOWING the SOUNDTRAY it is at ' + x + ', ' + y);
		#end

		visible = true;
		active = true;

		if (!silent)
		{
			FlxG.sound.play(Paths.sound(up ? volumeUpSound : volumeDownSound));
		}

		var globalVolume:Int = Math.round(FlxG.sound.logToLinear(FlxG.sound.volume) * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.1;
			}
		}

		_timer = 1.5;
		capsule.alpha = 1;
	}

	/**
	 * this DOES NOT center it on the screen this is a LIE
	 */
	public function screenCenter():Void
	{
		x = (504 * 2);
		y = 68;
		alpha = 1;
	}
}
#end