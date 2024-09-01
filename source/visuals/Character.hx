package visuals;

import backend.Conductor;
import states.PlayState;
import backend.ClientPrefs;

import flixel.animation.FlxAnimationController;
import adobeanimate.FlxAtlasSprite;

import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

import openfl.utils.Assets;
import haxe.Json;

import flixel.util.FlxColor;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;

	var artist:String;
	var animator:String;
	var whoDoneWhat:String;

	var _editor_isPlayer:Bool;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var hasTransition:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var hasTransitionsMap:Map<String, Bool> = new Map<String, Bool>();

	public var colorTween:FlxTween;

	public var canDance:Bool = true;
	public var canSing:Bool = true;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var danceEveryNumBeats:Int = 2;
	public var danced:Bool = false;

	public var healthIcon:String = 'face';
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var curFunnyPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var _editor_isPlayer:Null<Bool> = null;

	public var artist:String = "Unknown";
	public var animator:String = "Unknown";
	public var whoDoneWhat:String = "Unknown";

	public var isAnimateAtlas:Bool = false;
	public var atlas:FlxAtlasSprite;
	
	public var settingCharacterUp:Bool = true;

	public var animPaused(get, set):Bool;

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?doPositioning = true)
	{
		#if DEVELOPERBUILD
		var perf = new Perf("Creating Character: " + character + ', ' + x + ', ' + y);
		#end

		super(x, y);

		animation = new FlxAnimationController(this);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var characterPath:String = 'characters/$curCharacter.json';

		var path:String = Paths.getPath(characterPath, TEXT, null);
		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
		{
			path = Paths.getPath('characters/' + DEFAULT_CHARACTER + '.json', TEXT); //If a character couldn't be found, change him to BF just to prevent a crash
			color = FlxColor.BLACK;
			alpha = 0.6;
		}

		try
		{
			#if MODS_ALLOWED
			loadCharacterFile(Json.parse(File.getContent(path)));
			#else
			loadCharacterFile(Json.parse(Assets.getText(path)));
			#end
		}
		catch (e:Dynamic)
		{
			#if DEVELOPERBUILD
			trace('Error loading character file of "$character": $e');
			#end
		}

		if (animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss'))
		{
			hasMissAnimations = true;
		}
		
		recalculateDanceIdle();
		dance();

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	public function loadCharacterFile(json:Dynamic)
	{
		isAnimateAtlas = false;

		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT, null);

		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
		{
			isAnimateAtlas = true;
		}

		scale.set(1, 1);
		updateHitbox();

		if (!isAnimateAtlas)
		{
			frames = Paths.getAtlas(json.image);
		}
		else
		{
			try
			{
				atlas = new FlxAtlasSprite(0, 0, json.image);
				atlas.showPivot = false;
			}
			catch (e:Dynamic)
			{
				#if DEVELOPERBUILD
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
				#end
			}
		}

		imageFile = json.image;
		jsonScale = json.scale;

		if (json.scale != 1)
		{
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}

		positionArray = json.position;
		cameraPosition = json.camera_position;

		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file != null ? json.vocals_file : '';
		originalFlipX = (json.flip_x == true);
		_editor_isPlayer = json._editor_isPlayer;
		artist = json.artist;
		animator = json.animator;
		whoDoneWhat = json.whoDoneWhat;

		noAntialiasing = (json.no_antialiasing == true);
		antialiasing = ClientPrefs.globalAntialiasing ? !noAntialiasing : false;

		animationsArray = json.animations;

		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop;
				var hasTransition = anim.hasTransition;
				var animIndices:Array<Int> = anim.indices;

				/* this literally doesnt work and refuses to work, just gonna do it MANUALLY #fun
				//this might just be the most batshit solution to a stupid problem ever devised
				//"On static platforms, null can't be used as basic type Bool" well how about you just stop existing
				var whatTheFuck:String = 'fuck';

				//istg
				if (json.animations[json.animations.indexOf(anim)].hasTransition == null)
				{
					whatTheFuck = 'fuck';
				}

				if (hasTransition == true || hasTransition == false)
				{
					whatTheFuck = 'shit';
				}

				#if DEVELOPERBUILD
				trace(curCharacter + ' whatTheFuck status for $animAnim: ' + whatTheFuck);
				#end

				//so i dont have to manually fix this for every single character file
				if (singDuration >= 10 && whatTheFuck == 'fuck')
				{
					if (animAnim.toLowerCase().startsWith('sing') && !animAnim.endsWith('miss'))
					{
						#if DEVELOPERBUILD
						trace('SET $animAnim on character $curCharacter TO HAVE TRANSITION! MONDO COOL! YOU ARE SUPER PLAYER');
						#end
						anim.hasTransition = true;
						hasTransition = true;
					}
				}*/

				hasTransitionsMap.set(animAnim, hasTransition);

				if (!isAnimateAtlas)
				{
					if (animIndices != null && animIndices.length > 0)
					{
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					}
					else
					{
						animation.addByPrefix(animAnim, animName, animFps, animLoop);
					}
				}
				#if flxanimate
				else
				{
					if (animIndices != null && animIndices.length > 0)
					{
						atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					}
					else
					{
						atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
					}
				}
				#end

				if (anim.offsets != null && anim.offsets.length > 1)
				{
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}
				else
				{
					addOffset(anim.anim, 0, 0);
				}
			}
		}

		#if flxanimate
		if (isAnimateAtlas)
		{
			copyAtlasValues();
		}
		#end
	}

	override function update(elapsed:Float)
	{
		if (isAnimateAtlas)
		{
			atlas.update(elapsed);
		}

		if (debugMode || (!isAnimateAtlas && animation.curAnim == null) || (isAnimateAtlas && atlas.anim.curSymbol == null))
		{
			super.update(elapsed);

			return;
		}

		if (heyTimer > 0)
		{
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;

			if (heyTimer <= 0)
			{
				var anim:String = getAnimationName();

				if (specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}

				heyTimer = 0;
			}
		}
		else if (specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (getAnimationName().endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}

		if (getAnimationName().startsWith('sing'))
		{
			holdTimer += elapsed;
		}
		else if (isPlayer)
		{
			holdTimer = 0;
		}

		if (!isPlayer && holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();

		if (isAnimationFinished() && animOffsets.exists('$name-loop'))
		{
			playAnim('$name-loop');
		}

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool
	{
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curSymbol == null);
	}

	inline public function getAnimationName():String
	{
		var name:String = '';
		@:privateAccess
		if (!isAnimationNull())
		{
			name = !isAnimateAtlas ? animation.curAnim.name : atlas.animation.curAnim.name;
		}

		return (name != null) ? name : '';
	}

	public function isAnimationFinished():Bool
	{
		if (isAnimationNull())
		{
			return false;
		}

		return !isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
	}

	public function finishAnimation():Void
	{
		if (isAnimationNull())
		{
			return;
		}

		if (!isAnimateAtlas)
		{
			animation.curAnim.finish();
		}
		else
		{
			atlas.anim.curFrame = atlas.anim.length - 1;
		}
	}

	public function get_animPaused():Bool
	{
		if (isAnimationNull())
		{
			return false;
		}

		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.isPlaying;
	}

	public function set_animPaused(value:Bool):Bool
	{
		if (isAnimationNull())
		{
			return value;
		}

		if (!isAnimateAtlas)
		{
			animation.curAnim.paused = value;
		}
		else
		{
			if (value)
			{
				atlas.anim.pause();
			}
			else
			{
				atlas.animation.resume();
			}
		} 

		return value;
	}

	public function dance(alt:Bool = false)
	{
		var altStr:String = "";

		if (alt)
		{
			altStr = "-alt";
		}

		if (!debugMode && !skipDance && !specialAnim && canDance)
		{
			if (danceIdle)
			{
				danced = !danced;

				if (danced)
				{
					playAnim('danceRight' + idleSuffix + altStr, true);
				}
				else
				{
					playAnim('danceLeft' + idleSuffix + altStr, true);
				}
			}
			else if (animation.getByName('idle' + idleSuffix + altStr) != null)
			{
				if (animation.curAnim != null)
				{
					if (!animation.getByName('idle' + idleSuffix + altStr).looped || animation.curAnim.name != "idle" + idleSuffix + altStr)
					{
						playAnim('idle' + idleSuffix + altStr, true);
					}
				}
				else
				{
					playAnim('idle' + idleSuffix + altStr, true);
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.toLowerCase().startsWith('sing') && !canSing)
		{
			return;
		}

		if (AnimName.startsWith("sing"))
		{
			if (AnimName.startsWith("singLEFT"))
			{
				if (curCharacter == "rulez")
				{
					curFunnyPosition = [-64, 0];
				}
				else
				{
					curFunnyPosition = [-8, 0];
				}
			}
			else if (AnimName.startsWith("singDOWN"))
			{
				if (curCharacter == "rulez")
				{
					curFunnyPosition = [0, 136];
				}
				else
				{
					curFunnyPosition = [0, 8];
				}
			}
			else if (AnimName.startsWith("singUP"))
			{
				if (curCharacter == "rulez")
				{
					curFunnyPosition = [0, -48];
				}
				else
				{
					curFunnyPosition = [0, -8];
				}
			}
			else if (AnimName.startsWith("singRIGHT"))
			{
				if (curCharacter == "rulez")
				{
					curFunnyPosition = [48, 0];
				}
				else
				{
					curFunnyPosition = [8, 0];
				}
			}
			else
			{
				curFunnyPosition = [0, 0];
			}
		}
		else
		{
			curFunnyPosition = [0, 0];
		}

		specialAnim = false;

		if (!isAnimateAtlas)
		{
			animation.play(AnimName, Force, Reversed, Frame);
		}
		else
		{
			atlas.playAnimation(AnimName, Force, false, false);
		}

		if (animOffsets.exists(AnimName))
		{
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0], daOffset[1]);
		}

		if (curCharacter.startsWith('gf-') || curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public function recalculateDanceIdle()
	{
		var lastDanceIdle:Bool = danceIdle;

		danceIdle = (animOffsets.exists('danceLeft' + idleSuffix) && animOffsets.exists('danceRight' + idleSuffix));

		if (settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;

			if (danceIdle)
			{
				calc /= 2;
			}
			else
			{
				calc *= 2;
			}

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}

		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	public override function draw()
	{
		if (isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		
		super.draw();
	}

	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}

	public override function destroy()
	{
		destroyAtlas();
		super.destroy();
	}

	public function destroyAtlas()
	{
		if (atlas != null)
		{
			atlas = FlxDestroyUtil.destroy(atlas);
		}
	}
}