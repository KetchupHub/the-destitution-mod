#if DEVELOPERBUILD
package editors;

import states.MainMenuState;
import flixel.FlxSprite;
import shaders.*;
import shaders.NtscShaders.NTSCSFilter;
import shaders.NtscShaders.NTSCGlitch;
import shaders.NtscShaders.TVStatic;
import shaders.NtscShaders.Abberation;
import util.CoolUtil;
import states.MusicBeatState;
import util.MemoryUtil;
#if desktop
import backend.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import visuals.Character;

class ShadersTestState extends MusicBeatState
{
	var charPx:Character;
	var charAa:Character;

	public function new()
	{
		super();
	}

	private var camEditor:FlxCamera;

	public var curSelc:Int = 0;

	public var shaderz:Array<Dynamic> = [new AngelShader(), new AngelShader(), new BloomShader(), new BrightnessContrastShader(), new CamDupeShader(), new CRTShader(), new NTSCSFilter(), new NTSCGlitch(), new TVStatic(), new Abberation(0.5), new RippleShader(), new SilhouetteShader(255, 0, 0), new VCRBorder(), new FNAFShader(5)];

	override function create()
	{
		#if DEVELOPERBUILD
		var perf = new Perf("Total ShadersTestState create()");
		#end

		CoolUtil.rerollRandomness();

		MemoryUtil.collect(true);
        MemoryUtil.compact();

		#if desktop
		DiscordClient.changePresence("Shader Test Screen", null, null, '-menus');
		#end

		camEditor = new FlxCamera();
		FlxG.cameras.reset(camEditor);
		FlxG.cameras.setDefaultDrawTarget(camEditor, true);

		var lol:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		lol.screenCenter();
		add(lol);

		charPx = new Character(150, 256, 'bf-mark', true, false);
		add(charPx);
		charAa = new Character(650, 256, 'bf', true, false);
		add(charAa);

		prepShaders();

		FlxG.mouse.visible = true;

		#if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		add(versionShit);
		#end

		super.create();

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P)
		{
			switchShader(-1);
		}
		else if (controls.UI_RIGHT_P)
		{
			switchShader(1);
		}

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		shaderz[curSelc].update(elapsed);

		super.update(elapsed);
	}

	public function switchShader(change:Int)
	{
		curSelc += change;

		if (curSelc >= shaderz.length)
		{
			curSelc = 0;
		}
		else if (curSelc < 0)
		{
			curSelc = shaderz.length - 1;
		}

		trace(curSelc);

		if (curSelc != 0)
		{
			charPx.shader = shaderz[curSelc];
			charAa.shader = shaderz[curSelc];
		}
		else
		{
			charPx.shader = null;
			charAa.shader = null;
		}
	}

	public function prepShaders()
	{
		/**
		 * order: 
		 * none
		 * angelshader
		 * bloomshader
		 * brightnesscontrastshader
		 * camdupeshader
		 * crtshader
		 * ntscsfilter
		 * ntscsglitch
		 * tvstatic
		 * abberation
		 * rippleshader
		 * sillouetteshader
		 * vcrborder
		 * fnafshader
		 */
		shaderz[1].set_strength(1);
		shaderz[1].set_pixelSize(2);
		shaderz[4].set_mult(4);
		shaderz[9].setChrom(0.25);
	}
}
#end