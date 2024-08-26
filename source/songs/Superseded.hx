package songs;

import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import visuals.Boyfriend;
import visuals.Character;
import backend.Conductor;
import states.PlayState;

/**
 * Superseded's song class.
 */
class Superseded extends SongClass
{
	public override function new()
    {
        super();
        this.songNameForDisplay = 'Superseded';
        this.songHasSections = false;
        this.introType = 'Mark'; //wont be used anyways because superseded skips the countdown
        this.gameoverChar = 'bf-dead';
        this.gameoverMusicSuffix = '';
        this.songVariants = ["Normal", "Erect"];
        this.songDescription = "Mark's experimental time machine brings Nopeboy back to 2022 - 20, when everything was terrible!";
        this.startSwing = false;
        this.ratingsType = "";
        this.skipCountdown = true;
        this.preloadCharacters = ['mark-old', 'mark-old-turn', 'bf-old', 'the-creature', 'bf-hunter', 'stop-loading'];
        this.startPpCam = false;
    }

    public override function stepHitEvent(curStep:Float)
    {
        //this is where step hit events go
        super.stepHitEvent(curStep);
    }
    
    public override function beatHitEvent(curBeat:Float)
    {
        //this is where beat hit events go
        super.beatHitEvent(curBeat);

        switch(curBeat)
        {
            case 28:
                PlayState.instance.supersededIntro.animation.play("open", true);
                //PlayState.instance.boyfriend.visible = false;
            case 29:
                PlayState.instance.defaultCamZoom += 15;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.crochet / 500, {ease: FlxEase.quadInOut});
                FlxTween.tween(PlayState.instance.supersededIntro, {y: PlayState.instance.supersededIntro.y - 75}, Conductor.crochet / 500, {ease: FlxEase.quadInOut});
            case 31:
                PlayState.instance.supersededIntro.y += 75;
                PlayState.instance.supersededIntro.visible = false;
                PlayState.instance.defaultCamZoom -= 15.1;
                FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, Conductor.crochet / 1000, {ease: FlxEase.circOut});
            case 32:
                PlayState.instance.tweeningCam = false;
            case 156:
                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(PlayState.instance.dad.x, PlayState.instance.dad.y, 'mark-old-turn', false, false);
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                //PlayState.instance.boyfriend.visible = true;
            case 160:
                FlxG.camera.flash();
                PlayState.instance.defaultCamZoom = 0.875;
            case 304:
                FlxTween.tween(PlayState.instance.theSmog, {alpha: 1}, (Conductor.crochet / 250) * 4, {ease: FlxEase.expoIn});
            case 312:
                PlayState.instance.boyfriend.canSing = false;
                PlayState.instance.boyfriend.canDance = false;
                PlayState.instance.boyfriend.playAnim('notice', true);
            case 320:
                PlayState.instance.boyfriend.canSing = true;
                PlayState.instance.boyfriend.canDance = true;
                FlxG.camera.flash();
                PlayState.instance.defaultCamZoom = 1;
                PlayState.instance.starting.visible = false;
                PlayState.instance.starting.destroy();
                FlxTween.completeTweensOf(PlayState.instance.theSmog);
                PlayState.instance.theSmog.visible = false;
                PlayState.instance.theSmog.destroy();

                PlayState.instance.dadGroup.remove(PlayState.instance.dad);
                PlayState.instance.dad.destroy();
                PlayState.instance.dad = new Character(PlayState.instance.dad.x, PlayState.instance.dad.y, 'the-creature', false, false);
                PlayState.instance.dad.screenCenter();
                PlayState.instance.dad.y -= 128;
                PlayState.instance.dad.y -= 2048;
                PlayState.instance.dadGroup.add(PlayState.instance.dad);
                FlxTween.tween(PlayState.instance.boyfriend, {y: PlayState.instance.boyfriend.y - 832}, 2, {ease: FlxEase.cubeOut});

                PlayState.instance.boyfriendGroup.remove(PlayState.instance.boyfriend);
                PlayState.instance.boyfriend.destroy();
                PlayState.instance.boyfriend = new Boyfriend(PlayState.instance.boyfriend.x, PlayState.instance.boyfriend.y, 'bf-hunter', false);
                PlayState.instance.boyfriend.screenCenter();
                PlayState.instance.boyfriend.y += 348;
                PlayState.instance.boyfriend.y += 832;
                PlayState.instance.boyfriendGroup.add(PlayState.instance.boyfriend);
                FlxTween.tween(PlayState.instance.boyfriend, {y: PlayState.instance.boyfriend.y - 832}, 2, {ease: FlxEase.cubeOut});

                PlayState.instance.dadGroup.scrollFactor.set(0, 0);
                PlayState.instance.boyfriendGroup.scrollFactor.set(0, 0);
            case 328:
                FlxTween.tween(PlayState.instance.dad, {y: PlayState.instance.dad.y + 2048}, 1, {ease: FlxEase.backInOut});
        }
    }
}