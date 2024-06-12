package;

import openfl.system.System;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import WeekData;

using StringTools;

class PlayMenuState extends MusicBeatState
{
	var songs:Array<FreeplayState.SongMetadata> = [];

	private static var curSelected:Int = 0;

	var curDifficulty:Int = 0;

	private static var lastDifficultyName:String = '';

	var bg:FlxSprite;

	var albumArt:FlxSprite;
	var songText:FlxSprite;

	override function create()
	{
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Play Menu", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

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
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		bg = new FlxSprite().loadGraphic(Paths.image('playbg'));
		add(bg);
		bg.screenCenter();

		albumArt = new FlxSprite(35, 35).loadGraphic(Paths.image("albumCovers/destitution"));
		albumArt.setGraphicSize(185);
		albumArt.updateHitbox();
		albumArt.antialiasing = false;
		add(albumArt);

		songText = new FlxSprite(650, 45).loadGraphic(Paths.image("songTitles/destitution"));
		songText.setGraphicSize(625);
		songText.updateHitbox();
		songText.antialiasing = false;
		add(songText);

		WeekData.setDirectoryFromWeek();

		if(curSelected >= songs.length) curSelected = 0;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
        System.gc();

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_LEFT_P;
		var downP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-1);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(1);
				holdTime = 0;
			}

			if(controls.UI_RIGHT || controls.UI_DOWN)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -1 : 1));
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-1 * FlxG.mouse.wheel, false);
			}
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		remove(albumArt);
		remove(songText);

		albumArt = new FlxSprite(35, 35).loadGraphic(Paths.image("albumCovers/" + songs[curSelected].songName.toLowerCase()));
		albumArt.setGraphicSize(185);
		albumArt.updateHitbox();
		albumArt.antialiasing = false;
		add(albumArt);

		songText = new FlxSprite(650, 45).loadGraphic(Paths.image("songTitles/" + songs[curSelected].songName.toLowerCase()));
		songText.setGraphicSize(625);
		songText.updateHitbox();
		songText.antialiasing = false;
		add(songText);
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = 0;
		}

	}
}