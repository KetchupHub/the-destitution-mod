package songs;

import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;

/**
 * New Hampshire's song class.
 */
class NewHampshireErect extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'New Hampshire (ERECT)';
        this.songHasSections = false;
        this.introType = 'Default';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
        //songVariants literally does not matter for any of the variant classes lol
        this.songDescription = "More alternate universe shenanigans?! This time, it's just Mark's bucksian-self and Nopeboy angling to impress!";
        this.startSwing = false;
        this.ratingsType = "";
        this.skipCountdown = false;
        this.preloadCharacters = ['bucks-mark', 'bucks-bf', 'brokerboy', 'stop-loading'];
        this.startPpCam = false;
    }

    public override function stepHitEvent(curStep:Float)
    {
        //this is where step hit events go
        super.stepHitEvent(curStep);
        switch (curStep)
        {
            case 122:
                PlayState.instance.defaultCamZoom += 0.35;
                PlayState.instance.camGame.zoom = PlayState.instance.defaultCamZoom;
                PlayState.instance.moveCamera(true);
                PlayState.instance.disallowCamMove = true;
                PlayState.instance.snapCamFollowToPos(PlayState.instance.camFollow.x, PlayState.instance.camFollow.y);
            case 128:
                PlayState.instance.disallowCamMove = false;
                PlayState.instance.defaultCamZoom -= 0.2;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.stepCrochet / 500, {ease: FlxEase.circOut});
            case 160:
                PlayState.instance.defaultCamZoom -= 0.15;
            case 184 | 188:
                PlayState.instance.defaultCamZoom += 0.05;
            case 186 | 190:
                PlayState.instance.defaultCamZoom += 0.1;
            case 192:
                PlayState.instance.defaultCamZoom -= 0.3;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.crochet / 500, {ease: FlxEase.expoOut});
            case 204 | 206:
                PlayState.instance.defaultCamZoom += 0.1;
            case 208:
                PlayState.instance.defaultCamZoom += 0.05;
                FlxG.camera.flash();
            case 272:
                PlayState.instance.defaultCamZoom -= 0.15;
            case 326 | 332:
                PlayState.instance.defaultCamZoom += 0.1;
            case 336:
                PlayState.instance.defaultCamZoom -= 0.3;
                FlxG.camera.flash();
            case 400 | 402 | 408 | 410 | 416 | 418:
                PlayState.instance.defaultCamZoom += 0.05;
            case 404 | 412 | 420 | 426 | 428 | 430:
                PlayState.instance.defaultCamZoom += 0.1;
            case 406 | 414 | 422:
                PlayState.instance.defaultCamZoom -= 0.2;
            case 432:
                PlayState.instance.defaultCamZoom -= 0.3;
            case 464:
                PlayState.instance.defaultCamZoom += 0.15;
            case 496 | 524 | 526:
                PlayState.instance.defaultCamZoom -= 0.05;
            case 528:
                FlxG.camera.flash();
            case 584:
                PlayState.instance.defaultCamZoom += 0.35;
            case 592:
                PlayState.instance.defaultCamZoom -= 0.35;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.stepCrochet / 250, {ease: FlxEase.expoOut});
            case 734:
                PlayState.instance.defaultCamZoom -= 0.05;
            case 736:
                PlayState.instance.defaultCamZoom += 0.25;
        }
    }

    public var whichEndingYouGet:Int = 0;
    
    public override function beatHitEvent(curBeat:Float)
    {
        //this is where beat hit events go
        super.beatHitEvent(curBeat);

        //turning rating funny
        switch(curBeat)
        {
            case 165:
                {
                    PlayState.instance.dad.canDance = false;
                    PlayState.instance.dad.canSing = false;
                    PlayState.instance.dad.playAnim('lookBack', true);
                    PlayState.instance.stockboy.playAnim('walk', true);
                    PlayState.instance.stockboy.animation.finishCallback = function dirt(namb:String)
                    {
                        PlayState.instance.stockboy.animation.finishCallback = null;
                        PlayState.instance.brokerBop = true;
                        PlayState.instance.stockboy.playAnim('idle', true);
                        PlayState.instance.stockboy.finishAnimation();
                    }
                }
            case 175:
                {
                    if (PlayState.instance.cpuControlled)
                    {
                        whichEndingYouGet = 0;
                        PlayState.instance.dad.playAnim('turnHappy', true);
                    }
                    else
                    {
                        switch (Std.int((PlayState.instance.ratingPercent * 10) - 1))
                        {
                            case 0 | 1 | 2 | 3:
                                {
                                    whichEndingYouGet = 2;
                                    PlayState.instance.dad.playAnim('turnSad', true);
                                    PlayState.instance.brokerBop = false;
                                    PlayState.instance.stockboy.playAnim('die', true);
                                }
                            case 7 | 8 | 9 | 10:
                                {
                                    whichEndingYouGet = 0;
                                    PlayState.instance.dad.playAnim('turnHappy', true);
                                }
                            default:
                                {
                                    whichEndingYouGet = 1;
                                    PlayState.instance.dad.playAnim('turnNeutral', true);
                                }
                        }
                    }
                }
            case 178:
                {
                    PlayState.instance.dad.canDance = true;
                    PlayState.instance.dad.canSing = true;
                }
        }
    }
}