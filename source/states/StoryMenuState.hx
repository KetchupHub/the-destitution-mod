package states;

import backend.Song;
import backend.Highscore;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import visuals.PixelPerfectSprite;
import ui.RoadTripMarker;
import ui.RoadTripStop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import states.FreeplayState.SongMetadata;
import backend.ClientPrefs;
import util.CoolUtil;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.WeekData;
#if desktop
import backend.Discord.DiscordClient;
#end

class StoryMenuState extends MusicBeatState
{
  private var songs:Array<SongMetadata> = [];

  public var markersGrp:FlxTypedGroup<RoadTripMarker>;
  public var stopsGrp:FlxTypedGroup<RoadTripStop>;

  public var thaCar:PixelPerfectSprite;

  public var facingSong:Bool = false;

  public var exitingMenu:Bool = false;

  private var camFollowege:FlxPoint;
  private var camFollowObj:FlxObject;

  override function create()
  {
    #if DEVELOPERBUILD
    var perf = new Perf("Total StoryMenuState create()");
    #end

    persistentUpdate = true;
    persistentDraw = true;

    CoolUtil.newStateMemStuff();

    WeekData.reloadWeekFiles(true);

    #if desktop
    DiscordClient.changePresence("In the Story Menu", null, null, '-inst');
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

    markersGrp = new FlxTypedGroup<RoadTripMarker>();
    stopsGrp = new FlxTypedGroup<RoadTripStop>();

    for (i in 0...songs.length)
    {
      var myNewStop:RoadTripStop = new RoadTripStop(160 * (i + 2), 285, songs[i].songName.toLowerCase());
      myNewStop.ID = i;
      stopsGrp.add(myNewStop);

      var myNewMarker:RoadTripMarker = new RoadTripMarker((160 * (i + 2)) + 10, 140, songs[i].songName.toLowerCase());
      myNewMarker.ID = i;
      markersGrp.add(myNewMarker);
    }

    add(markersGrp);
    add(stopsGrp);

    thaCar = new PixelPerfectSprite(10, 285).loadGraphic(Paths.image('story/car'));
    thaCar.updateHitbox();
    thaCar.antialiasing = ClientPrefs.globalAntialiasing;
    add(thaCar);

    camFollowege = new FlxPoint();
    camFollowege = thaCar.getGraphicMidpoint();

    camFollowObj = new FlxObject(0, 0, 1, 1);
    camFollowObj.setPosition(camFollowege.x, camFollowege.y);

    FlxG.camera.follow(camFollowObj);

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

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music != null)
    {
      if (FlxG.sound.music.volume < 1)
      {
        FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
      }
    }

    if (controls.UI_LEFT && !exitingMenu)
    {
      thaCar.flipX = true;
      thaCar.x -= 100 * elapsed;
    }
    else if (controls.UI_RIGHT && !exitingMenu)
    {
      thaCar.flipX = false;
      thaCar.x += 100 * elapsed;
    }

    if ((controls.UI_LEFT || controls.UI_RIGHT) && !exitingMenu)
    {
      for (i in stopsGrp)
      {
        var dist = ((thaCar.x + thaCar.width) - i.x);

        if (thaCar.flipX)
        {
          dist = (i.x - (thaCar.x));
        }

        if (dist < 0)
        {
          dist *= -1;
        }

        if (dist <= 25)
        {
          i.hovered = true;
          markersGrp.members[i.ID].hovered = true;
        }
        else
        {
          i.hovered = false;
          markersGrp.members[i.ID].hovered = false;
        }
      }
    }

    if (thaCar.x < 0)
    {
      thaCar.x = 0;
    }

    camFollowege = thaCar.getGraphicMidpoint();
    camFollowObj.setPosition(camFollowege.x, camFollowege.y);

    if (controls.ACCEPT && !exitingMenu)
    {
      for (i in markersGrp)
      {
        if (i.acceptable)
        {
          exitingMenu = true;

          FlxG.sound.music.volume = 0;

          var songLowercase:String = Paths.formatToSongPath(i.songName);
          var poop:String = Highscore.formatSong(songLowercase);

          PlayState.SONG = Song.loadFromJson(poop);

          FlxTransitionableState.skipNextTransIn = true;
          FlxTransitionableState.skipNextTransOut = true;
          MusicBeatState.switchState(new LoadingScreenState());
        }
      }
    }

    if (controls.BACK && !exitingMenu)
    {
      exitingMenu = true;

      FlxTransitionableState.skipNextTransIn = false;
      FlxTransitionableState.skipNextTransOut = false;

      FlxG.sound.play(Paths.sound('cancelMenu'));

      MusicBeatState.switchState(new MainMenuState());
    }

    super.update(elapsed);
  }

  public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
  {
    songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
  }

  override function closeSubState()
  {
    persistentUpdate = true;
    super.closeSubState();
  }
}