package options;

import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.graphics.FlxGraphic;
import states.MainMenuState;
import states.FreeplayState;
import backend.ClientPrefs;
import ui.Alphabet;
import util.CoolUtil;
import util.MemoryUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import backend.Controls;
import states.MusicBeatState;

#if desktop
import backend.Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var finishedIntro:Bool = false;

	var optionsThingy:FlxSprite;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Note Colors':
				openSubState(new NotesSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Graphics':
				openSubState(new GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new VisualsUISubState());
			case 'Gameplay':
				openSubState(new GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if DEVELOPERBUILD
		var perf = new Perf("Total OptionsState create()");
		#end

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		FlxG.sound.music.stop();

		CoolUtil.rerollRandomness();

		MemoryUtil.collect(true);
        MemoryUtil.compact();

		finishedIntro = false;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bg/menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var transThing:FlxSprite = new FlxSprite();

		if(CoolUtil.lastStateScreenShot != null)
		{
			transThing.loadGraphic(FlxGraphic.fromBitmapData(CoolUtil.lastStateScreenShot.bitmapData));
			add(transThing);
			FlxTween.tween(transThing, {alpha: 0}, 0.35, {ease: FlxEase.sineOut, onComplete: function transThingDiesIrl(stupidScr:FlxTween)
			{
				transThing.visible = false;
				transThing.destroy();
			}});
		}

		optionsThingy = new FlxSprite();
		optionsThingy.frames = Paths.getSparrowAtlas('options/markbot');
		optionsThingy.animation.addByPrefix('intro', 'intro', 24, false);
		optionsThingy.animation.addByPrefix('outro', 'outro', 24, false);
		optionsThingy.animation.play('intro');
		optionsThingy.animation.pause();
		optionsThingy.scale.set(2, 2);
		optionsThingy.updateHitbox();
		optionsThingy.screenCenter();
		add(optionsThingy);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			var maxWidth = 640;
			if (optionText.width > maxWidth)
			{
				optionText.scaleX = maxWidth / (optionText.width + 38);
			}
			optionText.screenCenter();
			optionText.x -= 16;
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.alpha = 0;
			optionText.ID = i;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.alpha = 0;
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.alpha = 0;
		add(selectorRight);

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		add(versionShit);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();

		introSequence();

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	function introSequence()
	{
		optionsThingy.animation.play('intro', true);
		optionsThingy.animation.finishCallback = function gah(name:String)
		{
			#if DEVELOPERBUILD
			trace('FINISHED INTRO ANIM FOR OPTION BOY! DEBUGGIN THIS SHIT');
			#end

			for (i in grpOptions.members)
			{
				#if DEVELOPERBUILD
				trace('TWEEN OPTION TEXT: ' + i.text);
				#end

				var toal:Float = 0.6;

				if (i.ID == curSelected)
				{
					toal = 1;
				}

				FlxTween.tween(i, {alpha: toal}, 0.25, {ease: FlxEase.expoOut, startDelay: 0.05 * i.ID});
			}

			var fucky:FlxTimer = new FlxTimer().start(0.25, function imKillingMyself(buddypal:FlxTimer)
			{
				#if DEVELOPERBUILD
				trace('TWEEN SELECTORS');
				#end
				FlxTween.tween(selectorLeft, {alpha: 1}, 0.25, {ease: FlxEase.expoOut});
				FlxTween.tween(selectorRight, {alpha: 1}, 0.25, {ease: FlxEase.expoOut, onComplete: function dirt(fluck:FlxTween)
				{
					finishedIntro = true;
					changeSelection(0);
					FlxG.sound.playMusic(Paths.music('mus_machinations'), 0.8);
					#if DEVELOPERBUILD
					trace('FINISHED INTRO');
					#end
				}});
			});
		}
	}

	function outroSequence()
	{
		finishedIntro = false;
		FlxG.sound.music.stop();
		FlxG.sound.music = null;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		for (i in grpOptions.members)
		{
			FlxTween.tween(i, {alpha: 0}, 0.15, {ease: FlxEase.expoIn, startDelay: 0.05 * i.ID});
		}
		FlxTween.tween(selectorLeft, {alpha: 0}, 0.25, {ease: FlxEase.expoIn});
		FlxTween.tween(selectorRight, {alpha: 0}, 0.25, {ease: FlxEase.expoIn, onComplete: function direksts(fuuuck:FlxTween)
		{
			optionsThingy.animation.play('outro', true);
			optionsThingy.animation.finishCallback = function gah(name:String)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new MainMenuState());
			}
		}});
	}

	override function closeSubState()
	{
		super.closeSubState();

		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		if(FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		if (CoolUtil.randomAudio.bool(0.003))
		{
			#if DEVELOPERBUILD
			trace('yous won: rare sound');
			#end
			FlxG.sound.play(Paths.sound('rare'));
		}

		super.update(elapsed);

		if (controls.UI_UP_P && finishedIntro)
		{
			changeSelection(-1);
		}

		if (controls.UI_DOWN_P && finishedIntro)
		{
			changeSelection(1);
		}

		if (controls.BACK && finishedIntro)
		{
			outroSequence();
		}

		if (controls.ACCEPT && finishedIntro)
		{
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (finishedIntro)
			{
				item.alpha = 0.6;
			}

			if (item.targetY == 0)
			{
				if (finishedIntro)
				{
					item.alpha = 1;
				}
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}