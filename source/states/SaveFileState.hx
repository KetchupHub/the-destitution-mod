package states;

import backend.Conductor;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import options.OptionsState;
import backend.ClientPrefs;
import backend.WeekData;
import util.CoolUtil;
import util.MemoryUtil;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

#if desktop
import backend.Discord.DiscordClient;
#end

class SaveFileState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	public var camGame:FlxCamera;

    public var bg:FlxSprite;
	public var swirls:FlxSprite;
    public var guys:FlxSprite;

	override function create()
	{
		#if DEVELOPERBUILD
        var perf = new Perf("SaveFileState create()");
		#end

		persistentUpdate = true;
		persistentDraw = true;

		CoolUtil.rerollRandomness();

        MemoryUtil.collect(true);
        MemoryUtil.compact();

		FlxG.mouse.visible = false;

		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Picking a Save File for Story Mode", null);
		#end

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('mus_save_select'), 0);
			Conductor.changeBPM(136);
		}

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		bg = new FlxSprite().loadGraphic(Paths.image('saves/bg'));
        bg.scale.set(2, 2);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        swirls = new FlxSprite().loadGraphic(Paths.image('saves/swirls'), true, 640, 360);
        swirls.animation.add('idle', [0, 1], 1, true);
        swirls.animation.play('idle', true);
        swirls.scale.set(2, 2);
		swirls.updateHitbox();
		swirls.screenCenter();
        swirls.alpha = 0.25;
		add(swirls);

        guys = new FlxSprite().loadGraphic(Paths.image('saves/guys'), true, 202, 360);
        guys.animation.add('idle', [0, 1], 3, true);
        guys.animation.play('idle', true);
        guys.scale.set(2, 2);
		guys.updateHitbox();
        guys.x = 1280 - 404;
		add(guys);

		var versionShit:FlxText = new FlxText(-4, #if DEVELOPERBUILD FlxG.height - 44 #else FlxG.height - 24 #end, FlxG.width, "The Destitution Mod v" + MainMenuState.psychEngineVersion #if DEVELOPERBUILD + "\n(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")" #end, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		versionShit.antialiasing = ClientPrefs.globalAntialiasing;
		add(versionShit);

		changeItem();

		super.create();

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
			
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.sound.music.stop();
                FlxG.sound.music = null;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= 3)
		{
			curSelected = 0;
		}

		if (curSelected < 0)
		{
			curSelected = 2;
		}
	}
}