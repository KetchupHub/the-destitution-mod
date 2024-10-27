package states;

import visuals.PixelPerfectSprite;
import ui.MarkHeadTransition;
import flixel.addons.transition.FlxTransitionableState;
import backend.TextAndLanguage;
import backend.Highscore;
import backend.ClientPrefs;
import lime.app.Application;
import backend.PlayerSettings;
import util.CoolUtil;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

class InitState extends MusicBeatState
{
  public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO, FlxKey.NUMPADZERO];
  public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
  public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

  override public function create():Void
  {
    #if DEVELOPERBUILD
    var perf = new Perf("Total InitState create()");
    #end

    persistentUpdate = true;
    persistentDraw = true;

    FlxG.sound.muteKeys = muteKeys;
    FlxG.sound.volumeDownKeys = volumeDownKeys;
    FlxG.sound.volumeUpKeys = volumeUpKeys;

    FlxG.keys.preventDefaultKeys = [TAB];

    PlayerSettings.init();

    Application.current.window.title = CoolUtil.appTitleString;

    FlxG.mouse.visible = false;

    FlxG.mouse.load(Paths.image('cursor').bitmap, 2);

    FlxG.save.bind('destitution', CoolUtil.getSavePath());

    ClientPrefs.loadPrefs();

    Highscore.load();

    TextAndLanguage.setLang(ClientPrefs.language);

    if (FlxG.save.data != null && FlxG.save.data.fullscreen)
    {
      FlxG.fullscreen = FlxG.save.data.fullscreen;
    }

    CoolUtil.hasInitializedWindow = true;

    var initGraphic:PixelPerfectSprite = new PixelPerfectSprite().loadGraphic(Paths.image('init'));
    initGraphic.scale.set(2, 2);
    initGraphic.updateHitbox();
    initGraphic.screenCenter();
    add(initGraphic);

    super.create();

    FlxTransitionableState.skipNextTransIn = false;
    FlxTransitionableState.skipNextTransOut = false;

    MarkHeadTransition.nextCamera = FlxG.camera;

    if (FlxG.save.data.flashing == null && !FlashingState.leftState)
    {
      MusicBeatState.switchState(new FlashingState());
    }
    else
    {
      gotoTitle();
    }

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  public function gotoTitle()
  {
    var waitTime = new FlxTimer().start(1.5, function goDoIt(flux:FlxTimer)
    {
      MusicBeatState.switchState(new TitleState());
    });
  }
}