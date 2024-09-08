package states;

import backend.ClientPrefs;
import flixel.util.FlxStringUtil;
import backend.Conductor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import util.CoolUtil;
import util.MemoryUtil;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class ResultsState extends MusicBeatState
{
    public var screenshotBackdrop:FlxBackdrop;

    public var resultsText:FlxSprite;

    public var nopeboyRes:FlxSprite;

    public var score:Int = 0;
    public var hiscore:Int = 0;

    public var scoreLerp:Int = 0;
    public var hiscoreLerp:Int = 0;

    public var synergys:Int = 0;
    public var goods:Int = 0;
    public var eghs:Int = 0;
    public var bleghs:Int = 0;
    public var total:Int = 0;

    public var synergysLerp:Int = 0;
    public var goodsLerp:Int = 0;
    public var eghsLerp:Int = 0;
    public var bleghsLerp:Int = 0;
    public var totalLerp:Int = 0;

    public var missed:Int = 0;
    public var missedLerp:Int = 0;

    public var percent:Float = 0;
    public var percentLerp:Float = 0;

    public var statsText:FlxText;
    public var scoreText:FlxText;

    public var botplay:Bool;
    
    public var yellow:FlxSprite;
    public var sideGuy:FlxSprite;
    public var botplayThing:FlxSprite;

    public var elapsedTotal:Float;

    public var bgMovementMulti:Float = 0;
    public var bgMovementMultiTarget:Float = 1;

    public var selectedSomethin:Bool = false;

    public override function new(score:Int = 0, hiscore:Int = 0, synergys:Int = 0, goods:Int = 0, eghs:Int = 0, bleghs:Int = 0, botplay:Bool = false, percent:Float = 0, missed:Int = 0)
    {
        super();

        this.score = score;
        this.hiscore = hiscore;
        this.synergys = synergys;
        this.goods = goods;
        this.eghs = eghs;
        this.bleghs = bleghs;
        this.total = synergys + goods + eghs + bleghs;
        this.botplay = botplay;
        this.percent = percent;
        this.missed = missed;
    }

	override function create()
    {
        #if DEVELOPERBUILD
		var perf = new Perf("Total ResultsState create()");
		#end

        persistentUpdate = true;
		persistentDraw = true;

        CoolUtil.rerollRandomness();

        MemoryUtil.collect(true);
        MemoryUtil.compact();

        FlxG.sound.music.stop();
        FlxG.sound.music = null;

        FlxG.sound.playMusic(Paths.music('mus_quarterly_report'));
        Conductor.songPosition = 0;
        Conductor.changeBPM(112);

        screenshotBackdrop = new FlxBackdrop(FlxGraphic.fromBitmapData(CoolUtil.lastStateScreenShot.bitmapData));
        screenshotBackdrop.repeatAxes = XY;
        FlxTween.tween(screenshotBackdrop, {'scale.x': 0.25, 'scale.y': 0.25}, 1, {startDelay: 0.25, ease: FlxEase.circOut});
        screenshotBackdrop.antialiasing = ClientPrefs.globalAntialiasing;
        add(screenshotBackdrop);

        yellow = new FlxSprite().makeGraphic(1, 1, FlxColor.fromRGB(255, 204, 102));
        yellow.scale.set(2560, 2560);
        yellow.updateHitbox();
        yellow.screenCenter();
        yellow.blend = SCREEN;
        yellow.alpha = 0;
        add(yellow);
        FlxTween.tween(yellow, {alpha: 0.65}, 1, {ease: FlxEase.expoIn, startDelay: 0.1});

        nopeboyRes = new FlxSprite(275, -514);
        nopeboyRes.frames = Paths.getSparrowAtlas('results/nopeboy');
        nopeboyRes.animation.addByPrefix('results', 'results', 24, false);
        nopeboyRes.animation.play('results', true);
        nopeboyRes.antialiasing = ClientPrefs.globalAntialiasing;
        add(nopeboyRes);

        sideGuy = new FlxSprite().loadGraphic(Paths.image('results/side'));
        sideGuy.antialiasing = ClientPrefs.globalAntialiasing;
        sideGuy.x -= 750;
        add(sideGuy);
        FlxTween.tween(sideGuy, {x: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 1});

        resultsText = new FlxSprite(12, 22);
        resultsText.frames = Paths.getSparrowAtlas('results/textbop');
        resultsText.animation.addByPrefix('textbop', 'textbop', 24, false);
        resultsText.animation.play('textbop', true);
        resultsText.y -= 300;
        resultsText.antialiasing = ClientPrefs.globalAntialiasing;
        add(resultsText);
        FlxTween.tween(resultsText, {y: 22}, 0.4, {ease: FlxEase.backOut, startDelay: 1.75});

        statsText = new FlxText(26, 246, 683, 'Missed: 0\nBlegh: 0\nEgh: 0\nGood: 0\nSynergy: 0\nTotal: 0\nPercent: 0%', 38);
        statsText.setFormat(Paths.font('BAUHS93.ttf'), 38, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        statsText.borderSize = 2;
        statsText.alpha = 0;
        statsText.antialiasing = ClientPrefs.globalAntialiasing;
        add(statsText);

        scoreText = new FlxText(26, 599, 683, 'Score: 0\nHi-Score: 0', 52);
        scoreText.setFormat(Paths.font('BAUHS93.ttf'), 52, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        scoreText.borderSize = 2;
        scoreText.alpha = 0;
        scoreText.antialiasing = ClientPrefs.globalAntialiasing;
        add(scoreText);

        FlxTween.tween(statsText, {alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 1.8});
        FlxTween.tween(scoreText, {alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 1.85});

        botplayThing = new FlxSprite(FlxG.width - 130, 2).loadGraphic(Paths.image('ui/botplay'));
        botplayThing.scale.set(0.5, 0.5);
        botplayThing.updateHitbox();
        botplayThing.alpha = 0.75;
        add(botplayThing);
        botplayThing.visible = botplay;

        #if DEVELOPERBUILD
		var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width, "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        versionShit.antialiasing = ClientPrefs.globalAntialiasing;
		add(versionShit);
		#end

        #if DEVELOPERBUILD
        perf.print();
        #end

        super.create();
    }

    override function update(elapsed:Float)
    {
        elapsedTotal += elapsed;
        
        if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
        
        if ((controls.ACCEPT || controls.BACK) && !selectedSomethin)
		{
			selectedSomethin = true;

			FlxG.sound.play(Paths.sound('confirmMenu'));

            FlxG.sound.music.stop();
            FlxG.sound.music = null;

            bgMovementMultiTarget = 0;

            FlxTween.tween(nopeboyRes, {alpha: 0}, 0.25, {ease: FlxEase.circIn});
            FlxTween.tween(sideGuy, {x: sideGuy.x - 800}, 0.25, {ease: FlxEase.circIn});
            FlxTween.tween(resultsText, {x: resultsText.x - 800}, 0.25, {ease: FlxEase.circIn});
            FlxTween.tween(statsText, {x: statsText.x - 800}, 0.25, {ease: FlxEase.circIn});
            FlxTween.tween(scoreText, {x: scoreText.x - 800}, 0.25, {ease: FlxEase.circIn});

            var fuck:FlxTimer = new FlxTimer().start(0.75, function dire(fuckse:FlxTimer)
            {
                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.switchState(new MainMenuState()); 
            });
        }

        if (botplayThing != null)
        {
            botplayThing.angle += Math.cos(elapsedTotal) * 0.25;
        }

        if (statsText.alpha != 0)
        {
            synergysLerp = Math.floor(FlxMath.lerp(synergysLerp, synergys, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            goodsLerp = Math.floor(FlxMath.lerp(goodsLerp, goods, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            eghsLerp = Math.floor(FlxMath.lerp(eghsLerp, eghs, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            bleghsLerp = Math.floor(FlxMath.lerp(bleghsLerp, bleghs, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            totalLerp = Math.floor(FlxMath.lerp(totalLerp, total, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            missedLerp = Math.floor(FlxMath.lerp(missedLerp, missed, CoolUtil.boundTo(elapsed * 16, 0, 1)));
            percentLerp = Math.ffloor((FlxMath.lerp(percentLerp, percent, CoolUtil.boundTo(elapsed * 16, 0, 1))) * 10) / 10;

            if (Math.abs(synergysLerp - synergys) <= 30)
            {
                synergysLerp = synergys;
            }

            if (Math.abs(goodsLerp - goods) <= 30)
            {
                goodsLerp = goods;
            }
            
            if (Math.abs(eghsLerp - eghs) <= 30)
            {
                eghsLerp = eghs;
            }

            if (Math.abs(bleghsLerp - bleghs) <= 30)
            {
                bleghsLerp = bleghs;
            }

            if (Math.abs(totalLerp - total) <= 30)
            {
                totalLerp = total;
            }

            if (Math.abs(missedLerp - missed) <= 30)
            {
                missedLerp = missed;
            }

            if (Math.abs(percentLerp - percent) <= 5)
            {
                percentLerp = percent;
            }
        }

        if (scoreText.alpha != 0)
        {
            scoreLerp = Math.floor(FlxMath.lerp(scoreLerp, score, CoolUtil.boundTo(elapsed * 24, 0, 1)));
            hiscoreLerp = Math.floor(FlxMath.lerp(hiscoreLerp, hiscore, CoolUtil.boundTo(elapsed * 24, 0, 1)));

            if (Math.abs(scoreLerp - score) <= 25)
            {
                scoreLerp = score;
            }

            if (Math.abs(hiscoreLerp - hiscore) <= 25)
            {
                hiscoreLerp = hiscore;
            }
        }

        bgMovementMulti = FlxMath.lerp(bgMovementMulti, bgMovementMultiTarget, CoolUtil.boundTo(elapsed * 6, 0, 1));

        var scort:String = FlxStringUtil.formatMoney(scoreLerp, false, true);
        var hiscort:String = FlxStringUtil.formatMoney(hiscoreLerp, false, true);

		super.update(elapsed);

        statsText.text = 'Missed: $missedLerp\nBlegh: $bleghsLerp\nEgh: $eghsLerp\nGood: $goodsLerp\nSynergy: $synergysLerp\nTotal: $totalLerp\nPercent: $percentLerp%';
        scoreText.text = 'Score: $scort\nHi-Score: $hiscort';

        screenshotBackdrop.x += (225 * bgMovementMulti) * elapsed;
        screenshotBackdrop.y += (225 * bgMovementMulti) * elapsed;
    }

    override function beatHit()
    {
        super.beatHit();

        if (curBeat % 2 == 0)
        {
            if (resultsText != null)
            {
                resultsText.animation.play('textbop', true);
            }
        }
    }
}