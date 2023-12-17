package;

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

    var loadCooldown:Float = 1;

    var toLoad:Int;

    var finishedPreloading:Bool = false;

    var startedSwitching:Bool = false;

	override function create()
    {
        loadedBar = new FlxBar(74, 199, FlxBarFillDirection.TOP_TO_BOTTOM, 370, 247, this, "loaded", 0, 2, false);
        loadedBar.percent = 0;
        loadedBar.createFilledBar(FlxColor.GRAY, FlxColor.WHITE);
        add(loadedBar);
        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("loadBg"));
        add(bg);
        funkay = new FlxSprite(0, 0).loadGraphic(Paths.image("loadMark"));
        add(funkay);

        switch(PlayState.SONG.song.toLowerCase())
        {
            case 'destitution':
                charactersToLoad = ['mark', 'bf-mark', 'mark-alt', 'mark-annoyed', 'mark-angry', 'ploinky', 'item', 'whale', 'rulez', 'crypteh', 'zam', 'bf-mark-ploink', 'bf-mark-item', 'bf-mark-rulez', 'bf-mark-back', 'bf-mark-crypteh', 'bf-mark-annoyed', 'bg-player', 'stop-loading'];
            case 'superseded':
                charactersToLoad = ['superseded-mark', 'superseded-mark-graph', 'superseded-creature', 'superseded-bf', 'stop-loading'];
            case 'd-stitution':
                charactersToLoad = ['karm', 'd-bf', 'pinkerton', 'd-bf-dark', 'karm-scared', 'd-ili', 'stop-loading'];
            default:
                charactersToLoad = ['bf-mark', 'stop-loading'];
        }

        toLoad = charactersToLoad.length - 1;

        super.create();
    }

    override function update(elapsed:Float)
    {
		super.update(elapsed);

        loadCooldown -= elapsed;

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
                        trace("finished loading");
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
        loadCooldown = 1.25;

        trace("loading " + charName);

        var chrazy:Character = new Character(2000, 2000, charName);
        add(chrazy);
        characters.push(chrazy);
        charactersToLoad.remove(charName);
    }
}