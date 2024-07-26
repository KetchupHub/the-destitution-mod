package backend;

import openfl.utils.Assets;
import haxe.Json;
import backend.Song;

typedef StageFile = {
	var defaultZoom:Float;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;

	var artist:String;
}

class StageData
{
	public static function loadDirectory(SONG:SwagSong)
	{
		var stage:String = '';

		if(SONG.stage != null)
		{
			stage = SONG.stage;
		}
		else
		{
			stage = 'mark';
		}

		var stageFile:StageFile = getStageFile(stage);
	}

	public static function getStageFile(stage:String):StageFile
	{
		var rawJson:String = null;

		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		if(Assets.exists(path))
		{
			rawJson = Assets.getText(path);
		}
		else
		{
			return null;
		}

		return cast Json.parse(rawJson);
	}
}