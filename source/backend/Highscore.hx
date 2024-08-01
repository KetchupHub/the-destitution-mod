package backend;

import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();

	public static function resetSong(song:String):Void
	{
		var daSong:String = formatSong(song);

		setScore(daSong, 0);
		setRating(daSong, 0);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;

		for (i in 0...decimals)
		{
			tempMult *= 10;
		}

		var newValue:Float = Math.floor(value * tempMult);

		return newValue / tempMult;
	}

	public static function saveScore(song:String, score:Int = 0, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);

				if (rating >= 0)
				{
					setRating(daSong, rating);
				}
			}
		}
		else
		{
			setScore(daSong, score);

			if (rating >= 0)
			{
				setRating(daSong, rating);
			}
		}
	}

	static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);

		FlxG.save.data.songScores = songScores;

		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		songRating.set(song, rating);

		FlxG.save.data.songRating = songRating;

		FlxG.save.flush();
	}

	public static function formatSong(song:String):String
	{
		return Paths.formatToSongPath(song);
	}

	public static function getScore(song:String):Int
	{
		var daSong:String = formatSong(song);

		if (!songScores.exists(daSong))
		{
			setScore(daSong, 0);
		}

		return songScores.get(daSong);
	}

	public static function getRating(song:String):Float
	{
		var daSong:String = formatSong(song);

		if (!songRating.exists(daSong))
		{
			setRating(daSong, 0);
		}

		return songRating.get(daSong);
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}

		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
	}
}