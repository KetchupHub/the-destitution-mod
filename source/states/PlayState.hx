package states;

#if DEVELOPERBUILD
import util.macro.GitCommit;
#end
import lime.app.Application;
#if desktop
import backend.Discord.DiscordClient;
#end
import backend.Section.SwagSection;
import backend.Song.SwagSong;
import visuals.WiggleEffect.WiggleEffectType;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import ui.Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import backend.StageData;
import backend.Conductor.Rating;
import songs.*;
import backend.*;
import ui.*;
import visuals.*;

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

using StringTools;

class PlayState extends MusicBeatState
{
	public var songObj:SongClass;

	public var songFont:String = "BAUHS93.ttf";

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

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

	public var isCameraOnForcedPos:Bool = false;

	public var brokerBop:Bool = false;

	public var sectText:FlxText;
	public var sectNameText:FlxText;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	public static var prevCamFollow:FlxPoint;
	public static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = true;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var smoothenedHealth:Float = 1;
	public var combo:Int = 0;

	public static var songHasSections:Bool = false;

	public var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	public var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplayTxt:FlxSprite;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var heyTimer:Float;

	public var rulezGuySlideScaleWorldFunnyClips:FlxSprite;

	public var YOUSTUPIDSONOFABITCH:FlxSprite;

	public var zamMarkCamFlipShit:FlxSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var timeTxt:FlxText;
	public var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var bucksBars:Array<BucksGraphBar> = [];

	public var bucksBarHistoryFuck:Array<Int> = [9, 9, 9, 9, 9, 9, 9, 9];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var detailsText:String = "Playing the Game";
	var detailsPausedText:String = "Paused";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	public var ref:FlxSprite;

	public static var instance:PlayState;

	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	public var itemManFucked:FlxSprite;

	public var cuttingSceneThing:FlxSprite;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	public var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	public var angry:FlxSprite;
	public var zamboni:FlxSprite;
	public var cryptehB:FlxSprite;
	public var office:FlxSprite;
	public var annoyed:FlxSprite;
	public var liek:FlxSprite;
	public var space:FlxSprite;
	public var spaceWiggle:WiggleEffect = new WiggleEffect();
	public var ploinky:FlxSprite;
	public var starting:FlxSprite;

	public var bgPlayer:Character;
	public var bgPlayerWalkTarget:Float;

	public var spaceTime:Bool;

	public var spaceTimeDadArray:Array<Float> = [0, 0];
	public var spaceTimeBfArray:Array<Float> = [0, 0];

	public var spaceItems:FlxTypedGroup<FlxSprite>;

	public var supersededIntro:FlxSprite;

	public var backing:FlxSprite;
	public var sky:FlxSprite;

	public var lightningStrikes:FlxSprite;

	public var strikeyStrikes:Bool = false;

	public var train:FlxSprite;

	public var karmScaredy:FlxSprite;

	public var stockboy:Character;

	var bucksBarUpdateCountdown:Float = 10;

	var fullLength:FlxText;

	override public function create()
	{

		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
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
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		// String for when the game is paused
		detailsPausedText = "Paused";
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		songObj = SongInit.genSongObj(songName);

		songHasSections = songObj.songHasSections;
		sectionNum = 1;

		Application.current.window.title = util.CoolUtil.appTitleString + " - Playing " + songObj.songNameForDisplay;

		curStage = SONG.stage;
		if(SONG.stage == null || SONG.stage.length < 1)
		{
			switch (songName)
			{
				case 'destitution':
					curStage = 'mark';
				case 'superseded':
					curStage = 'superseded';
				case 'd-stitution':
					curStage = 'dsides';
				case 'three-of-them':
					curStage = 'april';
				case 'new-hampshire':
					curStage = 'bucks';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null)
		{
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		GameOverSubstate.characterName = songObj.gameoverChar;
		GameOverSubstate.loopSoundName = 'gameOver' + songObj.gameoverMusicSuffix;
		GameOverSubstate.endSoundName = 'gameOverEnd' + songObj.gameoverMusicSuffix;

		switch (curStage)
		{
			case 'april':
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('april/bg'));
				bg.scale.set(1.2, 1.2);
				bg.updateHitbox();
				bg.screenCenter();
				add(bg);
			case 'dsides':
				var pureWhiteAbyss:FlxSprite = new FlxSprite().makeGraphic(2560, 2560, FlxColor.WHITE);
				pureWhiteAbyss.screenCenter();
				pureWhiteAbyss.scrollFactor.set();
				add(pureWhiteAbyss);

				sky = new FlxSprite().loadGraphic(Paths.image('dsides/sky'));
				sky.antialiasing = false;
				add(sky);
				sky.screenCenter();
				sky.scrollFactor.set();

				backing = new FlxSprite().loadGraphic(Paths.image('dsides/backing'));
				backing.antialiasing = false;
				add(backing);
				backing.screenCenter();
				backing.scrollFactor.set(0.5, 0.5);

				starting = new FlxSprite().loadGraphic(Paths.image('dsides/front'));
				starting.antialiasing = false;
				add(starting);
				starting.screenCenter();

				karmScaredy = new FlxSprite(starting.x + 40.75, starting.y + 610.35);
				karmScaredy.frames = Paths.getSparrowAtlas("dsides/karm_scaredy");
				karmScaredy.animation.addByPrefix("idle", "idle", 24, false);
				karmScaredy.animation.play("idle", true);
				add(karmScaredy);

				karmScaredy.visible = false;

				lightningStrikes = new FlxSprite().makeGraphic(5000, 5000, FlxColor.fromRGB(255, 241, 185));
				if(ClientPrefs.shaders)
				{
					lightningStrikes.blend = BlendMode.ADD;
				}
				lightningStrikes.screenCenter();
				lightningStrikes.alpha = 0;

				lightningBg();
				
				unLightningBg();

				funnyBgColors.screenCenter();
				add(funnyBgColors);
				funnyBgColors.alpha = 0;
				funnyBgColors.color = FlxColor.BLACK;

				train = new FlxSprite().loadGraphic(Paths.image("dsides/train funny"));
				train.screenCenter();
				add(train);
				train.visible = false;
			case 'mark':
				angry = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/angry'));
				angry.antialiasing = false;
				add(angry);
				zamboni = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/zamboni'));
				zamboni.antialiasing = false;
				add(zamboni);
				cryptehB = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/cryptehB'));
				cryptehB.antialiasing = false;
				add(cryptehB);
				office = new FlxSprite(-680, -320);
				office.frames = Paths.getSparrowAtlas('destitution/destitution_bg_buy_my_new_shitcoin');
				office.animation.addByPrefix("idle", "ROOLZ ARE FOUR TOOLZ", 24, false);
				office.animation.play("idle", true);
				office.animation.pause();
				office.antialiasing = false;
				add(office);
				annoyed = new FlxSprite(-680, -320);
				annoyed.frames = Paths.getSparrowAtlas('destitution/destitution_bg_heyheyheywahtsallthis');
				annoyed.animation.addByPrefix("idle", "whale world to somewhat peterbed man", 24, false);
				annoyed.animation.play("idle", true);
				annoyed.animation.pause();
				annoyed.antialiasing = false;
				add(annoyed);
				liek = new FlxSprite(-680, -320);
				liek.frames = Paths.getSparrowAtlas('destitution/destitution_bg_ittem_whalez');
				liek.animation.addByPrefix("idle", "ITEM MAN TO THE WHALES OF THE WORLD", 24, false);
				liek.animation.play("idle", true);
				liek.animation.pause();
				liek.antialiasing = false;
				add(liek);
				space = new FlxSprite(-680, -320);
				space.loadGraphic(Paths.image("destitution/space"));
				space.antialiasing = false;
				space.scale.set(2, 2);
				space.updateHitbox();
				space.screenCenter();
				space.visible = false;
				add(space);
				spaceWiggle.effectType = WiggleEffectType.DREAMY;
				spaceWiggle.waveAmplitude = 0.2;
				spaceWiggle.waveFrequency = 7;
				spaceWiggle.waveSpeed = 1;
				space.shader = spaceWiggle.shader;

				spaceItems = new FlxTypedGroup<FlxSprite>();
				for(i in 0...10)
				{
					var fucksprit:FlxSprite = new FlxSprite(FlxG.random.float(space.x + 150, space.x + space.width - 150), FlxG.random.float(space.y + 150, space.y + space.height - 150));
					fucksprit.loadGraphic(Paths.image("destitution/itemShit/" + Std.string(FlxG.random.int(0, 10))));
					fucksprit.antialiasing = false;
					fucksprit.ID = i;
					fucksprit.scale.set(2, 2);
					fucksprit.updateHitbox();
					spaceItems.add(fucksprit);
				}
				add(spaceItems);
				spaceItems.visible = false;

				ploinky = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/ploinky'));
				ploinky.antialiasing = false;
				add(ploinky);
				starting = new FlxSprite(-680, -320).loadGraphic(Paths.image('destitution/start'));
				starting.antialiasing = false;
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

				bgPlayer = new Character(starting.x + 980, starting.y + 398, "bg-player", false, false);
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
			case 'superseded':
				skipCountdown = true;
				tweeningCam = true;
				camHUD.zoom = 15;

				starting = new FlxSprite(0, 0).loadGraphic(Paths.image('superseded/bg'));
				starting.antialiasing = false;
				add(starting);

				supersededIntro = new FlxSprite(0, 0);
				supersededIntro.frames = Paths.getSparrowAtlas("superseded/superseded_time");
				supersededIntro.animation.addByPrefix("idle", "idle", 24, true);
				supersededIntro.animation.addByPrefix("open", "open", 24, false);
				supersededIntro.antialiasing = false;
				supersededIntro.animation.play("idle", true);
				supersededIntro.scrollFactor.set();

				spaceWiggle.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
				spaceWiggle.waveAmplitude = 0.25;
				spaceWiggle.waveFrequency = 8;
				spaceWiggle.waveSpeed = 2;
			case 'bucks':
				var skyish = new FlxSprite(-458, -413);
				skyish.loadGraphic(Paths.image('bucks/skybox'));
				skyish.antialiasing = true;
				skyish.scrollFactor.set();
				add(skyish);

				var tvs = new FlxSprite(-610, -750);
				tvs.frames = Paths.getSparrowAtlas('bucks/tvs');
				tvs.animation.addByPrefix('idle', 'many tvs flashloop', 24, true);
				tvs.animation.play('idle');
				tvs.scale.set(2, 2);
				tvs.updateHitbox();
				tvs.antialiasing = true;
				tvs.scrollFactor.set(0.2, 0.1);
				add(tvs);

				var lump = new FlxSprite(-350, 270).loadGraphic(Paths.image('bucks/lump'));
				lump.antialiasing = true;
				lump.scrollFactor.set(0.45, 0.7);
				add(lump);

				stockboy = new Character(-245, 275, 'brokerboy', false, false);
				stockboy.antialiasing = true;
				stockboy.playAnim('walk', true);
				stockboy.animation.pause();
				stockboy.scrollFactor.set(0.45, 0.7);
				add(stockboy);
				
				var floor = new FlxSprite(-445, 200).loadGraphic(Paths.image('bucks/floor'));
				floor.antialiasing = true;
				add(floor);

				var screen = new FlxSprite(30, -250).loadGraphic(Paths.image('bucks/screen'));
				screen.antialiasing = true;
				add(screen);

				for(i in 0...7)
				{
					bucksBars[i] = new BucksGraphBar(screen.x + 200 + (i * 120), 5);
					add(bucksBars[i]);
				}

				var yais = new FlxSprite(80, -235);
				yais.frames = Paths.getSparrowAtlas('bucks/youre_accuracy_inc_stock');
				yais.animation.addByPrefix('idle', 'yais', 24, true);
				yais.animation.play('idle');
				yais.antialiasing = true;
				add(yais);

				ref = new FlxSprite(-458, -413);
				ref.loadGraphic(Paths.image('bucks/possy'));
				ref.alpha = 0.65;
				ref.antialiasing = true;
				ref.visible = false;
				add(ref);
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
		}

		add(gfGroup); //Needed for blammed lights

		add(dadGroup);

		add(boyfriendGroup);

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}

			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		if(supersededIntro != null)
		{
			add(supersededIntro);
		}

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		if(SONG.song.toLowerCase() == "d-stitution")
		{
			dad.visible = false;
		}

		Conductor.songPosition = -5000 / Conductor.songPosition;

		var storageLol:Bool = false;
		storageLol = ClientPrefs.middleScroll;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(0, 8, 400, "", 32);
		timeTxt.setFormat(Paths.font(songFont), 32 + 10, FlxColor.WHITE, CENTER, FlxTextBorderStyle.NONE, FlxColor.WHITE);
		timeTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5, 0);
		timeTxt.screenCenter(X);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 40;

		if(ClientPrefs.timeBarType == 'Time Left' || ClientPrefs.timeBarType == 'Time Elapsed')
		{
			timeTxt.size = 36;
			timeTxt.underline = true;
			fullLength = new FlxText(timeTxt.x, timeTxt.y + 36, 400, "", 24);
			fullLength.setFormat(Paths.font(songFont), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.NONE, FlxColor.WHITE);
			fullLength.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5, 0);
			fullLength.scrollFactor.set();
			fullLength.alpha = 0;
			fullLength.visible = showTime;
		}

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = songObj.songNameForDisplay;
		}
		updateTime = showTime;

		if(fullLength != null)
		{
			add(fullLength);
		}
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
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

		healthBarBG = new AttachedSprite('ui/healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'smoothenedHealth', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font(songFont), 20 + 10, FlxColor.WHITE, CENTER, FlxTextBorderStyle.NONE, FlxColor.WHITE);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5, 0);
		scoreTxt.scrollFactor.set();
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		var botplaySuffix:String = "";
		botplayTxt = new FlxSprite(0, FlxG.height - 256).loadGraphic(Paths.image("ui/botplay" + botplaySuffix));
		botplayTxt.scrollFactor.set();
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if(fullLength != null)
		{
			fullLength.cameras = [camHUD];
		}

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + GitCommit.getGitBranch() + " - " + GitCommit.getGitCommitHash() + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.cameras = [camHUD];
		add(versionShit);
		#end

		startingSong = true;
		
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		if(eventNotes.length > 1)
		{
			eventNotes.sort(sortByTime);
		}

		var daSong:String = Paths.formatToSongPath(curSong);

		startCountdown();

		ClientPrefs.middleScroll = storageLol;

		RecalculateRating();

		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		precacheList.set("breakfast", 'music');
		precacheList.set('alphabet', 'image');
	
		#if desktop
		DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.create();

		cacheCountdown();
		cachePopUpScore();

		for (key => type in precacheList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		
		CustomFadeTransition.nextCamera = camOther;
		if(eventNotes.length < 1) checkEventNote();
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [];
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			if(opponentVocals != null) opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		return value;
	}

	public function reloadHealthBarColors()
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch(type)
		{
			case 0:
				if(!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if(!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
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
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
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
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ui/ready', 'ui/set', 'ui/go']);

		var introAlts:Array<String> = introAssets.get('default');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro' + songObj.introType + '/intro3' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/intro2' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/intro1' + introSoundsSuffix);
		Paths.sound('intro' + songObj.introType + '/introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown)
		{
			return;
		}

		inCutscene = false;

		if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = -Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if(startOnTime < 0) startOnTime = 0;

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

		startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
		{
			if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			{
				gf.dance();
			}
			if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			{
				boyfriend.dance();
			}
			if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			{
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ui/ready', 'ui/set', 'ui/go']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro3' + introSoundsSuffix), 0.6);
				case 1:
					countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					countdownReady.cameras = [camHUD];
					countdownReady.scrollFactor.set();
					countdownReady.updateHitbox();
					countdownReady.screenCenter();
					countdownReady.antialiasing = antialias;
					insert(members.indexOf(notes), countdownReady);
					FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownReady);
							countdownReady.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro2' + introSoundsSuffix), 0.6);
				case 2:
					countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					countdownSet.cameras = [camHUD];
					countdownSet.scrollFactor.set();
					countdownSet.screenCenter();
					countdownSet.antialiasing = antialias;
					insert(members.indexOf(notes), countdownSet);
					FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownSet);
							countdownSet.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'intro1' + introSoundsSuffix), 0.6);
				case 3:
					countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					countdownGo.cameras = [camHUD];
					countdownGo.scrollFactor.set();
					countdownGo.updateHitbox();
					countdownGo.screenCenter();
					countdownGo.antialiasing = antialias;
					insert(members.indexOf(notes), countdownGo);
					FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownGo);
							countdownGo.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro' + songObj.introType + '/' + 'introGo' + introSoundsSuffix), 0.6);
					if(SONG.song.toLowerCase() == "d-stitution")
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
				case 4:
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
		scoreTxt.text = 'Score: ' + songScore
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

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		songLength = FlxG.sound.music.length;

		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		if(fullLength != null)
		{
			FlxTween.tween(fullLength, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			if(fullLength != null)
			{
					fullLength.text = FlxStringUtil.formatTime(Math.floor(songLength / 1000), false);
			}
		}

		#if desktop
		DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase(), true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
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
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, 'Player');
				vocals.loadEmbedded(playerVocals);
				
				var oppVocals = Paths.voices(songData.song, 'Opponent');
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

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
			for (event in eventsData) //Event Notes
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
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]];

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
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

	public static var sectionNum:Int = 1;

	//set health to 1 and display fun message
	public function sectionIntroThing(displayName:String)
	{
		songHasSections = true;
		sectionNum++;
		health = 1;

		if(sectNameText == null)
		{
			sectText = new FlxText(0, 0, FlxG.width, "SECTION 2", 96);
			sectText.setFormat(Paths.font(songFont), 96 * 2, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			sectText.screenCenter();
			sectText.y -= 400;
			sectText.alpha = 0;
			sectText.cameras = [camHUD];
			add(sectText);
			sectNameText = new FlxText(0, 0, FlxG.width, displayName.toUpperCase(), 48);
			sectNameText.setFormat(Paths.font(songFont), 48 * 2, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
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
						if(Math.isNaN(charType)) charType = 0;
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

	public var skipArrowStartTween:Bool = false;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
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
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1)
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
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

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
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

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
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase());
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
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songObj.songNameForDisplay, SONG.song.toLowerCase());
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
			DiscordClient.changePresence(detailsPausedText, songObj.songNameForDisplay, SONG.song.toLowerCase());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

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

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var elapsedTotal:Float;

	override public function update(elapsed:Float)
	{
		if(!inCutscene)
		{
			var lerpVal:Float = util.CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		if(ref != null)
		{
			if(FlxG.keys.justPressed.P)
			{
				ref.visible = !ref.visible;
			}
		}

		spaceWiggle.update(elapsed);

		if(startedCountdown && generatedMusic && bucksBars[5] != null)
		{
			bucksBarUpdateCountdown -= 1 * elapsed;

			if(bucksBarUpdateCountdown <= 0)
			{
				bucksBarUpdateCountdown = FlxG.random.float(2.75, 6.5);
				bucksBarHistoryFuck = bucksBarHistoryFuck.slice(1, 7);

				if(cpuControlled || (combo == 0 && songMisses == 0))
				{
					bucksBarHistoryFuck.push(9);
				}
				else
				{
					bucksBarHistoryFuck.push(Std.int((ratingPercent * 10) - 1));
				}

				for(i in 0...7)
				{
					bucksBars[i].changeGraphPos(bucksBarHistoryFuck[i]);
				}
			}
		}

		elapsedTotal += elapsed;

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();
		}

		smoothenedHealth = FlxMath.lerp(smoothenedHealth, health, util.CoolUtil.boundTo(elapsed * 13, 0, 1));

		super.update(elapsed);

		if(dad != null)
		{
			if(dad.animation.curAnim != null)
			{
				if(dad.animation.curAnim.name.toLowerCase().startsWith("sing"))
				{
					if(dad.singDuration >= 10)
					{
						if(dad.animation.curAnim.finished)
						{
							dad.dance(SONG.notes[curSection].altAnim);
							dad.holdTimer = 0;
							if(!dad.animation.curAnim.looped)
							{
								dad.animation.finish();
							}
						}
					}
				}
			}
		}

		if(boyfriend != null)
		{
			if(boyfriend.animation.curAnim != null)
			{
				if(boyfriend.animation.curAnim.name.toLowerCase().startsWith("sing"))
				{
					if(boyfriend.singDuration >= 10)
					{
						if(boyfriend.animation.curAnim.finished)
						{
							boyfriend.dance();
							boyfriend.holdTimer = 0;
							if(!boyfriend.animation.curAnim.looped)
							{
								boyfriend.animation.finish();
							}
						}
					}
				}
			}
		}

		if(spaceTime)
		{
			dad.y += Math.sin(elapsedTotal) * 0.3;
			boyfriend.y += Math.sin(elapsedTotal) * 0.3;

			dad.x += Math.cos(elapsedTotal) * 0.3;
			boyfriend.x += Math.cos(elapsedTotal) * 0.3;

			dad.angle += Math.sin(elapsedTotal) * 0.1;
			boyfriend.angle += Math.sin(elapsedTotal) * 0.1;

			for(i in spaceItems.members)
			{
				i.angle += 2;

				if(i.ID % 2 == 0)
				{
					i.x += Math.sin(elapsedTotal) * 0.4;
				}
				else
				{
					i.y += Math.sin(elapsedTotal) * 0.4;
				}
			}
		}

		if(whaleFuckShit)
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

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, util.CoolUtil.boundTo(1 - (elapsed * 13 * camZoomingDecay * playbackRate), 0, 1));
		var multDos:Float = FlxMath.lerp(1, iconP1.scale.y, util.CoolUtil.boundTo(1 - (elapsed * 13 * camZoomingDecay * playbackRate), 0, 1));
		iconP1.scale.set(mult, multDos);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, util.CoolUtil.boundTo(1 - (elapsed * 13 * camZoomingDecay * playbackRate), 0, 1));
		var multDos:Float = FlxMath.lerp(1, iconP2.scale.y, util.CoolUtil.boundTo(1 - (elapsed * 13 * camZoomingDecay * playbackRate), 0, 1));
		iconP2.scale.set(mult, multDos);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if(updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}
		}

		if(!tweeningCam)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + camZoomAdditive, FlxG.camera.zoom, util.CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, util.CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
				{
					keyShit();
				}
				else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
				}

				if(startedCountdown)
				{
					var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
					notes.forEachAlive(function(daNote:Note)
					{
						var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
						if(!daNote.mustPress) strumGroup = opponentStrums;

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

						if (strumScroll) //Downscroll
						{
							//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}
						else //Upscroll
						{
							//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}

						var angleDir = strumDirection * Math.PI / 180;
						if (daNote.copyAngle)
							daNote.angle = strumDirection - 90 + strumAngle;

						if(daNote.copyAlpha)
							daNote.alpha = strumAlpha;

						if(daNote.copyX)
							daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

						if(daNote.copyY)
						{
							daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
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

						if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
							if(daNote.isSustainNote) {
								if(daNote.canBeHit) {
									goodNoteHit(daNote);
								}
							} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
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

						// Kill extremely late notes and cause misses
						if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
						{
							if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
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

		if(FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if desktop
		DiscordClient.changePresence(detailsPausedText, songObj.songNameForDisplay, SONG.song.toLowerCase());
		Application.current.window.title = util.CoolUtil.appTitleString + " - PAUSED on " + songObj.songNameForDisplay;
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
		Application.current.window.title = util.CoolUtil.appTitleString + " - Chart Editor";
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false;

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			boyfriend.stunned = true;
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
			DiscordClient.changePresence("Game Over", songObj.songNameForDisplay, SONG.song.toLowerCase());
			Application.current.window.title = util.CoolUtil.appTitleString + " - GAME OVER on " + songObj.songNameForDisplay;
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
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

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
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

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
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
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
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
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
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
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
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

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

	public var disallowCamMove:Bool = false;

	public function moveCameraSection():Void
	{
		if(disallowCamMove)
		{
			return;
		}

		if(SONG.notes[curSection] == null) return;

		if(centerCamOnBg)
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
			tweenCamIn();
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			if(shoulderCam || funBackCamFadeShit)
			{
				camZoomAdditive = 0.175;
				if(funBackCamFadeShit)
				{
					if(bfAlphaTwnBack == null)
					{
						bfAlphaTwnBack = FlxTween.tween(boyfriend, {alpha: 0.5}, Conductor.crochet / 1000, {ease: FlxEase.quadOut, onComplete: function onCompleete(twn:FlxTween)
						{
							bfAlphaTwnBack = null;
						}});
					}
				}
			}
		}
		else
		{
			moveCamera(false);
			camZoomAdditive = 0;
			if(funBackCamFadeShit)
			{
				if(bfAlphaTwnBack == null)
				{
					bfAlphaTwnBack = FlxTween.tween(boyfriend, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadIn, onComplete: function onCompleete(twn:FlxTween)
					{
						bfAlphaTwnBack = null;
					}});
				}
			}
		}
	}

	public var cameraTwn:FlxTween;

	public var bfAlphaTwnBack:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			camFollow.x += dad.curFunnyPosition[0];
			camFollow.y += dad.curFunnyPosition[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			camFollow.x += boyfriend.curFunnyPosition[0];
			camFollow.y += boyfriend.curFunnyPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	public function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		songHasSections = false;
		sectionNum = 1;
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			});

			for (daNote in unspawnNotes)
			{
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck())
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

		if(!transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, percent);
				#end
			}
			
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			WeekData.loadTheFirstEnabledMod();
			cancelMusicFadeTween();

			if(FlxTransitionableState.skipNextTransIn)
			{
				CustomFadeTransition.nextCamera = null;
			}

			MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

			transitioning = true;
		}
	}

	public function KillNotes()
	{
		while(notes.length > 0)
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

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = 'ui/';
		var pixelShitPart2:String = '';

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var ratingY:Float = 528;
		if(ClientPrefs.downScroll)
		{
			ratingY = 5;
		}

		var rating:FlxSprite = new FlxSprite(998, ratingY);
		var score:Int = 350;

		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled)
		{
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "ui/";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = 998;
		rating.y = ratingY;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = ClientPrefs.globalAntialiasing;
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
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
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = 998 + (43 * daLoop) - 43;
			numScore.y = ratingY + 88;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			numScore.antialiasing = ClientPrefs.globalAntialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));

			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else
				{
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed', true);
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static', true);
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});
			
			if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	public var ploinkyTransition:FlxSprite;

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad', true);
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
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
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
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
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
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

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
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
		if(ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
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

	public var funBackCamFadeShit:Bool = false;

	override function destroy()
	{
		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if(FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		if(curStep == lastStepHit)
		{
			return;
		}

		songObj.stepHitEvent(curStep);

		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.noteOffset)
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

	public var funnyBgColorsPumpin:Bool = false;

	public var bgColorsCrazyBeats:Int = 4;
	public var bgColorsRandom:Bool = false;

	public var funnyBgColors:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.width * 3, FlxColor.WHITE);

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	public var centerCamOnBg:Bool = false;

	public var shoulderCam:Bool = false;

	public var camZoomAdditive:Float = 0;

	public var tweeningCam:Bool = false;

	public var funnyColorsArray:Array<FlxColor> = [FlxColor.BLUE, FlxColor.CYAN, FlxColor.GREEN, FlxColor.LIME, FlxColor.MAGENTA, FlxColor.ORANGE, FlxColor.PINK, FlxColor.PURPLE, FlxColor.RED, FlxColor.YELLOW, FlxColor.BROWN];

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat)
		{
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		songObj.beatHitEvent(curBeat);

		if(brokerBop)
		{
			if(curBeat % 2 == 0)
			{
				if(stockboy != null)
				{
					stockboy.dance();
				}
			}
		}

		if(rulezBeatSlam)
		{
			FlxG.camera.zoom += 0.075;
			camHUD.zoom += 0.075;
		}

		if(karmScaredy != null)
		{
			karmScaredy.animation.play("idle", true);
		}

		if(curBeat % bgColorsCrazyBeats == 0 && funnyBgColorsPumpin)
		{
			FlxTween.completeTweensOf(funnyBgColors);
			funnyBgColors.alpha = 0.1;
			if(bgColorsRandom)
			{
				funnyBgColors.color = funnyColorsArray[FlxG.random.int(0, funnyColorsArray.length - 1)];
			}
			FlxTween.tween(funnyBgColors, {alpha: 0.4}, Conductor.crochet / 750, {ease: FlxEase.smootherStepOut});
		}

		if(curBeat % 2 == 0)
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

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance(SONG.notes[curSection].altAnim);
		}

		if(curBeat % 2 == 0 && bgPlayer != null)
		{
			bgPlayer.dance();
		}

		if(curBeat % 8 == 0)
		{
			if(strikeyStrikes)
			{
				lightningStrikes.alpha = 1;
				FlxTween.tween(lightningStrikes, {alpha: 0}, Conductor.crochet / 150,  {ease: FlxEase.cubeOut});
			}
		}

		lastBeatHit = curBeat;
	}

	public var rulezBeatSlam:Bool = false;

	public var whaleFuckShit:Bool = false;

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
	}

	public var cyndaBeatsWaterMark:FlxSprite;

	public function epicCyndaBeats(lol:Bool)
	{
		if(cyndaBeatsWaterMark == null)
		{
			cyndaBeatsWaterMark = new FlxSprite(1800, 170).loadGraphic(Paths.image("april/epicbeats"));
			cyndaBeatsWaterMark.cameras = [camHUD];
			add(cyndaBeatsWaterMark);
		}

		FlxTween.tween(cyndaBeatsWaterMark, {x: lol ? 1800 : 900}, Conductor.crochet / 250, {ease: FlxEase.backInOut});
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;

		if(isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if(spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false)
	{
		if(totalPlayed < 1) //Prevent divide by 0
		{
			ratingName = '?';
		}
		else
		{
			// Rating Percent
			ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

			// Rating Name
			if(ratingPercent >= 1)
			{
				ratingName = ratingStuff[ratingStuff.length - 1][0]; //Uses last string
			}
			else
			{
				for (i in 0...ratingStuff.length - 1)
				{
					if(ratingPercent < ratingStuff[i][1])
					{
						ratingName = ratingStuff[i][0];
						break;
					}
				}
			}
		}

		// Rating FC
		ratingFC = "";
		if (sicks > 0)
		{
			ratingFC = "SFC";
		}
		if (goods > 0)
		{
			ratingFC = "GFC";
		}
		if (bads > 0 || shits > 0)
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

		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
	}
}