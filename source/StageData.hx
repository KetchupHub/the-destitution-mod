package;

import openfl.utils.Assets;
import haxe.Json;
import Song;

typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var stageUI:String;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static function dummy():StageFile
	{
		return {
			directory: "",
			defaultZoom: 1,
			stageUI: "normal",

			boyfriend: [770, 100],
			girlfriend: [400, 130],
			opponent: [100, 100],
			hide_girlfriend: false,

			camera_boyfriend: [0, 0],
			camera_opponent: [0, 0],
			camera_girlfriend: [0, 0],
			camera_speed: 1
		};
	}

	public static var forceNextDirectory:String = null;
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null && SONG.stage != 'stage') {
			stage = SONG.stage;
		} else if(SONG.song != null) {
			switch (SONG.song.toLowerCase())
			{
				case 'destitution':
					stage = 'mark';
				case 'superseded':
					stage = 'superseded';
				case 'd-stitution':
					stage = 'dsides';
				case 'isosceles':
					stage = 'argulow';
				case 'three-of-them':
					stage = 'april';
				default:
					stage = 'stage';
			}
		} else {
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		if(stageFile == null) { //preventing crashes
			forceNextDirectory = '';
		} else {
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		if(Assets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		else
		{
			return null;
		}

		return cast tjson.TJSON.parse(rawJson);
	}

	public static function vanillaSongStage(songName):String
	{
		switch (songName)
		{
			case 'destitution':
				return 'mark';
			case 'superseded':
				return 'superseded';
			case 'd-stitution':
				return 'dsides';
			case 'isosceles':
				return 'argulow';
			case 'three-of-them':
				return 'april';
			default:
				return 'stage';
		}
		return 'stage';
	}
}