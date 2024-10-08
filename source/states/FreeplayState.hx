package states;

import openfl.utils.Assets;
import haxe.Json;
import ui.TransitionScreenshotObject;
import util.EaseUtil;
import visuals.PixelPerfectSprite;
import ui.MarkHeadTransition;
import flixel.util.FlxStringUtil;
import backend.Conductor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import songs.SongInit;
import backend.Highscore;
import backend.ClientPrefs;
import ui.Alphabet;
import util.CoolUtil;
#if DEVELOPERBUILD
import editors.ChartingState;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import backend.WeekData;
#if desktop
import backend.Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
  public var songs:Array<SongMetadata> = [];

  public var enteringMenu:Bool = false;

  public var songCover:PixelPerfectSprite;

  public var selector:FlxText;

  public static var curSelected:Int = 0;

  public var scoreText:FlxText;
  public var descText:FlxText;
  public var lerpScore:Int = 0;
  public var lerpRating:Float = 0;
  public var intendedScore:Int = 0;
  public var intendedRating:Float = 0;

  public var grpSongs:FlxTypedGroup<Alphabet>;
  public var curPlaying:Bool = false;

  public var bg:PixelPerfectSprite;
  public var intendedColor:Int;
  public var colorTween:FlxTween;

  public var songVariantCur:String = 'Normal';

  public var freePaper:PixelPerfectSprite;
  public var freeMetal:PixelPerfectSprite;

  public var playerChar:String = '';

  public override function new(?player:String = '')
  {
    super();
    playerChar = player;
  }

  override function create()
  {
    #if DEVELOPERBUILD
    var perf = new Perf("Total FreeplayState create()");
    #end

    persistentUpdate = true;
    persistentDraw = true;

    CoolUtil.newStateMemStuff();

    WeekData.reloadWeekFiles(false, playerChar);

    var playerCharNoDash:String = playerChar.replace('-', '').toLowerCase();

    var toJsn:String = 'default';

    if (playerCharNoDash != '')
    {
      toJsn = playerCharNoDash;
    }

    var json:Dynamic = Json.parse(Assets.getText('assets/freeplay/$toJsn.json'));

    var useSkin:String = json.skin;

    #if desktop
    DiscordClient.changePresence("In the Freeplay Menu", null, null, '-inst');
    #end

    for (i in 0...WeekData.weeksList.length)
    {
      var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
      var leSongs:Array<String> = [];
      var leChars:Array<String> = [];

      for (j in 0...leWeek.songs.length)
      {
        leSongs.push(leWeek.songs[j][0]);
        leChars.push(leWeek.songs[j][1]);
      }

      WeekData.setDirectoryFromWeek(leWeek);

      for (song in leWeek.songs)
      {
        var colors:Array<Int> = song[2];

        if (colors == null || colors.length < 3)
        {
          colors = [146, 113, 253];
        }

        addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
      }
    }

    enteringMenu = true;

    bg = new PixelPerfectSprite().loadGraphic(Paths.image('freeplay/$useSkin/bg'));
    bg.alpha = 0.5;
    add(bg);
    bg.screenCenter();

    var transThing = new TransitionScreenshotObject();
    add(transThing);
    transThing.fadeout();

    freePaper = new PixelPerfectSprite().loadGraphic(Paths.image('freeplay/$useSkin/paper'));
    freePaper.scale.set(2, 2);
    freePaper.updateHitbox();
    freePaper.antialiasing = false;
    freePaper.x -= 1280;
    add(freePaper);

    FlxTween.tween(freePaper, {x: 0}, 0.5, {ease: FlxEase.circOut});

    freeMetal = new PixelPerfectSprite(804, 0).loadGraphic(Paths.image('freeplay/$useSkin/metal'));
    freeMetal.scale.set(2, 2);
    freeMetal.updateHitbox();
    freeMetal.antialiasing = false;
    freeMetal.x += 1280;
    add(freeMetal);

    FlxTween.tween(freeMetal, {x: 804}, 0.5, {ease: FlxEase.circOut});

    songCover = new PixelPerfectSprite(936, 0).loadGraphic(Paths.image('song_covers/placeholder', null, true));
    songCover.x = 936;
    songCover.y = 204;
    songCover.antialiasing = false;
    songCover.alpha = 0;
    add(songCover);

    FlxTween.tween(songCover, {alpha: 1}, 0.35, {ease: EaseUtil.stepped(4)});

    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);

    for (i in 0...songs.length)
    {
      var songText:Alphabet = new Alphabet(35, 150, SongInit.genSongObj(songs[i].songName.toLowerCase()).songNameForDisplay, true);
      songText.changeX = false;
      songText.isMenuItem = true;
      songText.targetY = i - curSelected;
      grpSongs.add(songText);

      var maxWidth = 680;
      if (songText.width > maxWidth)
      {
        songText.scaleX = maxWidth / (songText.width + 38);
      }
      songText.snapToPosition();

      Paths.currentModDirectory = songs[i].folder;
    }
    WeekData.setDirectoryFromWeek();

    scoreText = new FlxText(872, 5, 403, 'Best Score: 0 (0%)', 38);
    scoreText.setFormat(Paths.font("BAUHS93.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    scoreText.borderSize = 1.5;
    scoreText.alpha = 0;
    scoreText.antialiasing = ClientPrefs.globalAntialiasing;
    add(scoreText);

    FlxTween.tween(scoreText, {alpha: 1}, 0.35, {ease: EaseUtil.stepped(4)});

    descText = new FlxText(872, songCover.y + songCover.height + 21, 403, "Placeholder", 30);
    descText.setFormat(Paths.font("BAUHS93.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    descText.borderSize = 1.5;
    descText.alpha = 0;
    descText.antialiasing = ClientPrefs.globalAntialiasing;
    add(descText);

    changeSelection(0, false);

    FlxTween.tween(descText, {alpha: 1}, 0.35,
      {
        ease: EaseUtil.stepped(4),
        onComplete: function guhlt(frueck:FlxTween)
        {
          enteringMenu = false;
          changeSelection(0, true);
        }
      });

    if (curSelected >= songs.length) curSelected = 0;
    bg.color = songs[curSelected].color;
    var realboy = FlxColor.fromInt(bg.color);
    realboy.alphaFloat = 0.5;
    intendedColor = realboy;

    for (i in grpSongs.members)
    {
      i.alpha = 0;
      FlxTween.tween(i, {alpha: 0.6}, 0.25, {ease: EaseUtil.stepped(4)});
    }

    var swag:Alphabet = new Alphabet(1, 0, "swag");

    var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
    textBG.alpha = 0.6;
    add(textBG);

    #if PRELOAD_ALL
    var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
    var size:Int = 16;
    #else
    var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
    var size:Int = 18;
    #end
    var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
    text.setFormat(Paths.font("BAUHS93.ttf"), size, FlxColor.WHITE, RIGHT);
    text.scrollFactor.set();
    text.antialiasing = ClientPrefs.globalAntialiasing;
    add(text);

    #if DEVELOPERBUILD
    var versionShit:FlxText = new FlxText(4, FlxG.height - 24, FlxG.width,
      "(DEV BUILD!!! - " + CoolUtil.gitCommitBranch + " - " + CoolUtil.gitCommitHash + ")", 12);
    versionShit.scrollFactor.set();
    versionShit.setFormat(Paths.font("BAUHS93.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    versionShit.antialiasing = ClientPrefs.globalAntialiasing;
    add(versionShit);
    #end

    super.create();

    #if DEVELOPERBUILD
    perf.print();
    #end
  }

  var instPlaying:Int = -1;
  var holdTime:Float = 0;

  var exitingMenu:Bool = false;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music.volume < 0.7)
    {
      FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
    }

    if (!exitingMenu && !enteringMenu)
    {
      lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
      lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

      if (Math.abs(lerpScore - intendedScore) <= 10)
      {
        lerpScore = intendedScore;
      }

      if (Math.abs(lerpRating - intendedRating) <= 0.01)
      {
        lerpRating = intendedRating;
      }

      var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');

      if (ratingSplit.length < 2)
      { // No decimals, add an empty space
        ratingSplit.push('');
      }

      while (ratingSplit[1].length < 2)
      { // Less than 2 decimals in it, add decimals then
        ratingSplit[1] += '0';
      }

      var upP = controls.UI_UP_P;
      var downP = controls.UI_DOWN_P;
      var accepted = controls.ACCEPT;
      var space = FlxG.keys.justPressed.SPACE;
      var ctrl = FlxG.keys.justPressed.CONTROL;
      var tab = FlxG.keys.justPressed.TAB;

      var shiftMult:Int = 1;

      if (FlxG.keys.pressed.SHIFT)
      {
        shiftMult = 3;
      }

      if (songs.length > 1)
      {
        if (upP)
        {
          changeSelection(-shiftMult);
          holdTime = 0;
        }

        if (downP)
        {
          changeSelection(shiftMult);
          holdTime = 0;
        }

        if (tab && SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songVariants != ["Normal"])
        {
          var stupidThing:Int = SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songVariants.indexOf(songVariantCur);

          if (stupidThing + 1 > SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songVariants.length - 1)
          {
            stupidThing = 0;
          }
          else
          {
            stupidThing++;
          }

          songVariantCur = SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songVariants[stupidThing];
        }

        if (controls.UI_DOWN || controls.UI_UP)
        {
          var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
          holdTime += elapsed;
          var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

          if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
          {
            changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
          }
        }

        if (FlxG.mouse.wheel != 0)
        {
          FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
          changeSelection(-shiftMult * FlxG.mouse.wheel, false);
        }
      }

      var myFuck:String = '\nSong Variant: ' + songVariantCur + '\nTab to Switch!';

      if (SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songVariants.length <= 1)
      {
        myFuck = '';
      }

      scoreText.text = 'Best Score: ' + FlxStringUtil.formatMoney(lerpScore, false, true) + ' (' + ratingSplit.join('.') + '%)' + myFuck;
      positionHighscore();

      if (controls.BACK)
      {
        persistentUpdate = false;

        exitingMenu = true;

        if (colorTween != null)
        {
          colorTween.cancel();
        }

        FlxG.sound.play(Paths.sound('cancelMenu'));

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        for (i in grpSongs.members)
        {
          FlxTween.tween(i, {alpha: 0}, 0.35, {ease: EaseUtil.stepped(4)});
        }

        FlxTween.tween(freePaper, {x: -1280}, 0.25, {ease: FlxEase.circIn});
        FlxTween.tween(freeMetal, {x: 804 + 1280}, 0.25, {ease: FlxEase.circIn});

        FlxTween.tween(songCover, {alpha: 0}, 0.5, {ease: EaseUtil.stepped(4)});

        FlxTween.tween(scoreText, {alpha: 0}, 0.5, {ease: EaseUtil.stepped(4)});
        FlxTween.tween(descText, {alpha: 0}, 0.5,
          {
            ease: EaseUtil.stepped(4),
            onComplete: function dulter(flucks:FlxTween)
            {
              var fuckyou:FlxTimer = new FlxTimer().start(0.1, function dieIrl(fuckingShitAssDickPiss:FlxTimer)
              {
                MusicBeatState.switchState(new MainMenuState());
              });
            }
          });
      }

      if (ctrl)
      {
        persistentUpdate = false;
        openSubState(new GameplayChangersSubstate());
      }
      else if (space)
      {
        if (instPlaying != curSelected)
        {
          #if PRELOAD_ALL
          var suffy:String = '';

          switch (songVariantCur)
          {
            case 'Erect':
              {
                suffy = '-erect';
              }
          }

          FlxG.sound.music.volume = 0;
          Paths.currentModDirectory = songs[curSelected].folder;
          var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase() + suffy);
          PlayState.SONG = Song.loadFromJson(poop);
          FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
          Conductor.changeBPM(PlayState.SONG.bpm);
          instPlaying = curSelected;
          #end
        }
      }
      else if (accepted)
      {
        persistentUpdate = false;
        var suffy:String = '';

        switch (songVariantCur)
        {
          case 'Erect':
            {
              suffy = '-erect';
            }
        }

        var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName + suffy);
        var poop:String = Highscore.formatSong(songLowercase);

        PlayState.SONG = Song.loadFromJson(poop);

        if (colorTween != null)
        {
          colorTween.cancel();
        }

        #if DEVELOPERBUILD
        if (FlxG.keys.pressed.SHIFT)
        {
          FlxTransitionableState.skipNextTransIn = false;
          FlxTransitionableState.skipNextTransOut = false;
          MarkHeadTransition.nextCamera = FlxG.camera;
          MusicBeatState.switchState(new ChartingState());
        }
        else
        {
        #end
          FlxTransitionableState.skipNextTransIn = true;
          FlxTransitionableState.skipNextTransOut = true;
          MusicBeatState.switchState(new LoadingScreenState());
        #if DEVELOPERBUILD
        }
        #end

        FlxG.sound.music.volume = 0;
      }
      else if (controls.RESET)
      {
        persistentUpdate = false;
        openSubState(new ResetScoreSubState(songs[curSelected].songName, songs[curSelected].songCharacter));
        FlxG.sound.play(Paths.sound('scrollMenu'));
      }
    }

    super.update(elapsed);
  }

  function changeSelection(change:Int = 0, playSound:Bool = true)
  {
    if (playSound)
    {
      FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    }

    songVariantCur = 'Normal';

    curSelected += change;

    if (curSelected < 0)
    {
      curSelected = songs.length - 1;
    }
    if (curSelected >= songs.length)
    {
      curSelected = 0;
    }

    var newColor:Int = songs[curSelected].color;

    if (newColor != intendedColor)
    {
      if (colorTween != null)
      {
        colorTween.cancel();
      }

      var realboy = FlxColor.fromInt(newColor);
      realboy.alphaFloat = 0.5;
      intendedColor = realboy;

      colorTween = FlxTween.color(bg, 1, bg.color, intendedColor,
        {
          ease: EaseUtil.stepped(8),
          onComplete: function(twn:FlxTween) {
            colorTween = null;
          }
        });
    }

    intendedScore = Highscore.getScore(songs[curSelected].songName);
    intendedRating = Highscore.getRating(songs[curSelected].songName);

    var bullShit:Int = 0;

    for (item in grpSongs.members)
    {
      item.targetY = bullShit - curSelected;
      bullShit++;

      item.alpha = 0.6;

      if (item.targetY == 0)
      {
        item.alpha = 1;
      }
    }

    if (songs[curSelected].songName.toLowerCase() == 'eggshells')
    {
      if (Paths.image('song_covers/' + songs[curSelected].songName.toLowerCase() + ClientPrefs.lastEggshellsEnding, null, true) != null)
      {
        songCover.loadGraphic(Paths.image('song_covers/' + songs[curSelected].songName.toLowerCase() + ClientPrefs.lastEggshellsEnding));
      }
      else
      {
        songCover.loadGraphic(Paths.image('song_covers/placeholder'));
      }
    }
    else if (Paths.image('song_covers/' + songs[curSelected].songName.toLowerCase(), null, true) != null)
    {
      songCover.loadGraphic(Paths.image('song_covers/' + songs[curSelected].songName.toLowerCase()));
    }
    else
    {
      songCover.loadGraphic(Paths.image('song_covers/placeholder'));
    }

    songCover.x = 936;
    songCover.y = 204;

    descText.text = SongInit.genSongObj(songs[curSelected].songName.toLowerCase()).songDescription;

    Paths.currentModDirectory = songs[curSelected].folder;
  }

  public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
  {
    songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
  }

  override function closeSubState()
  {
    changeSelection(0, false);
    persistentUpdate = true;
    super.closeSubState();
  }

  public function positionHighscore()
  {
    scoreText.x = FlxG.width - scoreText.width - 6;
  }
}

class SongMetadata
{
  public var songName:String = "";
  public var week:Int = 0;
  public var songCharacter:String = "";
  public var color:Int = -7179779;
  public var folder:String = "";

  public function new(song:String, week:Int, songCharacter:String, color:Int)
  {
    this.songName = song;
    this.week = week;
    this.songCharacter = songCharacter;
    this.color = color;
    this.folder = Paths.currentModDirectory;

    if (this.folder == null)
    {
      this.folder = '';
    }
  }
}

typedef FreeplayGfxData =
{
  var skin:String;
}