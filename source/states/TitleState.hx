package states;

import util.EaseUtil;
import visuals.PixelPerfectSprite;
import ui.MarkHeadTransition;
import flixel.graphics.FlxGraphic;
import shaders.ColorSwap;
import backend.Highscore;
import backend.PlayerSettings;
import backend.WeekData;
import backend.ClientPrefs;
import ui.Alphabet;
import backend.Conductor;
import util.CoolUtil;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

class TitleState extends MusicBeatState
{
  public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
  public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
  public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

  public static var initialized:Bool = false;

  public var transitioning:Bool = false;

  public var newTitle:Bool = false;

  public var titleTimer:Float = 0;

  public var sickBeats:Int = 0;

  public var blackScreen:PixelPerfectSprite;

  public var credGroup:FlxGroup;
  public var credTextShit:Alphabet;
  public var textGroup:FlxTypedGroup<Alphabet>;

  public var exitButton:PixelPerfectSprite;
  public var playButton:PixelPerfectSprite;

  public var charec:String = 'mark';

  public var curWacky:Array<String> = [];

  public var tppLogo:PixelPerfectSprite;

  public var mustUpdate:Bool = false;

  public var skippedIntro:Bool = false;

  public var increaseVolume:Bool = false;

  public var logo:PixelPerfectSprite;

  public var titleCharacter:PixelPerfectSprite;

  public var swagShader:ColorSwap = null;

  public var closeSequenceStarted:Bool = false;

  public var quitDoingIntroShit:Bool = false;

  public static var closedState:Bool = false;

  override public function create():Void
  {
    #if DEVELOPERBUILD
    var perf = new Perf("Total TitleState create()");
    #end

    persistentUpdate = true;
    persistentDraw = true;

    WeekData.loadTheFirstEnabledMod();

    FlxG.sound.muteKeys = muteKeys;
    FlxG.sound.volumeDownKeys = volumeDownKeys;
    FlxG.sound.volumeUpKeys = volumeUpKeys;

    FlxG.keys.preventDefaultKeys = [TAB];

    PlayerSettings.init();

    curWacky = CoolUtil.randomLogic.getObject(getIntroTextShit());

    swagShader = new ColorSwap();

    super.create();

    Application.current.window.title = CoolUtil.appTitleString;

    FlxG.mouse.load(Paths.image('cursor').bitmap, 2);

    FlxG.save.bind('destitution', CoolUtil.getSavePath());

    ClientPrefs.loadPrefs();

    Highscore.load();

    if (!initialized)
    {
      if (FlxG.save.data != null && FlxG.save.data.fullscreen)
      {
        FlxG.fullscreen = FlxG.save.data.fullscreen;
      }
    }

    FlxG.mouse.visible = true;

    if (FlxG.save.data.flashing == null && !FlashingState.leftState)
    {
      FlxTransitionableState.skipNextTransIn = false;
      FlxTransitionableState.skipNextTransOut = false;

      MarkHeadTransition.nextCamera = FlxG.camera;

      MusicBeatState.switchState(new FlashingState());
    }
    else
    {
      if (initialized)
      {
        startIntro();
      }
      else
      {
        new FlxTimer().start(1, function(tmr:FlxTimer) {
          startIntro();
        });
      }
    }

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  public function startIntro()
  {
    CoolUtil.hasInitializedWindow = true;

    #if DEVELOPERBUILD
    var perf = new Perf("TitleState startIntro()");
    #end

    if (!initialized)
    {
      if (FlxG.sound.music == null)
      {
        FlxG.sound.playMusic(Paths.music('mus_pauperized'), 0);
        Conductor.changeBPM(150);
      }
    }

    persistentUpdate = true;

    var bg:FlxSprite = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    add(bg);

    swagShader = new ColorSwap();

    if (initialized)
    {
      CoolUtil.rerollRandomness();
    }

    var arrey:Array<String> = ['bf', 'crypteh', 'ili', 'karm', 'mark', 'ploinky', 'rulez', 'whale'];
    if (CoolUtil.randomLogic.bool(10))
    {
      arrey = ['blocken', 'plant'];
    }
    var holidayChar = CoolUtil.getHolidayCharacter();
    if (holidayChar != null)
    {
      // should i be nice and make the holidays the only ones you can get on that day?
      // nah
      // except as im typing this i realize that seems like a dick move so i wont
      // still ends up trolling the people who wouldve rolled the 1/10 chance ones though so lol
      arrey = [holidayChar];
    }
    charec = arrey[CoolUtil.randomVisuals.int(0, arrey.length - 1)];
    if (Paths.image('title/char/$charec', null, true) == null)
    {
      // precaution
      charec = 'mark';
    }
    #if SHOWCASEVIDEO
    // force set to mark for showcase video, cuz i want it to be as non random as possible.
    charec = 'mark';
    #end
    titleCharacter = new PixelPerfectSprite(0, 0).loadGraphic(Paths.image('title/char/$charec'), true, 320, 360);
    titleCharacter.animation.add(charec, [0, 1], 0, false);
    titleCharacter.animation.play(charec, true);
    titleCharacter.antialiasing = false;
    titleCharacter.scale.set(2, 2);
    titleCharacter.updateHitbox();
    titleCharacter.shader = swagShader.shader;
    add(titleCharacter);

    var objects:PixelPerfectSprite = new PixelPerfectSprite(640, 0).loadGraphic(Paths.image('title/obj'));
    objects.antialiasing = false;
    objects.scale.set(2, 2);
    objects.updateHitbox();
    objects.shader = swagShader.shader;
    add(objects);

    logo = new PixelPerfectSprite(490, 0);
    logo.frames = Paths.getSparrowAtlas('title/logo');
    logo.antialiasing = false;
    logo.animation.addByPrefix('bump', 'idle', 24, false);
    logo.animation.play('bump');
    add(logo);

    var tppWatermarkTittle:PixelPerfectSprite = new PixelPerfectSprite(8, 590).loadGraphic(Paths.image("title/tpp"));
    tppWatermarkTittle.setGraphicSize(256);
    tppWatermarkTittle.updateHitbox();
    add(tppWatermarkTittle);

    exitButton = new PixelPerfectSprite(8, 8).loadGraphic(Paths.image('title/close'));
    exitButton.scale.set(2, 2);
    exitButton.updateHitbox();
    add(exitButton);

    playButton = new PixelPerfectSprite(FlxG.width - 210, FlxG.height - 210).loadGraphic(Paths.image('title/play'));
    playButton.scale.set(2, 2);
    playButton.updateHitbox();
    add(playButton);

    credGroup = new FlxGroup();
    add(credGroup);

    textGroup = new FlxTypedGroup<Alphabet>();

    blackScreen = new PixelPerfectSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    credGroup.add(blackScreen);

    credTextShit = new Alphabet(0, 20, "", true);
    credTextShit.screenCenter();
    credTextShit.visible = false;

    tppLogo = new PixelPerfectSprite().loadGraphic(Paths.image("title/tpp"));
    tppLogo.screenCenter();
    tppLogo.y = 70;
    tppLogo.antialiasing = false;
    tppLogo.visible = false;
    add(tppLogo);

    var transThing:FlxSprite = new FlxSprite();

    if (CoolUtil.lastStateScreenShot != null)
    {
      transThing.loadGraphic(FlxGraphic.fromBitmapData(CoolUtil.lastStateScreenShot.bitmapData));
      add(transThing);
      FlxTween.tween(transThing, {alpha: 0}, 0.25,
        {
          startDelay: 0.05,
          ease: EaseUtil.stepped(4),
          onComplete: function transThingDiesIrl(stupidScr:FlxTween)
          {
            transThing.visible = false;
            transThing.destroy();
          }
        });
    }

    #if DEVELOPERBUILD
    var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width,
      "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
    versionShit.scrollFactor.set();
    versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    versionShit.antialiasing = ClientPrefs.globalAntialiasing;
    add(versionShit);
    #end

    if (initialized)
    {
      skipIntro(true);
    }
    else
    {
      initialized = true;
    }

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  public function getIntroTextShit():Array<Array<String>>
  {
    var fullText:String = Assets.getText(Paths.txt('introText'));

    var firstArray:Array<String> = fullText.split('\n');
    var swagGoodArray:Array<Array<String>> = [];

    for (i in firstArray)
    {
      swagGoodArray.push(i.split('--'));
    }

    return swagGoodArray;
  }

  override function update(elapsed:Float)
  {
    if (!closeSequenceStarted)
    {
      if (FlxG.sound.music != null)
      {
        Conductor.songPosition = FlxG.sound.music.time;
      }

      var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

      var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

      if (gamepad != null)
      {
        if (gamepad.justPressed.START)
        {
          pressedEnter = true;
        }
      }

      if (!transitioning)
      {
        if (skippedIntro && FlxG.mouse.overlaps(exitButton, FlxG.camera) && !transitioning)
        {
          if (FlxG.mouse.justPressed)
          {
            gameCloseSequence();
          }
        }

        if (skippedIntro && FlxG.mouse.overlaps(playButton, FlxG.camera) && !transitioning)
        {
          if (FlxG.mouse.justPressed)
          {
            pressedEnter = true;
          }
        }
      }

      if (newTitle)
      {
        titleTimer += CoolUtil.boundTo(elapsed, 0, 1);

        if (titleTimer > 2)
        {
          titleTimer -= 2;
        }
      }

      if (initialized && !transitioning && skippedIntro)
      {
        if (newTitle && !pressedEnter)
        {
          var timer:Float = titleTimer;

          if (timer >= 1)
          {
            timer = (-timer) + 2;
          }

          timer = FlxEase.quadInOut(timer);
        }

        if (pressedEnter)
        {
          // FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF);
          FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

          transitioning = true;

          FlxTween.tween(playButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.25,
            {
              ease: EaseUtil.stepped(4),
              onComplete: function fuckstween(t:FlxTween)
              {
                playButton.alpha = 0;
                playButton.visible = false;
                playButton.destroy();
              }
            });

          FlxTween.tween(exitButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.25,
            {
              ease: EaseUtil.stepped(4),
              onComplete: function fuckstween(t:FlxTween)
              {
                exitButton.alpha = 0;
                exitButton.visible = false;
                exitButton.destroy();
              }
            });

          new FlxTimer().start(1, function(tmr:FlxTimer) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;

            MusicBeatState.switchState(new MainMenuState());

            closedState = true;
          });
        }
      }

      if (initialized && pressedEnter && !skippedIntro)
      {
        skipIntro();
      }
    }

    if (swagShader != null)
    {
      if (controls.UI_LEFT && !controls.UI_RIGHT)
      {
        swagShader.hue -= elapsed * 0.1;
      }

      if (controls.UI_RIGHT && !controls.UI_LEFT)
      {
        swagShader.hue += elapsed * 0.1;
      }
    }

    super.update(elapsed);
  }

  public function gameCloseSequence()
  {
    closeSequenceStarted = true;
    titleCharacter.animation.curAnim.curFrame = 0;
    FlxG.sound.music.stop();
    FlxG.sound.play(Paths.sound('titleExit/$charec'), 1, false);

    FlxTween.tween(playButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.25,
      {
        ease: EaseUtil.stepped(4),
        onComplete: function fuckstween(t:FlxTween)
        {
          playButton.alpha = 0;
          playButton.visible = false;
          playButton.destroy();
        }
      });

    FlxTween.tween(exitButton, {'scale.x': 0.01, 'scale.y': 0.01}, 0.25,
      {
        ease: EaseUtil.stepped(4),
        onComplete: function fuckstween(t:FlxTween)
        {
          exitButton.alpha = 0;
          exitButton.visible = false;
          exitButton.destroy();
        }
      });

    var timeyTheTimer:FlxTimer = new FlxTimer().start(2.5, function photoshopTimey(timeyX:FlxTimer)
    {
      Application.current.window.close();
    });
  }

  public function createCoolText(textArray:Array<String>, ?offset:Float = 0)
  {
    for (i in 0...textArray.length)
    {
      var money:Alphabet = new Alphabet(0, 0, textArray[i], true);

      money.screenCenter(X);
      money.y += (i * 70) + 200 + offset;
      money.ID = textGroup.length;

      // money.scaleX = 1.5;
      // money.scaleY = 0.5;
      money.alpha = 0;

      // FlxTween.tween(money, {scaleX: 1, scaleY: 1}, 0.5, {ease: FlxEase.backInOut});
      FlxTween.tween(money, {alpha: 1}, 0.25, {ease: EaseUtil.stepped(4)});

      if (credGroup != null && textGroup != null)
      {
        credGroup.add(money);
        textGroup.add(money);
      }
    }
  }

  public function addMoreText(text:String, ?offset:Float = 0)
  {
    if (textGroup != null && credGroup != null)
    {
      var coolText:Alphabet = new Alphabet(0, 0, text, true);

      coolText.screenCenter(X);
      coolText.y += (textGroup.length * 70) + 200 + offset;
      coolText.ID = textGroup.length;

      // coolText.scaleX = 1.5;
      // coolText.scaleY = 0.5;
      coolText.alpha = 0;

      // FlxTween.tween(coolText, {scaleX: 1, scaleY: 1}, 0.5, {ease: FlxEase.backInOut});
      FlxTween.tween(coolText, {alpha: 1}, 0.25, {ease: EaseUtil.stepped(4)});

      credGroup.add(coolText);
      textGroup.add(coolText);
    }
  }

  public function deleteCoolText()
  {
    while (textGroup.members.length > 0)
    {
      var thist = textGroup.members[0];
      FlxTween.completeTweensOf(thist);
      credGroup.remove(thist, true);
      textGroup.remove(thist, true);
      thist.destroy();
    }
  }

  override function beatHit()
  {
    super.beatHit();

    if (curBeat % 2 == 0)
    {
      if (logo != null)
      {
        logo.animation.play('bump', true);
      }

      if (titleCharacter != null)
      {
        if (titleCharacter.animation.curAnim.curFrame == 0)
        {
          titleCharacter.animation.curAnim.curFrame = 1;
        }
        else
        {
          titleCharacter.animation.curAnim.curFrame = 0;
        }
      }
    }

    if (!closedState && !quitDoingIntroShit)
    {
      sickBeats++;

      switch (sickBeats)
      {
        case 1:
          FlxG.sound.playMusic(Paths.music('mus_pauperized'));
        case 5:
          tppLogo.visible = true;
        case 9:
          createCoolText(['...present'], tppLogo.height);
        case 12:
          tppLogo.visible = false;
          deleteCoolText();
        case 13:
          createCoolText([curWacky[0]]);
        case 17:
          addMoreText(curWacky[1]);
        case 20:
          deleteCoolText();
        case 21:
          addMoreText('The');
        case 25:
          addMoreText('Destitution');
        case 29:
          addMoreText('Mod');
        case 33:
          skipIntro();
      }
    }
  }

  public function skipIntro(skipFade:Bool = false):Void
  {
    CoolUtil.hasInitializedWindow = true;

    if (!skippedIntro)
    {
      quitDoingIntroShit = true;

      remove(tppLogo);

      if (skipFade)
      {
        remove(credGroup);
      }
      else
      {
        for (cool in textGroup)
        {
          FlxTween.tween(cool, {alpha: 0}, 0.25, {startDelay: 0.2 * cool.ID, ease: EaseUtil.stepped(4)});
        }

        FlxTween.tween(blackScreen, {alpha: 0}, 2,
          {
            ease: EaseUtil.stepped(4),
            onComplete: function die(fuuuck:FlxTween)
            {
              remove(credGroup);
            }
          });
      }

      skippedIntro = true;
    }
  }
}