package states;

import backend.ClientPrefs;
import flixel.addons.transition.FlxTransitionableState;
import flixel.sound.FlxSound;
import util.MemoryUtil;
import backend.WeekData;
import backend.Conductor;
import visuals.Boyfriend;
import util.CoolUtil;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	public var updateCamera:Bool = false;
	public var playingDeathSound:Bool = false;

	public var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'deathsting_default';
	public static var loopSoundName:String = 'mus_overtime';
	public static var endSoundName:String = 'mus_overtime_end';

	public static var instance:GameOverSubstate;

	public static function resetVariables()
	{
		characterName = 'bf-dead';
		deathSoundName = 'deathsting_default';
		loopSoundName = 'mus_overtime';
		endSoundName = 'mus_overtime_end';
	}

	override function create()
	{
		instance = this;
		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		#if DEVELOPERBUILD
		var perf = new Perf("Total GameOverSubstate new()");
		#end

		CoolUtil.rerollRandomness();

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName), 1, false, null, true, function oncompey()
		{
			playingDeathSound = false;
		});
		playingDeathSound = true;
		Conductor.changeBPM(95);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		versionShit.antialiasing = ClientPrefs.globalAntialiasing;
		add(versionShit);
		#end

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	var isFollowingAlready:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (CoolUtil.randomAudio.bool(0.0003))
		{
			#if DEVELOPERBUILD
			trace('yous won: rare sound');
			#end
			FlxG.sound.play(Paths.sound('rare'));
		}

		if (updateCamera)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);

			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			FlxG.sound.list.forEach(function ficks(fuc:FlxSound)
			{
				fuc.stop();
			});
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			MemoryUtil.collect(true);
			MemoryUtil.compact();

			WeekData.loadTheFirstEnabledMod();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			MusicBeatState.switchState(new MainMenuState());

			FlxG.sound.playMusic(Paths.music('mus_pauperized'));
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					MusicBeatState.switchState(new PlayState());
				});
			});
		}
	}
}