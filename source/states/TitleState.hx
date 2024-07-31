package states;

import flixel.graphics.FlxGraphic;
import visuals.ColorSwap;
import backend.Highscore;
import backend.PlayerSettings;
import backend.WeekData;
import backend.ClientPrefs;
import ui.Alphabet;
import backend.Conductor;
import util.CoolUtil;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	
	var transitioning:Bool = false;	
	
	var newTitle:Bool = false;

	var titleTimer:Float = 0;

	var blackScreen:FlxSprite;

	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	var exitButton:FlxSprite;
	var playButton:FlxSprite;

	var charec:String = 'mark';

	var curWacky:Array<String> = [];

	var tppLogo:FlxSprite;

	var mustUpdate:Bool = false;

	var skippedIntro:Bool = false;
	
	var increaseVolume:Bool = false;

	var logo:FlxSprite;

	var titleCharacter:FlxSprite;

	var swagShader:ColorSwap = null;

	var closeSequenceStarted:Bool = false;

	override public function create():Void
	{
		#if DEVELOPERBUILD
		var perf = new Perf("Total TitleState create()");
		#end

		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 24;

		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = CoolUtil.randomLogic.getObject(getIntroTextShit());

		swagShader = new ColorSwap();

		super.create();

		Application.current.window.title = CoolUtil.appTitleString;

		FlxG.mouse.load(Paths.image('cursor').bitmap, 2, 2, 2);

		FlxG.save.bind('destitution', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}

			persistentUpdate = true;
			persistentDraw = true;
		}

		FlxG.mouse.visible = true;

		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			if (initialized)
			{
				startIntro();
			}
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	function startIntro()
	{
		#if DEVELOPERBUILD
        var perf = new Perf("TitleState startIntro()");
		#end

		if (!initialized)
		{
			if(FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('mus_pauperized'), 0);

				Conductor.changeBPM(150);
			}
		}
		
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

		swagShader = new ColorSwap();

		if(initialized)
		{
			CoolUtil.rerollRandomness();
		}

		var arrey:Array<String> = ['bf', 'crypteh', 'ili', 'karm', 'mark', 'ploinky', 'rulez', 'whale'];
		if(CoolUtil.randomLogic.bool(10))
		{
			arrey = ['blocken', 'plant'];
		}
		var holidayChar = CoolUtil.getHolidayCharacter();
		if(holidayChar != null)
		{
			//should i be nice and make the holidays the only ones you can get on that day?
			//nah
			//except as im typing this i realize that seems like a dick move so i wont
			//still ends up trolling the people who wouldve rolled the 1/10 chance ones though so lol
			arrey = [holidayChar];
		}
		charec = arrey[CoolUtil.randomVisuals.int(0, arrey.length - 1)];
		if(Paths.image('title/char/$charec') == null)
		{
			//precaution
			charec = 'mark';
		}
		#if SHOWCASEVIDEO
		//force set to mark for showcase video, cuz i want it to be as non random as possible.
		charec = 'mark';
		#end
		titleCharacter = new FlxSprite(0, 0).loadGraphic(Paths.image('title/char/$charec'), true, 320, 360);
		titleCharacter.animation.add(charec, [0, 1], 0, false);
		titleCharacter.animation.play(charec, true);
		titleCharacter.antialiasing = false;
		titleCharacter.scale.set(2, 2);
		titleCharacter.updateHitbox();
		titleCharacter.shader = swagShader.shader;
		add(titleCharacter);

		var objects:FlxSprite = new FlxSprite(640, 0).loadGraphic(Paths.image('title/obj'));
		objects.antialiasing = false;
		objects.scale.set(2, 2);
		objects.updateHitbox();
		objects.shader = swagShader.shader;
		add(objects);

		logo = new FlxSprite(490, 0);
		logo.frames = Paths.getSparrowAtlas('title/logo');
		logo.antialiasing = false;
		logo.animation.addByPrefix('bump', 'idle', 24, false);
		logo.animation.play('bump');
		add(logo);

		var tppWatermarkTittle:FlxSprite = new FlxSprite(8, 590).loadGraphic(Paths.image("title/tpp"));
		tppWatermarkTittle.setGraphicSize(256);
		tppWatermarkTittle.updateHitbox();
		add(tppWatermarkTittle);

		exitButton = new FlxSprite(8, 8).loadGraphic(Paths.image('title/close'));
		exitButton.scale.set(2, 2);
		exitButton.updateHitbox();
		add(exitButton);

		playButton = new FlxSprite(FlxG.width - 210, FlxG.height - 210).loadGraphic(Paths.image('title/play'));
		playButton.scale.set(2, 2);
		playButton.updateHitbox();
		add(playButton);

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		add(versionShit);
		#end

		credGroup = new FlxGroup();
		add(credGroup);

		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 20, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		tppLogo = new FlxSprite().loadGraphic(Paths.image("title/tpp"));
		tppLogo.screenCenter();
		tppLogo.y = 70;
		tppLogo.antialiasing = false;
		tppLogo.visible = false;
		add(tppLogo);

		var transThing:FlxSprite = new FlxSprite();

		if(CoolUtil.lastStateScreenShot != null)
		{
			transThing.loadGraphic(FlxGraphic.fromBitmapData(CoolUtil.lastStateScreenShot.bitmapData));
			add(transThing);
			FlxTween.tween(transThing, {alpha: 0}, 0.35, {startDelay: 0.05, ease: FlxEase.sineOut, onComplete: function transThingDiesIrl(stupidScr:FlxTween)
			{
				transThing.visible = false;
				transThing.destroy();
			}});
		}

		if (initialized)
		{
			skipIntro();
		}
		else
		{
			initialized = true;
		}

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function update(elapsed:Float)
	{
		if(!closeSequenceStarted)
		{
			if (FlxG.sound.music != null)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
		
			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
				{
					pressedEnter = true;
				}
			}
		
			if(skippedIntro && FlxG.mouse.overlaps(exitButton, FlxG.camera) && !transitioning)
			{
				if(FlxG.mouse.justPressed)
				{
					gameCloseSequence();
				}
			}
		
			if(skippedIntro && FlxG.mouse.overlaps(playButton, FlxG.camera) && !transitioning)
			{
				if(FlxG.mouse.justPressed)
				{
					pressedEnter = true;
				}
			}
				
			if (newTitle)
			{
				titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
		
				if (titleTimer > 2)
				{
					titleTimer -= 2;
				}
			}
		
			if (initialized && !transitioning && skippedIntro)
			{
				if (newTitle && !pressedEnter)
				{
					var timer:Float = titleTimer;
					if (timer >= 1)
					{
						timer = (-timer) + 2;
					}
					
					timer = FlxEase.quadInOut(timer);
				}
					
				if(pressedEnter)
				{
					//FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		
					transitioning = true;
		
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;

						MusicBeatState.switchState(new MainMenuState());
		
						closedState = true;
					});
				}
			}
		
			if (initialized && pressedEnter && !skippedIntro)
			{
				skipIntro();
			}
		}


		if(swagShader != null)
		{
			if(controls.UI_LEFT && !controls.UI_RIGHT)
			{
				swagShader.hue -= elapsed * 0.1;
			}

			if(controls.UI_RIGHT && !controls.UI_LEFT)
			{
				swagShader.hue += elapsed * 0.1;
			}
		}

		super.update(elapsed);
	}

	function gameCloseSequence()
	{
		closeSequenceStarted = true;
		titleCharacter.animation.curAnim.curFrame = 0;
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('titleExit/$charec'), 1, false);

		FlxTween.tween(playButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.35, {ease: FlxEase.backOut, onComplete: function fuckstween(t:FlxTween)
		{
			playButton.alpha = 0;
			playButton.visible = false;
			playButton.destroy();
		}});

		FlxTween.tween(exitButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.35, {ease: FlxEase.backOut, onComplete: function fuckstween(t:FlxTween)
		{
			exitButton.alpha = 0;
			exitButton.visible = false;
			exitButton.destroy();
		}});

		var timeyTheTimer:FlxTimer = new FlxTimer().start(2.5, function photoshopTimey(timeyX:FlxTimer)
		{
			Application.current.window.close();
		});
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);

			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;

			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);

			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;

			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0;

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if(curBeat % 2 == 0)
		{
			if(logo != null)
			{
				logo.animation.play('bump', true);
			}
	
			if(titleCharacter != null)
			{
				if(titleCharacter.animation.curAnim.curFrame == 0)
				{
					titleCharacter.animation.curAnim.curFrame = 1;
				}
				else
				{
					titleCharacter.animation.curAnim.curFrame = 0;
				}
			}
		}

		if(!closedState)
		{
			sickBeats++;

			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('mus_pauperized'));
				case 5:
					tppLogo.visible = true;
				case 9:
					createCoolText(['...present'], tppLogo.height);
				case 12:
					tppLogo.visible = false;
					deleteCoolText();
				case 13:
					createCoolText([curWacky[0]]);
				case 17:
					addMoreText(curWacky[1]);
				case 20:
					deleteCoolText();
				case 21:
					addMoreText('The');
				case 25:
					addMoreText('Destitution');
				case 29:
					addMoreText('Mod');
				case 33:
					skipIntro();
			}
		}
	}

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(tppLogo);
			remove(credGroup);

			//FlxG.camera.flash();

			skippedIntro = true;
		}
	}
}