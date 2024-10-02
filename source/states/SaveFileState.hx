package states;

import backend.RpgPrefs;
import util.EaseUtil;
import flixel.math.FlxMath;
import visuals.PixelPerfectSprite;
import flixel.util.FlxSave;
import backend.Conductor;
import backend.ClientPrefs;
import backend.WeekData;
import util.CoolUtil;
import util.MemoryUtil;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if desktop
import backend.Discord.DiscordClient;
#end

class SaveFileState extends MusicBeatState
{
  public static var curSelected:Int = 0;

  public var camGame:FlxCamera;

  public var bg:PixelPerfectSprite;
  public var swirls:PixelPerfectSprite;
  public var guys:PixelPerfectSprite;

  public var indi:PixelPerfectSprite;

  public var slotUsedArray:Array<Bool> = [ClientPrefs.rpgSave1Used, ClientPrefs.rpgSave2Used, ClientPrefs.rpgSave3Used];

  public var slots:Array<PixelPerfectSprite> = [];

  override function create()
  {
    #if DEVELOPERBUILD
    var perf = new Perf("SaveFileState create()");
    #end

    persistentUpdate = true;
    persistentDraw = true;

    CoolUtil.newStateMemStuff();

    FlxG.mouse.visible = false;

    WeekData.loadTheFirstEnabledMod();

    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Picking a Save File", null, null, '-rpg');
    #end

    if (FlxG.sound.music == null)
    {
      FlxG.sound.playMusic(Paths.music('mus_save_select'), 0);
      Conductor.changeBPM(136);
    }

    slotUsedArray = [ClientPrefs.rpgSave1Used, ClientPrefs.rpgSave2Used, ClientPrefs.rpgSave3Used];

    camGame = new FlxCamera();

    FlxG.cameras.reset(camGame);
    FlxG.cameras.setDefaultDrawTarget(camGame, true);

    transIn = FlxTransitionableState.defaultTransIn;
    transOut = FlxTransitionableState.defaultTransOut;

    bg = new PixelPerfectSprite().loadGraphic(Paths.image('saves/bg'));
    bg.scale.set(2, 2);
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    swirls = new PixelPerfectSprite().loadGraphic(Paths.image('saves/swirls'), true, 640, 360);
    swirls.animation.add('idle', [0, 1], 1, true);
    swirls.animation.play('idle', true);
    swirls.scale.set(2, 2);
    swirls.updateHitbox();
    swirls.screenCenter();
    swirls.alpha = 0.25;
    add(swirls);

    guys = new PixelPerfectSprite().loadGraphic(Paths.image('saves/guys'), true, 202, 360);
    guys.animation.add('idle', [0, 1], 3, true);
    guys.animation.play('idle', true);
    guys.scale.set(2, 2);
    guys.updateHitbox();
    guys.x = 1280 - 404;
    add(guys);

    for (i in 1...4)
    {
      var slotterson:PixelPerfectSprite = new PixelPerfectSprite(0, 240 * (i - 1)).loadGraphic(Paths.image('saves/s' + (i)), true, 164, 120);
      slotterson.animation.add('idle', [0, 1], 0, false);
      slotterson.animation.play('idle', true);
      slotterson.scale.set(2, 2);
      slotterson.updateHitbox();
      slotterson.ID = i - 1;
      if (slotUsedArray[i - 1] == true)
      {
        slotterson.animation.frameIndex = 1;
      }
      add(slotterson);
      slots.push(slotterson);
    }

    indi = new PixelPerfectSprite().loadGraphic(Paths.image('saves/indi'));
    indi.scale.set(2, 2);
    indi.updateHitbox();
    indi.pixelPerfectDiv = 4;
    add(indi);

    var title:PixelPerfectSprite = new PixelPerfectSprite().loadGraphic(Paths.image('saves/title'));
    title.scale.set(2, 2);
    title.updateHitbox();
    add(title);

    var delText:FlxText = new FlxText(4, FlxG.height - 24, FlxG.width, "Hold X to delete hovered save!", 12);
    delText.scrollFactor.set();
    delText.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    delText.antialiasing = ClientPrefs.globalAntialiasing;
    add(delText);

    #if DEVELOPERBUILD
    var versionShit:FlxText = new FlxText(-4, FlxG.height - 24, FlxG.width,
      "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
    versionShit.scrollFactor.set();
    versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    versionShit.antialiasing = ClientPrefs.globalAntialiasing;
    add(versionShit);
    #end

    changeItem();

    super.create();

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  var selectedSomethin:Bool = false;

  var delTimer:Float = 0;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music != null)
    {
      if (FlxG.sound.music.volume < 0.8)
      {
        FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
      }

      Conductor.songPosition = FlxG.sound.music.time;
    }

    indi.y = FlxMath.lerp(indi.y, slots[curSelected].y, CoolUtil.boundTo(elapsed * 6, 0, 1));

    if (!selectedSomethin)
    {
      if (controls.UI_UP_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(-1);
      }

      if (controls.UI_DOWN_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(1);
      }

      if (controls.BACK)
      {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        MusicBeatState.switchState(new MainMenuState());
      }

      if (FlxG.keys.pressed.X)
      {
        delTimer += 1 * elapsed;

        if (delTimer == 3 && slotUsedArray[curSelected] == true)
        {
          resetSave(curSelected + 1);
          slots[curSelected].animation.frameIndex = 0;
          slotUsedArray[curSelected] = false;
          // proabbly stupid but whatever
          switch (curSelected)
          {
            case 0:
              ClientPrefs.rpgSave1Used = false;
            case 1:
              ClientPrefs.rpgSave2Used = false;
            case 2:
              ClientPrefs.rpgSave3Used = false;
          }
          FlxG.sound.play(Paths.sound('cancelMenu'));
          delTimer = 0;
        }
      }
      else
      {
        // reset deltimer for safety
        delTimer = 0;
      }

      if (controls.ACCEPT)
      {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('confirmMenu'));

        for (slotto in slots)
        {
          if (slotto.ID != curSelected)
          {
            FlxTween.tween(slotto, {alpha: 0}, 0.35, {ease: EaseUtil.stepped(4)});
          }
        }
        FlxTween.tween(indi, {alpha: 0, y: 720}, 0.5, {ease: FlxEase.circOut});

        if (slotUsedArray[curSelected] == false)
        {
          prepFreshSave(curSelected + 1);
        }
        else
        {
          RpgPrefs.initSave(curSelected + 1);
        }

        slotUsedArray[curSelected] = true;

        // proabbly stupid but whatever
        switch (curSelected)
        {
          case 0:
            ClientPrefs.rpgSave1Used = true;
          case 1:
            ClientPrefs.rpgSave2Used = true;
          case 2:
            ClientPrefs.rpgSave3Used = true;
        }

        slots[curSelected].animation.frameIndex = 1;

        FlxG.sound.music.stop();
        FlxG.sound.music = null;

        FlxTransitionableState.skipNextTransIn = false;
        FlxTransitionableState.skipNextTransOut = false;
        MusicBeatState.switchState(new MainMenuState());
      }
    }

    super.update(elapsed);
  }

  function changeItem(huh:Int = 0)
  {
    curSelected += huh;

    if (curSelected >= 3)
    {
      curSelected = 0;
    }

    if (curSelected < 0)
    {
      curSelected = 2;
    }
  }

  function prepFreshSave(num:Int)
  {
    RpgPrefs.initSave(num);
    RpgPrefs.prepFreshSave(num);
    RpgPrefs.flushCurSave();
  }

  function resetSave(num:Int)
  {
    RpgPrefs.initSave(num);
    RpgPrefs.eraseCurSave();
    RpgPrefs.prepFreshSave(num);
    RpgPrefs.flushCurSave();
  }
}