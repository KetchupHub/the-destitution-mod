package songs;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.tweens.FlxEase;

/**
 * Destitution's song class.
 */
class Destitution extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Destitution';
        this.songHasSections = true;
        this.introType = 'Mark';
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
    }

    public override function stepHitEvent(curStep:Float)
    {
        //this is where step hit events go
        super.stepHitEvent(curStep);

        switch(curStep)
        {
            //lipsync shit literally just copied from d-stitution LMAO
            case 128:
                FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, Conductor.crochet / 250);
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom + 0.1}, Conductor.crochet / 500, {ease: FlxEase.cubeOut});
                PlayState.instance.defaultCamZoom += 0.1;
                PlayState.instance.dad.canDance = false;
                PlayState.instance.dad.canSing = false;
                PlayState.instance.dad.playAnim("lipsync", true);
            case 248:
                FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom + 0.2}, Conductor.crochet / 500, {ease: FlxEase.cubeInOut});
                PlayState.instance.defaultCamZoom += 0.2;
            case 256:
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
                PlayState.instance.defaultCamZoom -= 0.3;
                FlxG.camera.flash();
        }
    }
    
    public override function beatHitEvent(curBeat:Float)
    {
        //this is where beat hit events go
        super.beatHitEvent(curBeat);

        switch(curBeat)
        {
            case 288 | 512:
                if(curBeat == 288)
                {
                    PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                    PlayState.instance.dad.destroy();
                    PlayState.instance.dad = new Character(PlayState.instance.dad.x, PlayState.instance.dad.y, 'mark-alt', false, false);
                    PlayState.instance.dadGroup.add(PlayState.instance.dad);

                    FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, Conductor.crochet / 250);
                    FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom + 0.1}, Conductor.crochet / 500, {ease: FlxEase.cubeOut});
                    PlayState.instance.defaultCamZoom += 0.1;
                    PlayState.instance.dad.canDance = false;
                    PlayState.instance.dad.canSing = false;
                    PlayState.instance.dad.playAnim("lipsync", true);

                    Paths.clearUnusedMemory();
                }
                PlayState.instance.bgPlayer.canDance = false;
                PlayState.instance.bgPlayer.playAnim("walk", true);
                var fuckeryWad:Int = 1;
                if(curBeat >= 512)
                {
                    fuckeryWad = 2;
                }
                FlxTween.tween(PlayState.instance.bgPlayer, {x: PlayState.instance.bgPlayerWalkTarget}, 4 * fuckeryWad, {onComplete: function fucksake(ferkck:FlxTween)
                {
                    PlayState.instance.bgPlayer.playAnim("notice", true);
                }});
            case 318:
                FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom + 0.2}, Conductor.crochet / 500, {ease: FlxEase.cubeInOut});
                PlayState.instance.defaultCamZoom += 0.2;
            case 320:
                PlayState.instance.defaultCamZoom -= 0.3;
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
                FlxTween.cancelTweensOf(PlayState.instance.bgPlayer);
                PlayState.instance.bgPlayer.x = PlayState.instance.bgPlayerWalkTarget;
                PlayState.instance.bgPlayer.canDance = true;
                PlayState.instance.bgPlayer.dance();
                FlxG.camera.flash();
                PlayState.instance.bgPlayerWalkTarget += 2800;
            case 576:
                PlayState.instance.defaultCamZoom = 1;
                PlayState.instance.remove(PlayState.instance.ploinkyTransition, true);
                PlayState.instance.ploinkyTransition.cameras = [PlayState.instance.camGame];
                PlayState.instance.add(PlayState.instance.ploinkyTransition);
                PlayState.instance.ploinkyTransition.screenCenter();
                PlayState.instance.ploinkyTransition.scrollFactor.set();
                PlayState.instance.ploinkyTransition.visible = true;
                PlayState.instance.ploinkyTransition.animation.play('1', true);
                PlayState.instance.ploinkyTransition.alpha = 0;
                FlxTween.tween(PlayState.instance.ploinkyTransition, {alpha: 1}, Conductor.crochet / 250);
                FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, Conductor.crochet / 250);
            case 584:
                PlayState.instance.ploinkyTransition.animation.play('2', true);
            case 592:
                PlayState.instance.ploinkyTransition.animation.play('3', true);
            case 600:
                PlayState.instance.ploinkyTransition.animation.play('4', true);
            case 608:
                PlayState.instance.bgPlayer.visible = false;
                PlayState.instance.bgPlayer.destroy();
                PlayState.instance.defaultCamZoom = 0.875;
                FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, Conductor.crochet / 250);
                PlayState.instance.ploinkyTransition.visible = false;
                PlayState.instance.ploinkyTransition.destroy();

                PlayState.instance.starting.visible = false;
                PlayState.instance.starting.destroy();

                PlayState.instance.shoulderCam = true;
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(0, 0, 'ploinky', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                PlayState.instance.dad.screenCenter();
                PlayState.instance.dad.x += 75;
                PlayState.instance.dad.y += 200;

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(-75, -85, 'bf-mark-ploink', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                FlxG.camera.flash();

                PlayState.instance.sectionIntroThing("This is Ploinky");

                Paths.clearUnusedMemory();
            case 800:
                PlayState.instance.dad.canDance = false;
                PlayState.instance.dad.canSing = false;
                PlayState.instance.dad.playAnim('pull', true);
            case 804:
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
                FlxG.camera.flash();
            case 930:
                PlayState.instance.dad.canDance = false;
                PlayState.instance.dad.canSing = false;
                PlayState.instance.dad.playAnim('put', true);
            case 932:
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
                FlxG.camera.flash();
            case 948:
                PlayState.instance.dad.visible = false;
                PlayState.instance.itemManFucked = new FlxSprite(1182 + PlayState.instance.ploinky.x, 586 + PlayState.instance.ploinky.y).loadGraphic(Paths.image("destitution/sacry"));
                PlayState.instance.add(PlayState.instance.itemManFucked);
                FlxG.camera.flash();
            case 1020:
                PlayState.instance.shoulderCam = false;
                PlayState.instance.itemManFucked.visible = false;
                PlayState.instance.itemManFucked.destroy();
                PlayState.instance.dad.alpha = 1;
                FlxG.camera.flash();
                PlayState.instance.ploinky.visible = false;
                PlayState.instance.ploinky.destroy();

                PlayState.instance.dad.visible = true;
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(800, 345, 'item', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                PlayState.instance.dad.x += 160;
                PlayState.instance.dad.y -= 520;
                
                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(-370, 220, 'bf-mark-item', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.x -= 700;
                PlayState.instance.boyfriend.y -= 575;
                
                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();
                PlayState.instance.camZoomingMult = 1.5;
                PlayState.instance.camZoomingDecay = 0.5;
                //chrm ab should start pulsing here
                FlxG.camera.flash();

                PlayState.instance.spaceTimeDadArray[0] = PlayState.instance.dad.x;
                PlayState.instance.spaceTimeDadArray[1] = PlayState.instance.dad.y;
                PlayState.instance.spaceTimeBfArray[0] = PlayState.instance.boyfriend.x;
                PlayState.instance.spaceTimeBfArray[1] = PlayState.instance.boyfriend.y;

                PlayState.instance.sectionIntroThing("I LIEK ITEM");
                
                Paths.clearUnusedMemory();
            case 1148 | 1228:
                FlxG.camera.flash();
                PlayState.instance.camZooming = false;
                PlayState.instance.camZoomingMult = 1;
                PlayState.instance.camZoomingDecay = 1;
                PlayState.instance.space.visible = false;
                PlayState.instance.spaceTime = false;
                PlayState.instance.spaceItems.visible = false;
                if(curBeat >= 1228)
                {
                    for(spitem in PlayState.instance.spaceItems.members)
                    {
                        spitem.destroy();
                    }
                    PlayState.instance.spaceItems.destroy();
                    PlayState.instance.space.destroy();
                }
                PlayState.instance.boyfriend.canDance = true;
                PlayState.instance.boyfriend.canSing = true;
                PlayState.instance.dad.canDance = true;
                PlayState.instance.dad.canSing = true;
                PlayState.instance.dad.setPosition(PlayState.instance.spaceTimeDadArray[0], PlayState.instance.spaceTimeDadArray[1]);
                PlayState.instance.boyfriend.setPosition(PlayState.instance.spaceTimeBfArray[0], PlayState.instance.spaceTimeBfArray[1]);
                PlayState.instance.dad.angle = 0;
                PlayState.instance.boyfriend.angle = 0;
                PlayState.instance.dad.dance();
                PlayState.instance.boyfriend.dance();
            case 1164 | 1236:
                FlxG.camera.flash();
                PlayState.instance.camZooming = true;
                PlayState.instance.camZoomingMult = 1.5;
                PlayState.instance.camZoomingDecay = 1.5;
                if(curBeat <= 1164)
                {
                    PlayState.instance.spaceItems.visible = true;
                    PlayState.instance.spaceTime = true;
                    PlayState.instance.space.visible = true;
                    PlayState.instance.boyfriend.canDance = false;
                    PlayState.instance.boyfriend.canSing = false;
                    PlayState.instance.boyfriend.playAnim("floaty space mcgee", true);
                    PlayState.instance.dad.canDance = false;
                    PlayState.instance.dad.canSing = false;
                    PlayState.instance.dad.playAnim("floaty space mcgee", true);
                }
            case 1324 | 1326 | 1328 | 1330:
                PlayState.instance.defaultCamZoom += 0.05;
            case 1332:
                PlayState.instance.camZoomingMult = 1;
                PlayState.instance.camZoomingDecay = 1;
                //chrm ab should stop pulsing here
                FlxG.camera.flash();
                PlayState.instance.defaultCamZoom -= 0.2;
            case 1340:
                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                FlxTween.tween(PlayState.instance.dad, {alpha: 0}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 0}, Conductor.crochet / 500);
            case 1344:
                PlayState.instance.centerCamOnBg = true;
                PlayState.instance.liek.animation.play("idle", true);
                PlayState.instance.cuttingSceneThing.visible = true;
            case 1348:
                PlayState.instance.cuttingSceneThing.visible = false;
                PlayState.instance.centerCamOnBg = false;
                FlxG.camera.flash();

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(-200, 65, 'bf-mark-annoyed', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.visible = false;
                
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(0, 0, 'whale', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                PlayState.instance.dad.screenCenter();
                PlayState.instance.dad.x += 90;
                PlayState.instance.dad.y += 300;
                
                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                PlayState.instance.dad.alpha = 0;
                PlayState.instance.boyfriend.alpha = 0;
                FlxTween.tween(PlayState.instance.dad, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 1}, Conductor.crochet / 500);

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.sectionIntroThing("Wiggy Whale");
                
                Paths.clearUnusedMemory();
            case 1540:
                //JUMPY FUN PART
                PlayState.instance.whaleFuckShit = true;
            case 1572:
                //DONT MISS, PAL
            case 1604:
                //ok yoyu can miss again
                PlayState.instance.whaleFuckShit = false;
                FlxG.camera.flash();
            case 1768:
                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                FlxTween.tween(PlayState.instance.dad, {alpha: 0}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 0}, Conductor.crochet / 500);
            case 1776:
                PlayState.instance.cuttingSceneThing.visible = true;
                PlayState.instance.liek.visible = false;
                PlayState.instance.liek.destroy();
                PlayState.instance.annoyed.animation.play("idle", true);
                PlayState.instance.centerCamOnBg = true;
            case 1780:
                PlayState.instance.cuttingSceneThing.visible = false;
                PlayState.instance.centerCamOnBg = false;
                PlayState.instance.shoulderCam = true;

                FlxG.camera.flash();

                PlayState.instance.boyfriend.visible = true;
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(-215, -60, 'mark-annoyed', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);

                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                PlayState.instance.dad.alpha = 0;
                PlayState.instance.boyfriend.alpha = 0;
                FlxTween.tween(PlayState.instance.dad, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 1}, Conductor.crochet / 500);

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.sectionIntroThing("Mark Mc. Marketing (B)");

                Paths.clearUnusedMemory();
            case 2036:
                PlayState.instance.rulezGuySlideScaleWorldFunnyClips.animation.play("intro", true);
            case 2044:
                PlayState.instance.rulezGuySlideScaleWorldFunnyClips.animation.play("zoom", true);
            case 2052:
                //i fucking love optimization just kidding i do not
                FlxTween.tween(PlayState.instance.rulezGuySlideScaleWorldFunnyClips, {y: PlayState.instance.rulezGuySlideScaleWorldFunnyClips.y + 20000}, (Conductor.crochet / 250) * 2, {ease: FlxEase.backOut, onComplete: function gaga(dddd:FlxTween)
                {
                    var fucksTimerSake:FlxTimer = new FlxTimer().start(2, function fuuck(stupidFuckler:FlxTimer)
                    {
                        FlxTween.cancelTweensOf(PlayState.instance.rulezGuySlideScaleWorldFunnyClips);
                        PlayState.instance.rulezGuySlideScaleWorldFunnyClips.destroy();
                    });
                }});

                PlayState.instance.shoulderCam = false;
                FlxG.camera.flash();
                PlayState.instance.annoyed.visible = false;
                PlayState.instance.annoyed.destroy();

                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(75, 115, 'rulez', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(0, 0, 'bf-mark-rulez', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);

                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                PlayState.instance.dad.alpha = 0;
                PlayState.instance.boyfriend.alpha = 0;
                FlxTween.tween(PlayState.instance.dad, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 1}, Conductor.crochet / 500);

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.sectionIntroThing("RULEZ GUY");

                Paths.clearUnusedMemory();
            case 2557:
                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                FlxTween.tween(PlayState.instance.dad, {alpha: 0}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 0}, Conductor.crochet / 500);
            case 2560:
                PlayState.instance.cuttingSceneThing.visible = true;
                PlayState.instance.centerCamOnBg = true;
                PlayState.instance.office.animation.play("idle", true);
            case 2564:
                PlayState.instance.cuttingSceneThing.visible = false;

                PlayState.instance.defaultCamZoom = 0.875 - 0.25;
                FlxG.camera.flash();
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(-235, -460, 'crypteh', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(-135, -205, 'bf-mark-crypteh', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);

                PlayState.instance.boyfriend.x -= 1280;

                FlxTween.cancelTweensOf(PlayState.instance.dad);
                FlxTween.cancelTweensOf(PlayState.instance.boyfriend);
                PlayState.instance.dad.alpha = 0;
                PlayState.instance.boyfriend.alpha = 0;
                FlxTween.tween(PlayState.instance.dad, {alpha: 1}, Conductor.crochet / 500);
                FlxTween.tween(PlayState.instance.boyfriend, {alpha: 1, x: PlayState.instance.boyfriend.x + 1280}, Conductor.crochet / 500);

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.remove(PlayState.instance.office, true);
                PlayState.instance.remove(PlayState.instance.dadGroup, true);
                PlayState.instance.remove(PlayState.instance.boyfriendGroup, true);
                PlayState.instance.add(PlayState.instance.dadGroup);
                PlayState.instance.add(PlayState.instance.office);
                PlayState.instance.add(PlayState.instance.boyfriendGroup);

                PlayState.instance.sectionIntroThing("Misteh Crypteh");
                
                Paths.clearUnusedMemory();
            case 2968:
                PlayState.instance.dad.canDance = false;
                PlayState.instance.dad.playAnim("scared", true);
            case 2972:
                PlayState.instance.funBackCamFadeShit = true;
                PlayState.instance.centerCamOnBg = false;
                PlayState.instance.defaultCamZoom += 0.15;
                FlxG.camera.flash();

                PlayState.instance.cryptehB.visible = false;
                PlayState.instance.office.visible = false;

                PlayState.instance.cryptehB.destroy();
                PlayState.instance.office.destroy();

                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(0, 0, 'zam', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                PlayState.instance.dad.screenCenter();
                PlayState.instance.dad.x -= 10;
                PlayState.instance.dad.y += 150;

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend = new Boyfriend(120, 70, 'bf-mark-back', false);
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.screenCenter();
                PlayState.instance.boyfriend.x += 150;
                PlayState.instance.boyfriend.y += 240;
                PlayState.instance.boyfriend.alpha = 0.5;

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.sectionIntroThing("Guy with a Zamboni");

                Paths.clearUnusedMemory();
            case 3499:
                PlayState.instance.zamMarkCamFlipShit.visible = true;
                PlayState.instance.zamMarkCamFlipShit.animation.play("idle", true);
            case 3500:
                PlayState.instance.zamMarkCamFlipShit.visible = false;
                PlayState.instance.zamMarkCamFlipShit.destroy();

                PlayState.instance.defaultCamZoom -= 0.05;
                FlxG.camera.flash();

                PlayState.instance.zamboni.visible = false;
                PlayState.instance.zamboni.destroy();

                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(125, 80, 'mark-angry', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                PlayState.instance.dad.screenCenter();
                PlayState.instance.dad.x += 325;
                PlayState.instance.dad.y += 320;

                PlayState.instance.boyfriend.screenCenter();
                PlayState.instance.boyfriend.x += 185;
                PlayState.instance.boyfriend.y += 350;

                PlayState.instance.dad.alpha = 1;
                PlayState.instance.boyfriend.alpha = 0.5;

                PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
                PlayState.instance.reloadHealthBarColors();

                PlayState.instance.sectionIntroThing("Mark Mc. Marketing (C)");
                
                Paths.clearUnusedMemory();
        }
    }
}