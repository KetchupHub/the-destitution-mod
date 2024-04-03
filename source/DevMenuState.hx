package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.*;

using StringTools;

class DevMenuState extends MusicBeatState
{
    var songAccessBox:FlxUIInputText;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

        songAccessBox = new FlxUIInputText(0, 0, 500, 'Destitution', 32, FlxColor.BLACK, FlxColor.WHITE);
        songAccessBox.name = 'type in song name';
        songAccessBox.screenCenter();
        add(songAccessBox);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

        if(controls.ACCEPT)
        {
            persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songAccessBox.text);
			var poop:String = Highscore.formatSong(songLowercase, 0);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			
			LoadingState.loadAndSwitchState(new LoadScreenPreloadGah());

			FlxG.sound.music.volume = 0;
        }

        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}