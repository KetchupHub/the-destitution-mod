package states;

import visuals.Character;
import util.CoolUtil;
import util.MemoryUtil;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class LoadScreenPreloadGah extends MusicBeatState
{
    var funkay:FlxSprite;

    var loadedBar:FlxBar;

    var charactersToLoad:Array<String> = [];

    var characters:Array<Character> = [];

    var loadCooldown:Float = 0.25;

    var toLoad:Int;

    var finishedPreloading:Bool = false;

    var startedSwitching:Bool = false;

    var holdingEscText:FlxText;

    var escHoldTimer:Float;

	override function create()
    {
        CoolUtil.rerollRandomness();

        MemoryUtil.collect(true);
        MemoryUtil.compact();

        loadedBar = new FlxBar(74, 199, FlxBarFillDirection.TOP_TO_BOTTOM, 370, 247, this, "loaded", 0, 2, false);
        loadedBar.percent = 0;
        loadedBar.createFilledBar(FlxColor.GRAY, FlxColor.WHITE);
        add(loadedBar);
        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("loading/loadBg"));
        bg.scale.set(2, 2);
        bg.updateHitbox();
        add(bg);
        var marksSuffix:String = "";
        //1/32 chance
        if(CoolUtil.randomVisuals.bool(3.125))
        {
            marksSuffix = "_secret";
        }
        funkay = new FlxSprite(0, 0).loadGraphic(Paths.image("loading/loadMark" + marksSuffix));
        funkay.scale.set(2, 2);
        funkay.updateHitbox();
        add(funkay);

        switch(PlayState.SONG.song.toLowerCase())
        {
            case 'destitution':
                charactersToLoad = ['mark', 'bf-mark', 'mark-alt', 'mark-annoyed', 'mark-angry', 'ploinky', 'item', 'whale', 'rulez', 'crypteh', 'zam', 'bf-mark-ploink', 'bf-mark-item', 'bf-mark-rulez', 'bf-mark-back', 'bf-mark-crypteh', 'bf-mark-annoyed', 'bg-player', 'stop-loading'];
            /*case 'superseded':
                charactersToLoad = ['superseded-mark', 'superseded-mark-graph', 'superseded-creature', 'superseded-bf', 'stop-loading'];*/
            case 'd-stitution':
                charactersToLoad = ['karm', 'd-bf', 'pinkerton', 'd-bf-dark', 'd-ili', 'd-bf-doug', 'douglass', 'karm-scold', 'douglass-player', 'd-rules', 'd-bf-rules', 'maestro', 'd-bf-rules-flipped', 'zamboney', 'karm-finale', 'stop-loading'];
            default:
                charactersToLoad = ['bf', 'gf', 'stop-loading'];
        }

        toLoad = charactersToLoad.length - 1;

        #if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		add(versionShit);
		#end

        holdingEscText = new FlxText(6, FlxG.height - 28, FlxG.width - 4, 'Going Back...', 16);
        holdingEscText.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 2);
        holdingEscText.scrollFactor.set();
        holdingEscText.alpha = 0;
        add(holdingEscText);

        super.create();
    }

    override function update(elapsed:Float)
    {
		super.update(elapsed);

        loadCooldown -= elapsed;

        //escape hgolding thing, so if you stop holding for a second the timer doenst completely restart
        if(FlxG.keys.pressed.ESCAPE)
        {
            escHoldTimer += elapsed;
        }
        else
        {
            if(escHoldTimer > 0)
            {
                escHoldTimer -= elapsed;
            }
        }

        if(escHoldTimer >= 1.5)
        {
            startedSwitching = true;
            MusicBeatState.switchState(new MainMenuState());
        }

        holdingEscText.alpha = FlxMath.bound(escHoldTimer * 2, 0, 1);

        if(!startedSwitching)
        {
            if(!finishedPreloading)
            {
                if(loadCooldown <= 0)
                {
                    if(charactersToLoad[0] != "stop-loading")
                    {
                        preloadCharacter(charactersToLoad[0]);
                    }
                    else
                    {
                        #if DEVELOPERBUILD
                        trace("finished loading");
                        #end
                        loadCooldown = 1;
                        finishedPreloading = true;
                    }
                }
            }
            else if(finishedPreloading && loadCooldown >= 0)
            {
                startedSwitching = true;
                MusicBeatState.switchState(new PlayState());
            }
        }

        loadedBar.percent = ((charactersToLoad.length - 1) / toLoad) * 100;

        if(FlxG.keys.justPressed.SPACE)
        {
            funkay.y = 100;
        }

        funkay.y = FlxMath.lerp(0, funkay.y, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
    }

    public function preloadCharacter(charName:String) 
    {
        //perf leads me to believe that 0.6 is the maximum reasonable character load time
        loadCooldown = 0.6;
        if(FlxG.keys.pressed.SHIFT)
        {
            //speedup for impatient people (me)
            loadCooldown = 0.25;
        }

        #if DEVELOPERBUILD
        var perf = new Perf("Preload Character: " + charName);
        trace("loading " + charName);
        #end

        var chrazy:Character = new Character(1279, 719, charName);
        chrazy.scale.set(0.1, 0.1);
        chrazy.updateHitbox();
        chrazy.alpha = 0.05;
        add(chrazy);
        insert(members.indexOf(funkay) - 1, chrazy);
        characters.push(chrazy);
        charactersToLoad.remove(charName);

        #if DEVELOPERBUILD
        perf.print();
        #end
    }
}