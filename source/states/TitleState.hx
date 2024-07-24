package states;

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

typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

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
	var credTextShit:ui.Alphabet;
	var textGroup:FlxGroup;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var tppLogo:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	var skippedIntro:Bool = false;
	
	var increaseVolume:Bool = false;

	var logo:FlxSprite;

	var titleCharacter:FlxSprite;

	var swagShader:ColorSwap = null;

	var titleText:FlxSprite;

	override public function create():Void
	{
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 24;

		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		swagShader = new ColorSwap();

		super.create();

		Application.current.window.title = CoolUtil.appTitleString;

		FlxG.save.bind('destitution', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}

			persistentUpdate = true;
			persistentDraw = true;
		}

		FlxG.mouse.visible = false;

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
	}

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('mus_pauperized'), 0);

				Conductor.changeBPM(titleJSON.bpm);
			}
		}
		
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none")
		{
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}
		else
		{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		add(bg);

		swagShader = new ColorSwap();

		logo = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logo.frames = Paths.getSparrowAtlas('destitution_mod_logo');
		logo.antialiasing = false;
		logo.animation.addByPrefix('bump', 'idle', 24, false);
		logo.animation.play('bump');
		logo.screenCenter();
		logo.x += 300;
		logo.shader = swagShader.shader;
		add(logo);

		var arrey:Array<String> = ['mark', 'bf', 'item', 'whale', 'crypteh', 'lock', 'plant'];
		var charec:String = arrey[FlxG.random.int(0, arrey.length - 1)];
		if(charec == 'plant' || charec == 'lock')
		{
			//reroll for lower chances, ik im dumb ok :sob:
			charec = arrey[FlxG.random.int(0, arrey.length - 1)];
			charec = arrey[FlxG.random.int(0, arrey.length - 1)];
		}
		var loopey:Bool = (charec == 'plant' || charec == 'item' || charec == 'whale' || charec == 'ploinky');

		titleCharacter = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		titleCharacter.frames = Paths.getSparrowAtlas('title/$charec');
		titleCharacter.animation.addByPrefix('idle', charec, 24, loopey);
		titleCharacter.animation.play('idle', true);
		titleCharacter.setGraphicSize(1080);
		titleCharacter.updateHitbox();
		titleCharacter.screenCenter(Y);
		titleCharacter.x = 0;
		if(charec == 'lock')
		{
			titleCharacter.x += 125;
		}
		titleCharacter.shader = swagShader.shader;
		add(titleCharacter);

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');

		var animFrames:Array<FlxFrame> = [];

		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0)
		{
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);

		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new ui.Alphabet(0, 20, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		tppLogo = new FlxSprite().loadGraphic(Paths.image("team productions presents"));
		tppLogo.screenCenter();
		tppLogo.y = 70;
		tppLogo.antialiasing = false;
		tppLogo.visible = false;
		add(tppLogo);

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		#end

		if (initialized)
		{
			skipIntro();
		}
		else
		{
			initialized = true;
		}
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
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null)
				{
					titleText.animation.play('press');
				}

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());

					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
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
				if(!titleCharacter.animation.getByName('idle').looped)
				{
					titleCharacter.animation.play('idle', true);
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

			FlxG.camera.flash();

			skippedIntro = true;
		}
	}
}