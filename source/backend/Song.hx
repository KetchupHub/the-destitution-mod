package backend;

import backend.Section.SwagSection;
import haxe.Json;

#if sys
import sys.io.File;
#end

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;

	var composer:String;
	var charter:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var speed:Float = 2.5;
	
	public var player1:String = 'bf-mark';
	public var player2:String = 'mark';
	public var gfVersion:String = 'gf';
	public var stage:String;

	public var arrowSkin:String;
	public var splashSkin:String;

	public var composer:String = 'Unknown';
	public var charter:String = 'Unknown';

	private static function onLoadJson(songJson:Dynamic)
	{
		if (songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if (songJson.composer == null)
		{
			songJson.composer = "Unknown";
		}

		if (songJson.charter == null)
		{
			songJson.charter = "Unknown";
		}

		if (songJson.events == null)
		{
			songJson.events = [];

			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;

				while (i < len)
				{
					var note:Array<Dynamic> = notes[i];

					if (note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else
					{
						i++;
					}
				}
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.player1 = 'bf-mark';
		this.player2 = 'mark';
		this.gfVersion = 'gf';
		this.composer = 'Unknown';
		this.charter = 'Unknown';
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);

		if (rawJson == null)
		{
			#if sys
			rawJson = File.getContent(Paths.json('charts/' + formattedSong)).trim();
			#else
			rawJson = Assets.getText(Paths.json('charts/' + formattedSong)).trim();
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:Dynamic = parseJSONshit(rawJson);

		if (jsonInput != 'events')
		{
			StageData.loadDirectory(songJson);
		}

		onLoadJson(songJson);

		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;

		return swagShit;
	}
}