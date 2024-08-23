package states;

import backend.Scoring;
import flixel.addons.effects.FlxClothSprite;
import backend.WeekData;
import ui.MarkHeadTransition;
import backend.Highscore;
import backend.Song;
import backend.Conductor;
import backend.ClientPrefs;
import util.CoolUtil;
import lime.app.Application;
import backend.Section.SwagSection;
import backend.Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.animation.FlxAnimationController;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import openfl.display.BlendMode;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import openfl.events.KeyboardEvent;
import backend.StageData;
import visuals.Character;
import visuals.Boyfriend;
import visuals.AttachedSprite;
import visuals.BucksGraphBar;
import visuals.WiggleEffect;
import ui.Note;
import ui.Note.EventNote;
import ui.StrumNote;
import ui.NoteSplash;
import ui.HealthIcon;
import songs.*;

#if desktop
import backend.Discord.DiscordClient;
#end

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import hxcodec.flixel.*;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var SONG:SwagSong = null;

	public var songObj:SongClass;

	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public static var ratingStuff:Array<Dynamic> = [
		['Blegh!', 0.2], //From 0% to 19%
		['Bleck!', 0.4], //From 20% to 39%
		['Bad!', 0.5], //From 40% to 49%
		['Egh.', 0.6], //From 50% to 59%
		['Meh.', 0.7], //From 60% to 69%
		['Good!', 0.8], //From 70% to 79%
		['Great!', 0.9], //From 80% to 89%
		['Incredible!', 0.99], //From 90% to 98%
		['Synergy!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	public var keysArray:Array<Dynamic>;

	public var camFollow:FlxPoint;
	public static var prevCamFollow:FlxPoint;

	public var camFollowPos:FlxObject;
	public static var prevCamFollowPos:FlxObject;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	public var debugKeysChart:Array<FlxKey>;
	public var debugKeysCharacter:Array<FlxKey>;

	public var ratingName:String = '?';
	public var ratingFC:String;
	public var songFont:String = "BAUHS93.ttf";
	public var songSpeedType:String = "multiplicative";
	public static var curStage:String = '';
	public var curSong:String = "";
	public var detailsText:String = "Playing the Game";
	public var detailsPausedText:String = "Paused";
	public var introSoundsSuffix:String = '';
	public var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var precacheList:Map<String, String> = new Map<String, String>();
	public var controlArray:Array<String>;
	public static var storyPlaylist:Array<String> = [];

	public var songTime:Float = 0;
	public var elapsedTotal:Float;
	public var totalNotesHit:Float = 0.0;
	public var camZoomAdditive:Float = 0;
	public var ratingPercent:Float;
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var songSpeed(default, set):Float = 1;
	public var noteKillOffset:Float = 350;
	public var playbackRate(default, set):Float = 1;
	public var spawnTime:Float = 2000;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	public var songPercent:Float = 0;
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var health:Float = 1;
	public var smoothenedHealth:Float = 1;
	public var cameraSpeed:Float = 1;
	public var heyTimer:Float;
	public static var daPixelZoom:Float = 6;
	public var defaultCamZoom:Float = 1.05;
	public var songLength:Float = 0;
	public var bgPlayerWalkTarget:Float;
	public var bucksBarUpdateCountdown:Float = 10;
	public static var startOnTime:Float = 0;
	public var spaceTimeDadArray:Array<Float> = [0, 0];
	public var spaceTimeBfArray:Array<Float> = [0, 0];
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public var totalPlayed:Int = 0;
	public static var sectionNum:Int = 1;
	public var debugNum:Int = 0;
	public var previousFrameTime:Int = 0;
	public var lastReportedPlayheadPosition:Int = 0;
	public var lastStepHit:Int = -1;
	public var bgColorsCrazyBeats:Int = 4;
	public var lightningStrikeBeat:Int = 0;
	public var lightningOffset:Int = 8;
	public var lastBeatHit:Int = -1;
	public var gfSpeed:Int = 1;
	public var combo:Int = 0;
	public static var storyWeek:Int = 0;
	public var synergys:Int = 0;
	public var goods:Int = 0;
	public var eghs:Int = 0;
	public var bleghs:Int = 0;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var deathCounter:Int = 0;
	public var bucksBarHistoryFuck:Array<Int> = [9, 9, 9, 9, 9, 9, 9, 9];
	
	public static var isStoryMode:Bool = false;
	public static var songHasSections:Bool = false;
	public static var chartingMode:Bool = false;
	public static var seenCutscene:Bool = false;
	public var pixelPerfectishCamera:Bool = false;
	public var fuckMyLife:Bool = false;
	public var swingSec:Bool = false;
	public var isCameraOnForcedPos:Bool = false;
	public var brokerBop:Bool = false;
	public var camZooming:Bool = true;
	public var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	public var updateTime:Bool = true;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	public var strikeyStrikes:Bool = false;
	public var spaceTime:Bool;
	public var rulezBeatSlam:Bool = false;
	public var whaleFuckShit:Bool = false;
	public var tweeningCam:Bool = false;
	public var centerCamOnBg:Bool = false;
	public var shoulderCam:Bool = false;
	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;
	public var disallowCamMove:Bool = false;
	public var skipArrowStartTween:Bool = false;
	public var paused:Bool = false;
	public var canReset:Bool = true;
	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;
	public var isDead:Bool = false;
	public var funBackCamFadeShit:Bool = false;
	public var funnyBgColorsPumpin:Bool = false;
	public var bgColorsRandom:Bool = false;
	public var keysPressed:Array<Bool> = [];
	public var strumsBlocked:Array<Bool> = [];
	public var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	public var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	public var scoreTxt:FlxText;
	public var timeTxt:FlxText;
	public var fullLength:FlxText;
	public var sectText:FlxText;
	public var sectNameText:FlxText;

	public var dad:Character = null;
	public var gf:Character = null;
	public var bgPlayer:Character;
	public var stockboy:Character;

	public var boyfriend:Boyfriend = null;
	
	#if !SHOWCASEVIDEO
	public var botplayTxt:FlxSprite;
	#end
	public var songIntro:FlxSprite;
	public var strumLine:FlxSprite;
	public static var lastRating:FlxSprite;
	public var ploinkyTransition:FlxSprite;
	public var rulezGuySlideScaleWorldFunnyClips:FlxSprite;
	public var YOUSTUPIDSONOFABITCH:FlxSprite;
	public var zamMarkCamFlipShit:FlxSprite;
	public var ref:FlxSprite;
	public var chefBanner:FlxSprite;
	public var chefTable:FlxSprite;
	public var train:FlxSprite;
	public var karmScaredy:FlxSprite;
	public var cabinBg:FlxSprite;
	public var supersededIntro:FlxSprite;
	public var backing:FlxSprite;
	public var sky:FlxSprite;
	public var lightningStrikes:FlxSprite;
	public var angry:FlxSprite;
	public var angryDadCover:FlxSprite;
	public var zamboni:FlxSprite;
	public var cryptehB:FlxSprite;
	public var office:FlxSprite;
	public var annoyed:FlxSprite;
	public var liek:FlxSprite;
	public var space:FlxSprite;
	public var blackVoid:FlxSprite;
	public var iliDevilJumpscare:FlxSprite;
	public var ploinky:FlxSprite;
	public var starting:FlxSprite;
	public var cuttingSceneThing:FlxSprite;
	public var funnyBgColors:FlxSprite;
	public var healthBarBG:FlxSprite;
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var lastScore:Array<FlxSprite> = [];
	public var spaceItems:FlxTypedGroup<FlxSprite>;

	public var chefCurtains:FlxClothSprite;
	
	public var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var eventNotes:Array<EventNote> = [];

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var bucksBars:Array<BucksGraphBar> = [];

	public var songSpeedTween:FlxTween;
	public var scoreTxtTween:FlxTween;
	public var cameraTwn:FlxTween;
	public var bfAlphaTwnBack:FlxTween;

	public var funnyColorsArray:Array<FlxColor> = [FlxColor.BLUE, FlxColor.CYAN, FlxColor.GREEN, FlxColor.LIME, FlxColor.MAGENTA, FlxColor.ORANGE, FlxColor.PINK, FlxColor.PURPLE, FlxColor.RED, FlxColor.YELLOW, FlxColor.BROWN];

	public var startTimer:FlxTimer;
	public var finishTimer:FlxTimer = null;

	public var spaceWiggle:WiggleEffect;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	override public function create()
	{
		instance = this;

		#if DEVELOPERBUILD
		var perf = new Perf("Total PlayState create()");
		#end

		FlxG.mouse.visible = false;

		CoolUtil.rerollRandomness();

		gameplaySettingsSetup();

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		MarkHeadTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		detailsPausedText = "Paused";
		#end

		var songName:String = Paths.formatToSongPath(SONG.song);

		songObj = SongInit.genSongObj(songName);

		songDataShit(songName);

		var stageData:StageFile = StageData.getStageFile(curStage);

		if (stageData == null)
		{
			stageData = {
				defaultZoom: 1,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1,
				artist: 'Cynda'
			};
		}

		defaultCamZoom = stageData.defaultZoom;

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];

		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];

		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
		{
			cameraSpeed = stageData.camera_speed;
		}

		boyfriendCameraOffset = stageData.camera_boyfriend;

		if (boyfriendCameraOffset == null)
		{
			boyfriendCameraOffset = [0, 0];
		}

		opponentCameraOffset = stageData.camera_opponent;

		if (opponentCameraOffset == null)
		{
			opponentCameraOffset = [0, 0];
		}

		girlfriendCameraOffset = stageData.camera_girlfriend;
		
		if (girlfriendCameraOffset == null)
		{
			girlfriendCameraOffset = [0, 0];
		}

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		makeStage(curStage);

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		var gfVersion:String = SONG.gfVersion;

		if (gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = 'gf';
			SONG.gfVersion = gfVersion;
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			
			startCharacterPos(gf);

			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);

		startCharacterPos(dad, true);

		dadGroup.add(dad);

		if (angryDadCover != null)
		{
			add(angryDadCover);
		}

		boyfriend = new Boyfriend(0, 0, SONG.player1);

		startCharacterPos(boyfriend);

		boyfriendGroup.add(boyfriend);

		if (supersededIntro != null)
		{
			add(supersededIntro);
		}

		if (chefTable != null)
		{
			add(chefTable);
			chefTable.visible = false;
		}

		if (chefBanner != null)
		{
			add(chefBanner);
			chefBanner.visible = false;
		}

		if (chefCurtains != null)
		{
			add(chefCurtains);
			chefCurtains.active = false;
			chefCurtains.visible = false;
		}

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);

		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);

			if(gf != null)
			{
				gf.visible = false;
			}
		}

		if (SONG.song.toLowerCase() == "d-stitution" || SONG.song.toLowerCase() == "d-stitution-erect")
		{
			dad.visible = false;
		}

		Conductor.songPosition = -5000 / Conductor.songPosition;

		var storageLol:Bool = false;
		storageLol = ClientPrefs.middleScroll;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);

		if (ClientPrefs.downScroll)
		{
			strumLine.y = FlxG.height - 150;
		}

		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(0, 4, 400, "", 32);
		timeTxt.setFormat(Paths.font(songFont), 32 + 10, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		timeTxt.borderSize = 1.5;
		timeTxt.screenCenter(X);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.visible = showTime;
		timeTxt.antialiasing = ClientPrefs.globalAntialiasing;
		
		if (ClientPrefs.downScroll)
		{
			timeTxt.y = FlxG.height - 40;
		}

		if (ClientPrefs.timeBarType == 'Time Left' || ClientPrefs.timeBarType == 'Time Elapsed')
		{
			timeTxt.size = 36;
			timeTxt.underline = true;
			fullLength = new FlxText(timeTxt.x, timeTxt.y + 36, 400, "", 24);
			fullLength.setFormat(Paths.font(songFont), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			fullLength.borderSize = 1.5;
			fullLength.scrollFactor.set();
			fullLength.alpha = 0;
			fullLength.visible = showTime;
			fullLength.antialiasing = ClientPrefs.globalAntialiasing;
		}

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = songObj.songNameForDisplay;
		}

		updateTime = showTime;

		if (fullLength != null)
		{
			add(fullLength);
		}

		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 14;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}

		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new FlxSprite(308, 532).loadGraphic(Paths.image('ui/healthBar'));
		healthBarBG.antialiasing = false;
		healthBarBG.scale.set(2, 2);
		healthBarBG.updateHitbox();
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		if (ClientPrefs.downScroll)
		{
			healthBarBG.y = 6;
		}

		healthBar = new FlxBar(healthBarBG.x + 24, healthBarBG.y + 72, RIGHT_TO_LEFT, 616, 46, this,
			'smoothenedHealth', 0, 2);
		if (ClientPrefs.smootherBars)
		{
			healthBar.numDivisions = 616;
		}
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);

		add(healthBarBG);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		//adding p1 second, solely for the visual gag with pinkerton's losing icon, lol
		add(iconP1);

		scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + healthBarBG.height - 44, healthBarBG.width, "", 24);
		scoreTxt.setFormat(Paths.font("Calculator.ttf"), 24, FlxColor.fromRGB(30, 173, 25), CENTER, FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(6, 59, 5));
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();
		scoreTxt.visible = !ClientPrefs.hideHud;
		scoreTxt.antialiasing = false;
		add(scoreTxt);

		//adding these now, because its better and such
		add(strumLineNotes);
		add(grpNoteSplashes);
		add(notes);

		#if !SHOWCASEVIDEO
		var botplaySuffix:String = "";
		botplayTxt = new FlxSprite(0, FlxG.height - 256).loadGraphic(Paths.image("ui/botplay" + botplaySuffix));
		botplayTxt.scrollFactor.set();
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		#end

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		versionShit.cameras = [camHUD];
		versionShit.antialiasing = ClientPrefs.globalAntialiasing;
		add(versionShit);
		#end

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if (fullLength != null)
		{
			fullLength.cameras = [camHUD];
		}
		#if !SHOWCASEVIDEO
		botplayTxt.cameras = [camHUD];
		#end

		if (ClientPrefs.middleScroll)
		{
			timerGoMiddlescroll(false);
		}

		startingSong = true;
		
		noteTypeMap.clear();
		noteTypeMap = null;

		eventPushedMap.clear();
		eventPushedMap = null;

		if (eventNotes.length > 1)
		{
			eventNotes.sort(sortByTime);
		}

		var daSong:String = Paths.formatToSongPath(curSong);

		startCountdown();

		ClientPrefs.middleScroll = storageLol;

		recalculateRating();

		if (ClientPrefs.hitsoundVolume > 0)
		{
			precacheList.set('hitsound', 'sound');
		}

		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		precacheList.set("mus_lunch_break", 'music');

		precacheList.set('alphabet', 'image');

		precacheList.set('ui/splashes/0', 'image');
		precacheList.set('ui/splashes/1', 'image');
		precacheList.set('ui/splashes/2', 'image');
		precacheList.set('ui/splashes/3', 'image');
	
		#if desktop
		DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
		#end

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.create();

		cacheCountdown();

		cachePopUpScore();

		for (key => type in precacheList)
		{
			switch (type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		
		MarkHeadTransition.nextCamera = camOther;

		if (eventNotes.length < 1)
		{
			checkEventNote();
		}

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	
	function makeStage(curStage:String)
	{
		#if DEVELOPERBUILD
		var stagePerf = new Perf("Stage Creation");
		#end

		switch (curStage)
		{
			case 'mark':
				angry = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/angry'));
				angry.scale.set(2, 2);
				angry.updateHitbox();
				angry.antialiasing = false;
				add(angry);
				
				angryDadCover = new FlxSprite(600, -320).loadGraphic(Paths.image('destitution/angry_dadcover'));
				angryDadCover.scale.set(2, 2);
				angryDadCover.updateHitbox();
				angryDadCover.antialiasing = false;
				angryDadCover.visible = false;

				zamboni = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/zamboni'));
				zamboni.scale.set(2, 2);
				zamboni.updateHitbox();
				zamboni.antialiasing = false;
				add(zamboni);

				cryptehB = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/cryptehB'));
				cryptehB.scale.set(2, 2);
				cryptehB.updateHitbox();
				cryptehB.antialiasing = false;
				add(cryptehB);

				office = new FlxSprite(-680, -320);
				office.frames = Paths.getSparrowAtlas('destitution/bg_rulez_crypteh');
				office.animation.addByPrefix("idle", "ROOLZ ARE FOUR TOOLZ", 24, false);
				office.animation.play("idle", true);
				office.animation.pause();
				office.scale.set(2, 2);
				office.updateHitbox();
				office.antialiasing = false;
				add(office);

				annoyed = new FlxSprite(-680, -320);
				annoyed.frames = Paths.getSparrowAtlas('destitution/bg_annoyed');
				annoyed.animation.addByPrefix("idle", "whale world to somewhat peterbed man", 24, false);
				annoyed.animation.play("idle", true);
				annoyed.animation.pause();
				annoyed.scale.set(2, 2);
				annoyed.updateHitbox();
				annoyed.antialiasing = false;
				add(annoyed);

				liek = new FlxSprite(-680, -320);
				liek.frames = Paths.getSparrowAtlas('destitution/bg_item_whale');
				liek.animation.addByPrefix("idle", "ITEM MAN TO THE WHALES OF THE WORLD", 24, false);
				liek.animation.play("idle", true);
				liek.animation.pause();
				liek.scale.set(2, 2);
				liek.updateHitbox();
				liek.antialiasing = false;
				add(liek);

				space = new FlxSprite(-680, -320);
				space.loadGraphic(Paths.image("destitution/space"));
				space.antialiasing = false;
				space.scale.set(8, 8);
				space.updateHitbox();
				space.screenCenter();
				space.scrollFactor.set(0.5, 0.5);
				space.visible = false;
				add(space);

				spaceWiggle = new WiggleEffect();
				spaceWiggle.effectType = WiggleEffectType.DREAMY;
				spaceWiggle.waveAmplitude = 0.2;
				spaceWiggle.waveFrequency = 7;
				spaceWiggle.waveSpeed = 1;
				space.shader = spaceWiggle.shader;

				spaceItems = new FlxTypedGroup<FlxSprite>();
				for (i in 0...7)
				{
					var fucksprit:FlxSprite = new FlxSprite(CoolUtil.randomLogic.float(-32, 1248), CoolUtil.randomLogic.float(-32, 688));
					fucksprit.loadGraphic(Paths.image("destitution/itemShit/" + Std.string(CoolUtil.randomVisuals.int(0, 10))));
					fucksprit.antialiasing = false;
					fucksprit.ID = i;
					fucksprit.scale.set(2, 2);
					fucksprit.updateHitbox();
					fucksprit.scrollFactor.set(CoolUtil.randomLogic.float(0.05, 0.2), CoolUtil.randomLogic.float(0.05, 0.2));
					spaceItems.add(fucksprit);
				}
				add(spaceItems);
				spaceItems.visible = false;

				blackVoid = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
				blackVoid.scale.set(2560, 2560);
				blackVoid.updateHitbox();
				blackVoid.screenCenter();
				blackVoid.scrollFactor.set();
				add(blackVoid);
				blackVoid.visible = false;

				ploinky = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/ploinky'));
				ploinky.antialiasing = false;
				ploinky.scale.set(2, 2);
				ploinky.updateHitbox();
				add(ploinky);

				starting = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/start'));
				starting.antialiasing = false;
				starting.scale.set(2, 2);
				starting.updateHitbox();
				add(starting);

				ploinkyTransition = new FlxSprite();
				ploinkyTransition.frames = Paths.getSparrowAtlas('destitution/mark_ploinky_transition');
				ploinkyTransition.animation.addByPrefix('1', '1', 24, false);
				ploinkyTransition.animation.addByPrefix('2', '2', 24, false);
				ploinkyTransition.animation.addByPrefix('3', '3', 24, false);
				ploinkyTransition.animation.addByPrefix('4', '4', 24, false);
				ploinkyTransition.animation.play('1', true);
				ploinkyTransition.camera = camHUD;
				add(ploinkyTransition);
				ploinkyTransition.visible = false;

				rulezGuySlideScaleWorldFunnyClips = new FlxSprite(0, 0);
				rulezGuySlideScaleWorldFunnyClips.frames = Paths.getSparrowAtlas('destitution/rulez_guy_screen_transition');
				rulezGuySlideScaleWorldFunnyClips.animation.addByPrefix("intro", "anim part 1", 24, false);
				rulezGuySlideScaleWorldFunnyClips.animation.addByPrefix("zoom", "anim part 2", 24, false);
				rulezGuySlideScaleWorldFunnyClips.animation.play("intro", true);
				rulezGuySlideScaleWorldFunnyClips.animation.pause();
				rulezGuySlideScaleWorldFunnyClips.scale.set(2, 2);
				rulezGuySlideScaleWorldFunnyClips.updateHitbox();
				rulezGuySlideScaleWorldFunnyClips.setPosition(0, 0);
				rulezGuySlideScaleWorldFunnyClips.antialiasing = false;
				rulezGuySlideScaleWorldFunnyClips.cameras = [camHUD];
				add(rulezGuySlideScaleWorldFunnyClips);

				zamMarkCamFlipShit = new FlxSprite(0, 0);
				zamMarkCamFlipShit.frames = Paths.getSparrowAtlas('destitution/cam_flip_lol');
				zamMarkCamFlipShit.animation.addByPrefix("idle", "idle", 24, false);
				zamMarkCamFlipShit.animation.play("idle", true);
				zamMarkCamFlipShit.animation.pause();
				zamMarkCamFlipShit.antialiasing = false;
				zamMarkCamFlipShit.cameras = [camHUD];
				add(zamMarkCamFlipShit);
				zamMarkCamFlipShit.visible = false;

				bgPlayer = new Character(starting.x + 1048, starting.y + 576, "bg-player", false, false);
				bgPlayer.canDance = false;
				bgPlayerWalkTarget = bgPlayer.x;
				bgPlayer.x -= 1400;
				bgPlayer.playAnim("walk", true);
				add(bgPlayer);

				cuttingSceneThing = new FlxSprite();
				cuttingSceneThing.frames = Paths.getSparrowAtlas("ui/cutting_scene");
				cuttingSceneThing.animation.addByPrefix("idle", "idle", 24, true);
				cuttingSceneThing.animation.play("idle", true);
				cuttingSceneThing.cameras = [camHUD];
				cuttingSceneThing.screenCenter();
				add(cuttingSceneThing);
				cuttingSceneThing.visible = false;

				precacheList.set('destitution/start', 'image');
				precacheList.set('destitution/mark_ploinky_transition', 'image');
				precacheList.set('destitution/ploinky', 'image');
				precacheList.set('destitution/bg_item_whale', 'image');
				precacheList.set('destitution/space', 'image');
				precacheList.set('destitution/itemShit/0', 'image');
				precacheList.set('destitution/itemShit/1', 'image');
				precacheList.set('destitution/itemShit/2', 'image');
				precacheList.set('destitution/itemShit/3', 'image');
				precacheList.set('destitution/itemShit/4', 'image');
				precacheList.set('destitution/itemShit/5', 'image');
				precacheList.set('destitution/itemShit/6', 'image');
				precacheList.set('destitution/itemShit/7', 'image');
				precacheList.set('destitution/itemShit/8', 'image');
				precacheList.set('destitution/itemShit/9', 'image');
				precacheList.set('destitution/itemShit/10', 'image');
				precacheList.set('ui/cutting_scene', 'image');
				precacheList.set('destitution/bg_annoyed', 'image');
				precacheList.set('destitution/rulez_guy_screen_transition', 'image');
				precacheList.set('destitution/bg_rulez_crypteh', 'image');
				precacheList.set('destitution/cryptehB', 'image');
				precacheList.set('destitution/zamboni', 'image');
				precacheList.set('destitution/cam_flip_lol', 'image');
				precacheList.set('destitution/angry', 'image');
				precacheList.set('destitution/angry_dadcover', 'image');
			case 'superseded':
				tweeningCam = true;
				camHUD.zoom = 15;

				starting = new FlxSprite(-574, 96).loadGraphic(Paths.image('superseded/bg'));
				starting.antialiasing = false;
				add(starting);

				supersededIntro = new FlxSprite(0, 0);
				supersededIntro.frames = Paths.getSparrowAtlas("superseded/superseded_time");
				supersededIntro.animation.addByPrefix("idle", "idle", 24, true);
				supersededIntro.animation.addByPrefix("open", "open", 24, false);
				supersededIntro.antialiasing = false;
				supersededIntro.animation.play("idle", true);
				supersededIntro.scrollFactor.set();

				spaceWiggle = new WiggleEffect();
				spaceWiggle.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
				spaceWiggle.waveAmplitude = 0.25;
				spaceWiggle.waveFrequency = 8;
				spaceWiggle.waveSpeed = 2;
			case 'dsides':
				var pureWhiteAbyss:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
				pureWhiteAbyss.scale.set(2560, 2560);
				pureWhiteAbyss.updateHitbox();
				pureWhiteAbyss.screenCenter();
				pureWhiteAbyss.scrollFactor.set();
				add(pureWhiteAbyss);

				sky = new FlxSprite().loadGraphic(Paths.image('dsides/sky'));
				sky.scale.set(2, 2);
				sky.updateHitbox();
				sky.antialiasing = false;
				add(sky);
				sky.screenCenter();
				sky.scrollFactor.set();

				backing = new FlxSprite().loadGraphic(Paths.image('dsides/backing'));
				backing.scale.set(2, 2);
				backing.updateHitbox();
				backing.antialiasing = false;
				add(backing);
				backing.screenCenter();
				backing.scrollFactor.set(0.5, 0.5);

				starting = new FlxSprite().loadGraphic(Paths.image('dsides/front'));
				starting.scale.set(2, 2);
				starting.updateHitbox();
				starting.antialiasing = false;
				add(starting);
				starting.screenCenter();

				karmScaredy = new FlxSprite(starting.x + 42, starting.y + 612);
				karmScaredy.frames = Paths.getSparrowAtlas("dsides/karm_scaredy");
				karmScaredy.animation.addByPrefix("idle", "idle", 24, false);
				karmScaredy.animation.play("idle", true);
				karmScaredy.scrollFactor.set(0.9, 0.9);
				add(karmScaredy);
				karmScaredy.visible = false;

				chefTable = new FlxSprite().loadGraphic(Paths.image('dsides/chefTable'));
				chefTable.scale.set(4, 4);
				chefTable.updateHitbox();
				chefTable.antialiasing = false;
				chefTable.screenCenter();
				chefTable.scrollFactor.set(1.6, 0.55);
				chefTable.y -= 4000;

				chefBanner = new FlxSprite().loadGraphic(Paths.image('dsides/chefBanner'));
				chefBanner.scale.set(4, 4);
				chefBanner.updateHitbox();
				chefBanner.antialiasing = false;
				chefBanner.screenCenter();
				chefBanner.scrollFactor.set(1.25, 0.75);
				chefBanner.y -= 4000;

				chefCurtains = new FlxClothSprite();
				chefCurtains.loadGraphic(Paths.image('dsides/chefCurtains'));
				chefCurtains.scale.set(4, 4);
				chefCurtains.meshScale.set(4, 4);
				chefCurtains.setMesh(16, 16, 0, 0, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
				chefCurtains.iterations = 8;
				chefCurtains.maxVelocity.set(50, 50);
				chefCurtains.meshVelocity.x = 50;
				chefCurtains.meshVelocity.y = 50;
				chefCurtains.updateHitbox();
				chefCurtains.antialiasing = false;
				chefCurtains.screenCenter();
				chefCurtains.x -= 512;
				chefCurtains.y -= 648;
				chefCurtains.y -= 256;
				chefCurtains.scrollFactor.set(0.1, 0.1);
				chefCurtains.y -= 4000;

				lightningStrikes = new FlxSprite().makeGraphic(1, 1, FlxColor.fromRGB(255, 241, 185));
				lightningStrikes.scale.set(5000, 5000);
				lightningStrikes.updateHitbox();

				if (ClientPrefs.shaders)
				{
					lightningStrikes.blend = BlendMode.ADD;
				}

				lightningStrikes.screenCenter();
				lightningStrikes.scrollFactor.set();
				lightningStrikes.alpha = 0;

				funnyBgColors = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
				funnyBgColors.scale.set(FlxG.width * 3, FlxG.width * 3);
				funnyBgColors.updateHitbox();
				funnyBgColors.screenCenter();
				funnyBgColors.scrollFactor.set();
				add(funnyBgColors);
				funnyBgColors.alpha = 0;
				funnyBgColors.color = FlxColor.BLACK;

				if (ClientPrefs.shaders)
				{
					funnyBgColors.blend = BlendMode.MULTIPLY;
				}

				train = new FlxSprite().loadGraphic(Paths.image("dsides/train funny"));
				train.scale.set(10, 10);
				train.updateHitbox();
				train.antialiasing = false;
				train.screenCenter();
				add(train);
				train.visible = false;

				precacheList.set('dsides/karm_scaredy', 'image');
				precacheList.set('dsides/dark backing', 'image');
				precacheList.set('dsides/dark front', 'image');
				precacheList.set('dsides/dark sky', 'image');
				precacheList.set('dsides/train funny', 'image');
				precacheList.set('dsides/iliBacking', 'image');
				precacheList.set('dsides/iliRoom', 'image');
				precacheList.set('dsides/iliSky', 'image');
				precacheList.set('dsides/chefBanner', 'image');
				precacheList.set('dsides/chefCurtains', 'image');
				precacheList.set('dsides/chefTable', 'image');
				precacheList.set('dsides/dougBacking', 'image');
				precacheList.set('dsides/dougRoom', 'image');
				precacheList.set('dsides/dougSky', 'image');
				precacheList.set('dsides/skyworldSky', 'image');
				precacheList.set('dsides/skyworldStage', 'image');

				precacheList.set('dsides/karmFlees', 'sound');
				precacheList.set('dsides/storm0', 'sound');
				precacheList.set('dsides/storm1', 'sound');
				precacheList.set('dsides/storm2', 'sound');
				precacheList.set('dsides/storm3', 'sound');
			case 'eggshells':
				cabinBg = new FlxSprite();
				cabinBg.frames = Paths.getSparrowAtlas('eggshells/cabin');
				cabinBg.animation.addByPrefix('idle', 'idle', 24, true);
				cabinBg.animation.play('idle', true);
				cabinBg.scale.set(2, 2);
				cabinBg.updateHitbox();
				cabinBg.screenCenter();
				add(cabinBg);
			case 'bucks':
				var skyish = new FlxSprite(-458, -413);
				skyish.loadGraphic(Paths.image('bucks/skybox'));
				skyish.antialiasing = ClientPrefs.globalAntialiasing;
				skyish.scrollFactor.set();
				add(skyish);

				var tvs = new FlxSprite(-610, -750);
				tvs.frames = Paths.getSparrowAtlas('bucks/tvs');
				tvs.animation.addByPrefix('idle', 'many tvs flashloop', 24, true);
				tvs.animation.play('idle');
				tvs.scale.set(2, 2);
				tvs.updateHitbox();
				tvs.antialiasing = ClientPrefs.globalAntialiasing;
				tvs.scrollFactor.set(0.2, 0.1);
				add(tvs);

				var lump = new FlxSprite(-350, 270).loadGraphic(Paths.image('bucks/lump'));
				lump.antialiasing = ClientPrefs.globalAntialiasing;
				lump.scrollFactor.set(0.45, 0.7);
				add(lump);

				stockboy = new Character(-245, 275, 'brokerboy', false, false);
				stockboy.antialiasing = ClientPrefs.globalAntialiasing;
				stockboy.playAnim('walk', true);
				stockboy.animation.pause();
				stockboy.scrollFactor.set(0.45, 0.7);
				add(stockboy);
				
				var floor = new FlxSprite(-445, 200).loadGraphic(Paths.image('bucks/floor'));
				floor.antialiasing = ClientPrefs.globalAntialiasing;
				add(floor);

				var screen = new FlxSprite(30, -250).loadGraphic(Paths.image('bucks/screen'));
				screen.antialiasing = ClientPrefs.globalAntialiasing;
				add(screen);

				for (i in 0...7)
				{
					bucksBars[i] = new BucksGraphBar(screen.x + 200 + (i * 120), 5);
					add(bucksBars[i]);
				}

				var yais = new FlxSprite(80, -235);
				yais.frames = Paths.getSparrowAtlas('bucks/youre_accuracy_inc_stock');
				yais.animation.addByPrefix('idle', 'yais', 24, true);
				yais.animation.play('idle');
				yais.antialiasing = ClientPrefs.globalAntialiasing;
				add(yais);
		}

		#if DEVELOPERBUILD
		stagePerf.print();
		#end
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed;

			for (note in notes)
			{
				note.resizeByRatio(ratio);
			}

			for (note in unspawnNotes)
			{
				note.resizeByRatio(ratio);
			}
		}

		songSpeed = value;
		noteKillOffset = 350 / songSpeed;

		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if (generatedMusic)
		{
			if (vocals != null)
			{
				vocals.pitch = value;
			}

			if (opponentVocals != null)
			{
				opponentVocals.pitch = value;
			}

			FlxG.sound.music.pitch = value;
		}

		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;

		return value;
	}

	public function reloadHealthBarColors()
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}
			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}
			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{
			char.setPosition(GF_X, GF_Y);
			char.danceEveryNumBeats = 2;
		}

		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}
	
	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:FlxVideoSprite = new FlxVideoSprite();
		video.play(filepath);
		video.animation.finishCallback = function(fff:String)
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
		{
			endSong();
		}
		else
		{
			startCountdown();
		}
	}

	function cacheCountdown()
	{
		Paths.image('ui/songIntro');
		
		Paths.sound('intro' + songObj.introType + '/intro3' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/intro2' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/intro1' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			return;
		}

		inCutscene = false;

		if (skipCountdown || startOnTime > 0)
		{
			skipArrowStartTween = true;
		}

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;

		Conductor.songPosition = -Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (startOnTime < 0)
		{
			startOnTime = 0;
		}

		if (startOnTime > 0)
		{
			clearNotesBefore(startOnTime);
			setSongTime(startOnTime - 350);

			return;
		}
		else if (skipCountdown)
		{
			setSongTime(0);

			return;
		}

		songIntro = new FlxSprite();
		songIntro.frames = Paths.getSparrowAtlas('ui/songIntro');
		songIntro.animation.addByPrefix('3', '3', 24, false);
		songIntro.animation.addByPrefix('2', '2', 24, false);
		songIntro.animation.addByPrefix('1', '1', 24, false);
		songIntro.animation.addByPrefix('go', 'go', 24, false);
		songIntro.animation.play("3", true);
		songIntro.scale.set(2, 2);
		songIntro.updateHitbox();
		songIntro.screenCenter();
		songIntro.cameras = [camHUD];
		add(songIntro);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
		{
			if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
			{
				gf.dance();
			}

			if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
			{
				boyfriend.dance();
			}

			if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
			{
				dad.dance();
			}

			switch (swagCounter)
			{
				case 0:
					songIntro.animation.play("3", true);

					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro3' + introSoundsSuffix), 0.6);
				case 1:
					songIntro.animation.play("2", true);

					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro2' + introSoundsSuffix), 0.6);
				case 2:
					songIntro.animation.play("1", true);

					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro1' + introSoundsSuffix), 0.6);
				case 3:
					songIntro.animation.play("go", true);

					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'introGo' + introSoundsSuffix), 0.6);

					FlxTween.tween(songIntro, {alpha: 0}, Conductor.crochet / 1000,
					{
						ease: FlxEase.cubeInOut,
						startDelay: 0.1,
						onComplete: function(twn:FlxTween)
						{
							remove(songIntro);
							songIntro.destroy();
						}
					});

					if(SONG.song.toLowerCase() == "d-stitution" || SONG.song.toLowerCase() == "d-stitution-erect")
					{
						dad.visible = true;
						dad.canDance = false;
						dad.playAnim("kar", true);
						dad.animation.finishCallback = function fff(st:String)
						{
							dad.animation.finishCallback = null;
							dad.canDance = true;
							dad.dance();
							dad.animation.finish();
						}
					}
			}

			notes.forEachAlive(function(note:Note)
			{
				if(ClientPrefs.opponentStrums || note.mustPress)
				{
					note.copyAlpha = false;
					note.alpha = note.multAlpha;

					if(ClientPrefs.middleScroll && !note.mustPress)
					{
						note.alpha *= 0.35;
					}
				}
			});

			swagCounter += 1;
		}, 5);
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;

		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];

			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}

			--i;
		}

		i = notes.length - 1;

		while (i >= 0)
		{
			var daNote:Note = notes.members[i];

			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}

			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true)
		+ ' | Misses: ' + songMisses
		+ ' | Rating: ' + ratingName
		+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}

			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;

			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2,
			{
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0)
		{
			time = 0;
		}

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
		}

		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		try
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}
		catch (e:Dynamic)
		{
			throw "Missing instrumental!";
		}

		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}

		startOnTime = 0;

		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		songLength = FlxG.sound.music.length;

		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		if (fullLength != null)
		{
			FlxTween.tween(fullLength, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

			if (fullLength != null)
			{
					fullLength.text = FlxStringUtil.formatTime(Math.floor(songLength / 1000), false);
			}
		}

		#if desktop
		DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''), true, songLength);
		#end
	}

	public function generateSong(dataPath:String):Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			var playerVocals = Paths.voices(songData.song, 'Player');
			vocals.loadEmbedded(playerVocals);
				
			var oppVocals = Paths.voices(songData.song, 'Opponent');
			if (oppVocals != null)
				opponentVocals.loadEmbedded(oppVocals);
		}
		catch (e:Dynamic)
		{
			throw "Player vocals and/or Opponent vocals not found!";
		}

		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0;

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');

		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;

			for (event in eventsData)
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;

				if (unspawnNotes.length > 0)
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				}
				else
				{
					oldNote = null;
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];

				if(!Std.isOfType(songNotes[3], String))
				{
					swagNote.noteType = ChartingState.noteTypeList[songNotes[3]];
				}

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);

				if(floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;

							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;

					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}

			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];

				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};

				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	public function sectionIntroThing(displayName:String)
	{
		songHasSections = true;
		sectionNum++;
		health = 1;

		if(sectNameText == null)
		{
			sectText = new FlxText(0, 0, FlxG.width, "SECTION 2", 96);
			sectText.setFormat(Paths.font(songFont), 96 * 2, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			sectText.borderSize = 1.5;
			sectText.screenCenter();
			sectText.y -= 400;
			sectText.alpha = 0;
			sectText.cameras = [camHUD];
			add(sectText);
			sectNameText = new FlxText(0, 0, FlxG.width, displayName.toUpperCase(), 48);
			sectNameText.setFormat(Paths.font(songFont), 48 * 2, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			sectNameText.borderSize = 1.5;
			sectNameText.screenCenter();
			sectNameText.y -= 100;
			sectNameText.alpha = 0;
			sectNameText.cameras = [camHUD];
			add(sectNameText);
		}

		sectText.text = "SECTION " + sectionNum;
		sectNameText.text = displayName.toUpperCase();

		sectText.screenCenter();
		sectText.y -= 350;
		sectNameText.screenCenter();
		sectNameText.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		sectNameText.y -= 150;

		FlxTween.tween(sectText, {alpha: 1, y: sectText.y + 200}, 0.75, {ease: FlxEase.backOut});
		FlxTween.tween(sectNameText, {alpha: 1, y: sectNameText.y + 200}, 0.75, {ease: FlxEase.backOut});

		var gghg:FlxTimer = new FlxTimer().start(2.5, function fggjg(ss:FlxTimer)
		{
			FlxTween.tween(sectText, {alpha: 0, y: sectText.y + 200}, 0.75, {ease: FlxEase.backIn});
			FlxTween.tween(sectNameText, {alpha: 0, y: sectNameText.y + 200}, 0.75, {ease: FlxEase.backIn});
		});
	}
	
	public function lightningBg()
	{
		sky.loadGraphic(Paths.image("dsides/dark sky"));
		backing.loadGraphic(Paths.image("dsides/dark backing"));
		starting.loadGraphic(Paths.image("dsides/dark front"));
	}

	public function unLightningBg()
	{
		sky.loadGraphic(Paths.image("dsides/sky"));
		backing.loadGraphic(Paths.image("dsides/backing"));
		starting.loadGraphic(Paths.image("dsides/front"));
		strikeyStrikes = false;
	}

	public function eventPushed(event:EventNote)
	{
		switch(event.event)
		{
			case 'Change Character':
				var charType:Int = 0;

				switch(event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);

						if(Math.isNaN(charType))
						{
							charType = 0;
						}
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;

			if (player < 1)
			{
				if (!ClientPrefs.opponentStrums)
				{
					targetAlpha = 0;
				}
				else if (ClientPrefs.middleScroll)
				{
					targetAlpha = 0.35;
				}
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;

			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if (i > 1)
					{
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
			{
				startTimer.active = false;
			}
			
			if (finishTimer != null && !finishTimer.finished)
			{
				finishTimer.active = false;
			}

			if (songSpeedTween != null)
			{
				songSpeedTween.active = false;
			}

			var chars:Array<Character> = [boyfriend, gf, dad];

			for (char in chars)
			{
				if(char != null && char.colorTween != null)
				{
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
			{
				startTimer.active = true;
			}

			if (finishTimer != null && !finishTimer.finished)
			{
				finishTimer.active = true;
			}

			if (songSpeedTween != null)
			{
				songSpeedTween.active = true;
			}

			var chars:Array<Character> = [boyfriend, gf, dad];

			for (char in chars)
			{
				if(char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}

			for (timer in modchartTimers)
			{
				timer.active = true;
			}

			paused = false;

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
		{
			return;
		}

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.pitch = playbackRate;
		}

		vocals.play();
		opponentVocals.play();
	}

	override public function update(elapsed:Float)
	{
		elapsedTotal += elapsed;

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);

			var targets:Array<Float> = [FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal)];

			//i fucking hate math
			/*if (pixelPerfectishCamera)
			{
				var backup:Array<Float> = targets;

				targets = [((Math.floor(backup[0]) + 2 / 2) / 2) * 2, ((Math.floor(backup[1]) + 2 / 2) / 2) * 2];

				//if (targets[0] % 2 == 0)
				//{
				camFollowPos.setPosition(targets[0], targets[1]);
				//}
			}
			else
			{*/
				camFollowPos.setPosition(targets[0], targets[1]);
			//}
		}

		if (ref != null)
		{
			if (FlxG.keys.justPressed.P)
			{
				ref.visible = !ref.visible;
			}
		}

		if (spaceWiggle != null)
		{
			spaceWiggle.update(elapsed);
		}

		if (chefCurtains != null)
		{
			if (chefCurtains.active)
			{
				chefCurtains.meshVelocity.x = FlxMath.lerp(0, chefCurtains.meshVelocity.x, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				chefCurtains.meshVelocity.y = FlxMath.lerp(0, chefCurtains.meshVelocity.y, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}
		}
		
		if (startedCountdown && generatedMusic && bucksBars[5] != null)
		{
			bucksBarUpdateCountdown -= 1 * elapsed;

			if (bucksBarUpdateCountdown <= 0)
			{
				bucksBarUpdateCountdown = CoolUtil.randomVisuals.float(2.75, 6.5);
				bucksBarHistoryFuck = bucksBarHistoryFuck.slice(1, 7);

				if (cpuControlled || (combo == 0 && songMisses == 0))
				{
					bucksBarHistoryFuck.push(9);
				}
				else
				{
					bucksBarHistoryFuck.push(Std.int((ratingPercent * 10) - 1));
				}

				for (i in 0...7)
				{
					bucksBars[i].changeGraphPos(bucksBarHistoryFuck[i]);
				}
			}
		}

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}
		}

		if (health > 2)
		{
			health = 2;
		}

		smoothenedHealth = FlxMath.lerp(smoothenedHealth, health, CoolUtil.boundTo(elapsed * 13, 0, 1));

		healthBar.value = smoothenedHealth;

		updateIconStuff(elapsed);

		super.update(elapsed);

		if (dad != null)
		{
			if (dad.animation.curAnim != null)
			{
				if (dad.animation.curAnim.name.toLowerCase().startsWith("sing"))
				{
					if (dad.singDuration >= 10)
					{
						if (dad.animation.curAnim.finished)
						{
							dad.dance(SONG.notes[curSection].altAnim);
							dad.holdTimer = 0;

							if (!dad.animation.curAnim.looped)
							{
								dad.animation.finish();
							}
						}
					}
				}
			}
		}

		if (boyfriend != null)
		{
			if (boyfriend.animation.curAnim != null)
			{
				if (boyfriend.animation.curAnim.name.toLowerCase().startsWith("sing"))
				{
					if (boyfriend.singDuration >= 10)
					{
						if (boyfriend.animation.curAnim.finished)
						{
							boyfriend.dance();
							boyfriend.holdTimer = 0;

							if (!boyfriend.animation.curAnim.looped)
							{
								boyfriend.animation.finish();
							}
						}
					}
				}
			}
		}

		if (spaceTime)
		{
			dad.y += Math.sin(elapsedTotal) * 0.3;
			boyfriend.y += Math.sin(elapsedTotal) * 0.3;

			dad.x += Math.cos(elapsedTotal) * 0.3;
			boyfriend.x += Math.cos(elapsedTotal) * 0.3;

			dad.angle += Math.sin(elapsedTotal) * 0.1;
			boyfriend.angle += Math.sin(elapsedTotal) * 0.1;

			for (i in spaceItems.members)
			{
				i.angle += 2;

				if (i.ID % 2 == 0)
				{
					i.x += Math.sin(elapsedTotal) * 0.4;
				}
				else
				{
					i.y += Math.sin(elapsedTotal) * 0.4;
				}
			}
		}

		if (whaleFuckShit)
		{
			dad.y += ((Math.cos(elapsedTotal * 4)));
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			openPauseMenu();
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(dad.curCharacter));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
			{
				startSong();
			}
			else if (!startedCountdown)
			{
				Conductor.songPosition = -Conductor.crochet * 5;
			}
		}
		else
		{
			if (!paused && FlxG.sound.music != null)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if (updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;

					if (curTime < 0)
					{
						curTime = 0;
					}

					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);

					if (ClientPrefs.timeBarType == 'Time Elapsed')
					{
						songCalc = curTime;
					}

					var secondsTotal:Int = Math.floor(songCalc / 1000);

					if (secondsTotal < 0)
					{
						secondsTotal = 0;
					}

					if (ClientPrefs.timeBarType != 'Song Name')
					{
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					}
				}
			}
		}

		if(!tweeningCam)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + camZoomAdditive, FlxG.camera.zoom, util.CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, util.CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
		}

		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;

			if (songSpeed < 1)
			{
				time /= songSpeed;
			}

			if (unspawnNotes[0].multSpeed < 1)
			{
				time /= unspawnNotes[0].multSpeed;
			}

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && FlxG.sound.music != null)
		{
			if(!inCutscene)
			{
				if (!cpuControlled)
				{
					keyShit();
				}
				else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}

				if(startedCountdown)
				{
					var fakeCrochet:Float = (60 / SONG.bpm) * 1000;

					notes.forEachAlive(function(daNote:Note)
					{
						var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;

						if(!daNote.mustPress)
						{
							strumGroup = opponentStrums;
						}

						var strumX:Float = strumGroup.members[daNote.noteData].x;
						var strumY:Float = strumGroup.members[daNote.noteData].y;
						var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
						var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
						var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
						var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

						strumX += daNote.offsetX;
						strumY += daNote.offsetY;
						strumAngle += daNote.offsetAngle;
						strumAlpha *= daNote.multAlpha;

						if (strumScroll)
						{
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}
						else
						{
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}

						var angleDir = strumDirection * Math.PI / 180;

						if (daNote.copyAngle)
						{
							daNote.angle = strumDirection - 90 + strumAngle;
						}

						if(daNote.copyAlpha)
						{
							daNote.alpha = strumAlpha;
						}

						if(daNote.copyX)
						{
							daNote.x = strumX + Math.cos(angleDir) * daNote.distance;
						}

						if(daNote.copyY)
						{
							daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

							if(strumScroll && daNote.isSustainNote)
							{
								if (daNote.animation.curAnim.name.endsWith('end'))
								{
									daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
									daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
									daNote.y -= 19;
								}

								daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
								daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
							}
						}

						if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
						{
							opponentNoteHit(daNote);
						}

						if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit)
						{
							if(daNote.isSustainNote)
							{
								if(daNote.canBeHit)
								{
									goodNoteHit(daNote);
								}
							}
							else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote)
							{
								goodNoteHit(daNote);
							}
						}

						var center:Float = strumY + Note.swagWidth / 2;
						if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
							(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							if (strumScroll)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}

						if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
						{
							if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
							{
								noteMiss(daNote);
							}

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}
				else
				{
					notes.forEachAlive(function(daNote:Note)
					{
						daNote.canBeHit = false;
						daNote.wasGoodHit = false;
					});
				}
			}
			checkEventNote();
		}
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		FlxG.sound.play(Paths.sound('pause'));

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if desktop
		DiscordClient.changePresence(detailsPausedText, songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
		Application.current.window.title = CoolUtil.appTitleString + " - PAUSED on " + songObj.songNameForDisplay;
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;
		#if desktop
		Application.current.window.title = CoolUtil.appTitleString + " - Chart Editor";
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			deathCounter++;

			paused = true;

			vocals.stop();
			opponentVocals.stop();
			FlxG.sound.music.stop();

			persistentUpdate = false;
			persistentDraw = false;

			for (tween in modchartTweens)
			{
				tween.active = true;
			}

			for (timer in modchartTimers)
			{
				timer.active = true;
			}

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

			#if desktop
			DiscordClient.changePresence("Game Over", songObj.songNameForDisplay, SONG.song.toLowerCase().replace('-erect', ''));
			Application.current.window.title = CoolUtil.appTitleString + " - GAME OVER on " + songObj.songNameForDisplay;
			#end
			isDead = true;
			return true;
		}

		return false;
	}

	public function checkEventNote()
	{
		while(eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;

			if(Conductor.songPosition < leStrumTime)
			{
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
			{
				value1 = eventNotes[0].value1;
			}

			var value2:String = '';
			if(eventNotes[0].value2 != null)
			{
				value2 = eventNotes[0].value2;
			}

			triggerEventNote(eventNotes[0].event, value1, value2);

			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);

		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch(eventName)
		{
			case 'Hey!':
				var value:Int = 2;

				switch(value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);

				if(Math.isNaN(time) || time <= 0)
				{
					time = 0.6;
				}

				if(value != 0)
				{
					if(dad.curCharacter.startsWith('gf'))
					{
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else if (gf != null)
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}

				if(value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}
			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);

				if(Math.isNaN(value) || value < 1)
				{
					value = 1;
				}

				gfSpeed = value;
			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms)
				{
					var camZoom:Float = Std.parseFloat(value1);

					if(Math.isNaN(camZoom))
					{
						camZoom = 0.015;
					}

					var hudZoom:Float = Std.parseFloat(value2);

					if(Math.isNaN(hudZoom))
					{
						hudZoom = 0.03;
					}

					FlxG.camera.zoom += camZoom;

					camHUD.zoom += hudZoom;
				}
			case 'Play Animation':
				var char:Character = dad;

				switch(value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);

						if(Math.isNaN(val2))
						{
							val2 = 0;
						}

						switch(val2)
						{
							case 1:
								char = boyfriend;
							case 2:
								char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}
			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);

					if(Math.isNaN(val1))
					{
						val1 = 0;
					}

					var val2:Float = Std.parseFloat(value2);

					if(Math.isNaN(val2))
					{
						val2 = 0;
					}

					isCameraOnForcedPos = false;

					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
					{
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}
			case 'Alt Idle Animation':
				var char:Character = dad;

				switch(value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);

						if(Math.isNaN(val))
						{
							val = 0;
						}

						switch(val)
						{
							case 1:
								char = boyfriend;
							case 2:
								char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}
			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];

				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;

					if(split[0] != null)
					{
						duration = Std.parseFloat(split[0].trim());
					}

					if(split[1] != null)
					{
						intensity = Std.parseFloat(split[1].trim());
					}

					if(Math.isNaN(duration))
					{
						duration = 0;
					}

					if(Math.isNaN(intensity))
					{
						intensity = 0;
					}

					if(duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}
			case 'Change Character':
				var charType:Int = 0;

				switch(value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);

						if(Math.isNaN(charType))
						{
							charType = 0;
						}
				}

				switch(charType)
				{
					case 0:
						if(boyfriend.curCharacter != value2)
						{
							if(!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;

							iconP1.changeIcon(boyfriend.healthIcon);
						}
					case 1:
						if(dad.curCharacter != value2)
						{
							if(!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');

							var lastAlpha:Float = dad.alpha;

							dad.alpha = 0.00001;
							dad = dadMap.get(value2);

							if(!dad.curCharacter.startsWith('gf'))
							{
								if(wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if(gf != null)
							{
								gf.visible = false;
							}

							dad.alpha = lastAlpha;

							iconP2.changeIcon(dad.healthIcon);
						}
					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
				{
					return;
				}

				var val1:Float = Std.parseFloat(value1);

				if(Math.isNaN(val1))
				{
					val1 = 1;
				}

				var val2:Float = Std.parseFloat(value2);

				if(Math.isNaN(val2))
				{
					val2 = 0;
				}

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
	}

	public function moveCameraSection():Void
	{
		if (disallowCamMove)
		{
			return;
		}

		if (SONG.notes[curSection] == null)
		{
			return;
		}

		if (centerCamOnBg)
		{
			camFollow.set(angry.getMidpoint().x, angry.getMidpoint().y);
			camZoomAdditive = 0;
			return;
		}

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			camFollow.x += gf.curFunnyPosition[0];
			camFollow.y += gf.curFunnyPosition[1];
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);

			if (shoulderCam || funBackCamFadeShit)
			{
				camZoomAdditive = 0.175;
			}
		}
		else
		{
			moveCamera(false);

			camZoomAdditive = 0;
		}
	}

	public var curTheCube:FlxSprite;

	public function moveCamera(isDad:Bool, forceMiddleCam:Bool = false)
	{
		if (SONG.notes[curSection].middleCamSection || forceMiddleCam)
		{
			//rip the large square
			/*if (curTheCube == null)
			{
				var theCube:FlxSprite;
				var targetXforCube:Float = 0;
				var targetYforCube:Float = 0;
				var targetWidthForCube:Float = 1;
				var targetHeightForCube:Float = 1;
	
				// x
				if ((boyfriend.x + boyfriendGroup.x) > (dad.x + dadGroup.x))
				{
					targetXforCube = boyfriend.x + boyfriendGroup.x;
					targetWidthForCube = boyfriend.width + (targetXforCube - (dad.x + dadGroup.x)) + dad.width;
				}
				else
				{
					targetXforCube = dad.x + dadGroup.x;
					targetWidthForCube = dad.width + (targetXforCube - (boyfriend.x + boyfriendGroup.x)) + boyfriend.width;
				}
	
				// y
				if ((boyfriend.y + boyfriendGroup.y) > (dad.y + dadGroup.y))
				{
					targetYforCube = boyfriend.y + boyfriendGroup.y;
					targetHeightForCube = boyfriend.height + (targetYforCube - (dad.y + dadGroup.y)) + dad.height;
				}
				else
				{
					targetYforCube = dad.y + dadGroup.y;
					targetHeightForCube = dad.height + (targetYforCube - (boyfriend.y + boyfriendGroup.y)) + boyfriend.height;
				}
	
				theCube = new FlxSprite(targetXforCube, targetYforCube).makeGraphic(Std.int(targetWidthForCube), Std.int(targetHeightForCube));

				curTheCube = theCube;
			}

			camFollow.set(curTheCube.getMidpoint().x, curTheCube.getMidpoint().y);*/

			camFollow.set(((dad.getMidpoint().x - dad.x) / 2) + ((boyfriend.getMidpoint().x - boyfriend.x) / 2) + 148, dad.getMidpoint().y - 148);
			camFollow.y += dad.cameraPosition[1];
			camFollow.y += 64;

			if (isDad)
			{
				camFollow.x += dad.curFunnyPosition[0];
				camFollow.y += dad.curFunnyPosition[1];
			}
			else
			{
				camFollow.x += boyfriend.curFunnyPosition[0];
				camFollow.y += boyfriend.curFunnyPosition[1];
			}
		}
		else if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 148, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			camFollow.x += dad.curFunnyPosition[0];
			camFollow.y += dad.curFunnyPosition[1];

			if (funBackCamFadeShit)
			{
				if (bfAlphaTwnBack == null)
				{
					bfAlphaTwnBack = FlxTween.tween(boyfriend, {alpha: 0.5}, Conductor.crochet / 1000, {ease: FlxEase.quadOut, onComplete: function onCompleete(twn:FlxTween)
					{
						bfAlphaTwnBack = null;
					}});
				}
			}
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			camFollow.x += boyfriend.curFunnyPosition[0];
			camFollow.y += boyfriend.curFunnyPosition[1];

			if (funBackCamFadeShit)
			{
				if (bfAlphaTwnBack == null)
				{
					bfAlphaTwnBack = FlxTween.tween(boyfriend, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadIn, onComplete: function onCompleete(twn:FlxTween)
					{
						bfAlphaTwnBack = null;
					}});
				}
			}
		}
	}

	public function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = songEndTransitionThing;

		songHasSections = false;
		sectionNum = 1;
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public function songEndTransitionThing():Void
	{
		moveCamera(false, false);
		disallowCamMove = true;
		camZooming = false;
		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom - 0.1}, 1.5, {ease: FlxEase.expoOut});
		defaultCamZoom -= 0.1;
		FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.smootherStepOut, onComplete: function the(flucks:FlxTween)
		{
			var dieIril:FlxTimer = new FlxTimer().start(0.5, function imKingMyS(fuckYouTimer:FlxTimer)
			{
				endSong();				
			});
		}});
	}

	public var transitioning = false;

	public function endSong():Void
	{
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			});

			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}
		
		songHasSections = false;
		sectionNum = 1;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		deathCounter = 0;
		seenCutscene = false;

		if (!transitioning)
		{
			var percent:Float = ratingPercent;

			if (Math.isNaN(percent))
			{
				percent = 0;
			}

			Highscore.saveScore(SONG.song, songScore, percent);

			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			WeekData.loadTheFirstEnabledMod();
			cancelMusicFadeTween();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			if (FlxTransitionableState.skipNextTransIn)
			{
				MarkHeadTransition.nextCamera = null;
			}

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.stop();
			}

			MusicBeatState.switchState(new ResultsState(songScore, Highscore.getScore(SONG.song), synergys, goods, eghs, bleghs, cpuControlled, Highscore.floorDecimal(ratingPercent * 100, 2), songMisses));

			transitioning = true;
		}
	}

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}

		unspawnNotes = [];
		eventNotes = [];
	}

	public function cachePopUpScore()
	{
		var ratingsSuffix:String = songObj.ratingsType;

		Paths.image('ui/ratings' + ratingsSuffix + "/synergy");
		Paths.image('ui/ratings' + ratingsSuffix + "/good");
		Paths.image('ui/ratings' + ratingsSuffix + "/egh");
		Paths.image('ui/ratings' + ratingsSuffix + "/blegh");

		for (i in 0...10)
		{
			Paths.image('ui/ratings' + ratingsSuffix + '/num' + i);
		}
	}

	public function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

		vocals.volume = 1;

		var placement:String = Std.string(combo);
		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);

		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var ratingY:Float = 528;

		if (ClientPrefs.downScroll)
		{
			ratingY = 5;
		}

		var rating:FlxSprite = new FlxSprite(998, ratingY);
		var score:Int = Scoring.scoreNote(noteDiff / playbackRate);
		var daRating:String = Scoring.judgeNote(noteDiff / playbackRate);

		var ratingMod:Float = 1;
		switch (daRating)
		{
			case 'blegh':
				ratingMod = 0;
			case 'egh':
				ratingMod = 0.4;
			case 'good':
				ratingMod = 0.7;
		}

		totalNotesHit += ratingMod;
		note.ratingMod = ratingMod;

		switch (daRating)
		{
			case 'blegh':
				bleghs++;
			case 'egh':
				eghs++;
			case 'good':
				goods++;
			case 'synergy':
				synergys++;
		}

		note.rating = daRating;

		if (daRating == "synergy" && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;

			if (!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				recalculateRating(false);
			}
		}

		var ratingsSuffix:String = songObj.ratingsType;

		rating.loadGraphic(Paths.image('ui/ratings' + ratingsSuffix + '/' + daRating.toLowerCase()));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = 998;
		rating.y = ratingY;
		rating.acceleration.y = CoolUtil.randomLogic.int(500, 600) * playbackRate * playbackRate;
		rating.velocity.y -= CoolUtil.randomLogic.int(140, 175) * playbackRate;
		rating.velocity.x -= CoolUtil.randomLogic.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null)
			{
				lastRating.kill();
			}

			lastRating = rating;
		}

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 10000)
		{
			seperatedScore.push(Math.floor(combo / 10000) % 10);
		}

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}

		if (combo >= 100)
		{
			seperatedScore.push(Math.floor(combo / 100) % 10);
		}

		if (combo >= 10)
		{
			seperatedScore.push(Math.floor(combo / 10) % 10);
		}

		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;

		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/ratings' + ratingsSuffix + '/num' + Std.int(i)));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = 998 + (43 * daLoop);
			numScore.y = ratingY + 88;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
			{
				lastScore.push(numScore);
			}

			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.acceleration.y = CoolUtil.randomLogic.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= CoolUtil.randomLogic.int(140, 160) * playbackRate;
			numScore.velocity.x = CoolUtil.randomLogic.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			if (showComboNum)
			{
				insert(members.indexOf(strumLineNotes), numScore);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate,
			{
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;

			if (numScore.x > xThing)
			{
				xThing = numScore.x;
			}
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate,
		{
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (generatedMusic && !endingSong)
			{
				var lastTime:Float = Conductor.songPosition;

				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;
				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;
				var sortedNotesList:Array<Note> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
						}

						canMiss = true;
					}
				});

				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
							{
								notesStopped = true;
							}
						}

						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else
				{
					if (canMiss)
					{
						noteMissPress(key);
					}
				}

				keysPressed[key] = true;

				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];

			if (strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed', true);
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
		{
			return 1;
		}
		else if (!a.lowPriority && b.lowPriority)
		{
			return -1;
		}

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	public function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];

			if (spr != null)
			{
				spr.playAnim('static', true);
				spr.resetAnim = 0;
			}
		}
	}

	public function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}

		return -1;
	}

	public function keyShit():Void
	{
		var parsedHoldArray:Array<Bool> = parseKeys();

		if (ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] && strumsBlocked[i] != true)
					{
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
					}
				}
			}
		}

		if (startedCountdown && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit)
				{
					goodNoteHit(daNote);
				}
			});
			
			if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		if (ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] || strumsBlocked[i] == true)
					{
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
					}
				}
			}
		}
	}

	public function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];

		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}

		return ret;
	}

	function noteMiss(daNote:Note):Void
	{
		//Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		combo = 0;

		health -= daNote.missHealth * healthLoss;
		
		if (instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		if (songMisses == 0 || !daNote.isSustainNote)
		{
			songMisses++;
		}

		vocals.volume = 0;

		if (!practiceMode)
		{
			songScore -= 10;
		}

		if (!daNote.isSustainNote)
		{
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), CoolUtil.randomAudio.float(0.45, 0.65));
		}

		totalPlayed++;
		recalculateRating(true);

		var char:Character = boyfriend;

		if (daNote.gfNote)
		{
			char = gf;
		}

		if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
	}

	function noteMissPress(direction:Int = 1):Void
	{
		if (ClientPrefs.ghostTapping)
		{
			return;
		}

		health -= 0.05 * healthLoss;

		if (instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad', true);
		}

		combo = 0;

		if (!practiceMode)
		{
			songScore -= 10;
		}

		/*if (!endingSong)
		{
			songMisses++;
		}*/

		totalPlayed++;

		recalculateRating(true);

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), CoolUtil.randomAudio.float(0.45, 0.65));

		if (boyfriend.hasMissAnimations)
		{
			boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
		}

		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		camZooming = true;

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
				{
					altAnim = '-alt';
				}
			}

			var char:Character = dad;

			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;

			if (note.gfNote)
			{
				char = gf;
			}

			if (char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		var time:Float = 0.15;

		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
		{
			time += 0.15;
		}

		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
			{
				return;
			}

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);

				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				if (!note.noMissAnimation)
				{
					switch (note.noteType)
					{
						case 'Hurt Note':
							if (boyfriend.animation.getByName('hurt') != null)
							{
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;

				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;

				popUpScore(note);
			}

			health += note.hitHealth * healthGain;

			if (!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.gfNote)
				{
					if (gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled)
			{
				var time:Float = 0.15;

				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}

				strumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			}
			else
			{
				var spr = playerStrums.members[note.noteData];

				if (spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];

			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
		{
			skin = PlayState.SONG.splashSkin;
		}

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;

		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;

			if (note != null)
			{
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	override function destroy()
	{
		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		FlxAnimationController.globalSpeed = 1;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pitch = 1;
		}

		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.fadeTween != null)
			{
				FlxG.sound.music.fadeTween.cancel();
			}

			FlxG.sound.music.fadeTween = null;
		}
	}

	override function stepHit()
	{
		if (curStep == lastStepHit)
		{
			return;
		}

		songObj.stepHitEvent(curStep);

		if (FlxG.sound.music.time >= -ClientPrefs.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;

			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		lastStepHit = curStep;
	}

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		try
		{
			var thisTestThing;
			thisTestThing = SONG.notes[curSection].altAnim;
		}
		catch (e:Dynamic)
		{
			throw "Null section! You need to open the chart editor and play the song to the end to generate missing sections.";
		}

		songObj.beatHitEvent(curBeat);

		if (brokerBop)
		{
			if (curBeat % 2 == 0)
			{
				if (stockboy != null)
				{
					stockboy.dance();
				}
			}
		}

		if (rulezBeatSlam && ClientPrefs.camZooms)
		{
			FlxG.camera.zoom += 0.075;
			camHUD.zoom += 0.075;
		}

		if (fuckMyLife)
		{
			if (karmScaredy != null && curBeat % 2 == 0)
			{
				karmScaredy.animation.play("idle", true);
			}
		}

		if (curBeat % bgColorsCrazyBeats == 0 && funnyBgColorsPumpin)
		{
			FlxTween.completeTweensOf(funnyBgColors);

			funnyBgColors.alpha = 0.1;

			if (bgColorsRandom)
			{
				funnyBgColors.color = funnyColorsArray[CoolUtil.randomVisuals.int(0, funnyColorsArray.length - 1)];
			}

			FlxTween.tween(funnyBgColors, {alpha: 0.5}, Conductor.crochet / 750, {ease: FlxEase.smootherStepOut});
		}

		if (chefCurtains != null)
		{
			if (chefCurtains.active)
			{
				chefCurtains.meshVelocity.x += CoolUtil.randomVisuals.float(-12.5, 12.5);
				chefCurtains.meshVelocity.y += CoolUtil.randomVisuals.float(0, 12.5);
			}
		}

		if (curBeat % 2 == 0)
		{
			iconP1.scale.set(0.6, 1.4);
			iconP2.scale.set(1.4, 0.6);
		}
		else
		{
			iconP1.scale.set(1.4, 0.6);
			iconP2.scale.set(0.6, 1.4);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
		{
			boyfriend.dance();
		}

		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
		{
			dad.dance(SONG.notes[curSection].altAnim);
		}

		if (curBeat % 2 == 0 && bgPlayer != null)
		{
			bgPlayer.dance();
		}

		if (curBeat % 8 == 0)
		{
			if (strikeyStrikes)
			{
				lightningStrikes.alpha = 1;
				FlxTween.tween(lightningStrikes, {alpha: 0}, Conductor.crochet / 150,  {ease: FlxEase.cubeOut});
				FlxG.sound.play(Paths.soundRandom('dsides/storm', 0, 3), 0.9, false);
			}
		}

		lastBeatHit = curBeat;
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && !tweeningCam)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
			}
		}

		if (chefCurtains != null)
		{
			if (chefCurtains.active)
			{
				chefCurtains.meshVelocity.x += CoolUtil.randomVisuals.float(-40, 40);
				chefCurtains.meshVelocity.y += CoolUtil.randomVisuals.float(0, 40);
			}
		}
	}

	function updateIconStuff(elapsed:Float)
	{		
		iconP1.iconLerp(elapsed, camZoomingDecay, playbackRate);
		iconP2.iconLerp(elapsed, camZoomingDecay, playbackRate);
		
		iconP1.x = (healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26) + 10;
		iconP2.x = (healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2) + 10;

		iconP1.y = healthBar.y - 55;
		iconP2.y = healthBar.y - 55;

		iconP1.setFrameWithHealth(healthBar.percent, 1);
		iconP2.setFrameWithHealth(healthBar.percent, 2);
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;

		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public function recalculateRating(badHit:Bool = false)
	{
		if (totalPlayed < 1) //Prevent divide by 0
		{
			ratingName = '?';
		}
		else
		{
			// Rating Percent
			ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

			// Rating Name
			if (ratingPercent >= 1)
			{
				ratingName = ratingStuff[ratingStuff.length - 1][0]; //Uses last string
			}
			else
			{
				for (i in 0...ratingStuff.length - 1)
				{
					if (ratingPercent < ratingStuff[i][1])
					{
						ratingName = ratingStuff[i][0];
						break;
					}
				}
			}
		}

		ratingFC = "";

		if (synergys > 0)
		{
			ratingFC = "SFC";
		}

		if (goods > 0)
		{
			ratingFC = "GFC";
		}

		if (eghs > 0 || bleghs > 0)
		{
			ratingFC = "FC";
		}

		if (songMisses > 0 && songMisses < 10)
		{
			ratingFC = "SDCB";
		}
		else if (songMisses >= 10)
		{
			ratingFC = "Clear";
		}

		updateScore(badHit);
	}

	/**
	 * just to clean up create()
	 */
	public function gameplaySettingsSetup()
	{
		Scoring.PBOT1_SYNERGY_THRESHOLD = ClientPrefs.synergyWindow;
		Scoring.PBOT1_GOOD_THRESHOLD = ClientPrefs.goodWindow;
		Scoring.PBOT1_EGH_THRESHOLD = ClientPrefs.eghWindow;
		Scoring.PBOT1_BLEGH_THRESHOLD = ClientPrefs.bleghWindow;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
	}

	/**
	 * just to clean up create()
	 */
	public function songDataShit(songName:String)
	{
		GameOverSubstate.resetVariables();
		
		swingSec = songObj.startSwing;
		songHasSections = songObj.songHasSections;
		pixelPerfectishCamera = songObj.startPpCam;
		sectionNum = 1;

		Application.current.window.title = CoolUtil.appTitleString + " - Playing " + songObj.songNameForDisplay;

		curStage = SONG.stage;

		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (songName.replace('-erect', ''))
			{
				case 'destitution':
					curStage = 'mark';
				case 'superseded':
					curStage = 'superseded';
				case 'd-stitution':
					curStage = 'dsides';
				case 'eggshells' | 'eggshells-bad' | 'eggshells-good':
					curStage = 'eggshells';
				case 'new-hampshire':
					curStage = 'bucks';
				default:
					curStage = 'mark';
			}
		}

		SONG.stage = curStage;

		GameOverSubstate.characterName = songObj.gameoverChar;
		GameOverSubstate.loopSoundName = 'mus_overtime' + songObj.gameoverMusicSuffix;
		GameOverSubstate.endSoundName = 'mus_overtime_end' + songObj.gameoverMusicSuffix;

		skipCountdown = songObj.skipCountdown;
	}

	/**
	 * rescaling stuff for timer
	 */
	public function timerGoMiddlescroll(isFrom:Bool)
	{
		var death:Float = timeTxt.y;

		if (isFrom)
		{
			FlxTween.tween(timeTxt, {y: timeTxt.y + 12, 'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.smootherStepInOut});

			if (fullLength != null)
			{
				FlxTween.tween(fullLength, {y: (death + 12) + 36, 'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.smootherStepInOut});
			}
		}
		else
		{
			FlxTween.tween(timeTxt, {y: timeTxt.y - 12, 'scale.x': 0.8, 'scale.y': 0.8}, 1, {ease: FlxEase.smootherStepInOut});

			if (fullLength != null)
			{
				FlxTween.tween(fullLength, {y: (death - 12) + (36 * 0.8), 'scale.x': 0.8, 'scale.y': 0.8}, 1, {ease: FlxEase.smootherStepInOut});
			}
		}
	}
}