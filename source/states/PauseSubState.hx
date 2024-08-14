package states;

import util.CoolUtil;
import backend.WeekData;
import backend.ClientPrefs;
import backend.Conductor;
import ui.Alphabet;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Toggle Practice Mode', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;

	public static var songName:String = '';

	var songCover:FlxSprite;
	var descText:FlxText;

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	public function new(x:Float, y:Float)
	{
		#if DEVELOPERBUILD
		var perf = new Perf("Total PauseSubState new()");
		#end

		super();

		songName = PlayState.instance.songObj.songNameForDisplay;

		CoolUtil.rerollRandomness();

		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(3, 'Leave Charting Mode');
			menuItemsOG.insert(4, 'End Song');
			menuItemsOG.insert(5, 'Toggle Botplay');
		}

		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music("mus_lunch_break"), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false);

		FlxG.sound.list.add(pauseMusic);

		FlxTween.globalManager.forEach(function killsSelf(i:FlxTween)
		{
			i.active = false;
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.instance.songObj.songNameForDisplay;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("BAUHS93.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		blueballedTxt.text = "Died: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font("BAUHS93.ttf"), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		var sectionTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		sectionTxt.text = "Section " + PlayState.sectionNum;
		sectionTxt.scrollFactor.set();
		sectionTxt.setFormat(Paths.font("BAUHS93.ttf"), 32);
		sectionTxt.updateHitbox();

		if (PlayState.songHasSections)
		{
			add(sectionTxt);
		}

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font("BAUHS93.ttf"), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 165, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font("BAUHS93.ttf"), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		songCover = new FlxSprite(936, 0).loadGraphic(Paths.image('song_covers/' + PlayState.SONG.song.toLowerCase().replace('-erect', '')));
		songCover.screenCenter();
		songCover.x = FlxG.width - (256 + 15);
		songCover.y -= 76;
		songCover.antialiasing = false;
		add(songCover);

		descText = new FlxText(872, songCover.y + songCover.height + 21, 400, PlayState.instance.songObj.songDescription, 30);
		descText.setFormat(Paths.font("BAUHS93.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		descText.borderSize = 1.5;
		descText.x = FlxG.width - 415;
		descText.y = songCover.y + songCover.height + 21;
		add(descText);

		blueballedTxt.alpha = 0;
		levelInfo.alpha = 0;
		sectionTxt.alpha = 0;
		practiceText.alpha = 0;
		chartingText.alpha = 0;
		songCover.alpha = 0;
		descText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		sectionTxt.x = FlxG.width - (sectionTxt.width + 20);
		
		songCover.y -= 5;
		descText.y -= 5;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(sectionTxt, {alpha: 1, y: sectionTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(chartingText, {alpha: 1, y: chartingText.y + 5}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(songCover, {alpha: 1, y: songCover.y + 5}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(descText, {alpha: 1, y: descText.y + 5}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if DEVELOPERBUILD
		perf.print();
		#end
	}

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		if (pauseMusic.volume < 0.5)
		{
			pauseMusic.volume += 0.01 * elapsed;
		}

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}

		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			switch (daSelected)
			{
				case "Resume":
					Application.current.window.title = CoolUtil.appTitleString + " - Playing " + PlayState.instance.songObj.songNameForDisplay;

					FlxTween.globalManager.forEach(function killsSelf(i:FlxTween)
					{
						i.active = true;
					});

					close();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;

					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					Application.current.window.title = CoolUtil.appTitleString + " - Playing " + PlayState.instance.songObj.songNameForDisplay;

					restartSong();
				case "Leave Charting Mode":
					restartSong();

					PlayState.chartingMode = false;
				case "End Song":
					Application.current.window.title = CoolUtil.appTitleString;

					close();

					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;

					#if !SHOWCASEVIDEO
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					#end
				case "Exit to menu":
					Application.current.window.title = CoolUtil.appTitleString;

					PlayState.deathCounter = 0;

					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					MusicBeatState.switchState(new MainMenuState());

					PlayState.cancelMusicFadeTween();

					FlxG.sound.playMusic(Paths.music('mus_pauperized'));
					Conductor.songPosition = 0;
					Conductor.changeBPM(150);

					PlayState.chartingMode = false;
			}
		}
	}

	public static function restartSong()
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		MusicBeatState.switchState(new PlayState());
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
		{
			curSelected = menuItems.length - 1;
		}

		if (curSelected >= menuItems.length)
		{
			curSelected = 0;
		}

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}

		curSelected = 0;
		changeSelection();
	}
}