package backend;

import states.MainMenuState;
import util.CoolUtil;
import Sys.sleep;
import discord_rpc.DiscordRpc;

/**
 * Handles all Discord API and Rich Presence related functions.
 */
class DiscordClient
{
	public static var isInitialized:Bool = false;

	public function new()
	{
		DiscordRpc.start({
			clientID: "1104955579979542548",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}
	
	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}
	
	static function onReady()
	{
		DiscordRpc.presence(
		{
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "The Destitution Mod"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});

		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, iconSuffix:String = '', ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		var alrgey:String = "icon" + iconSuffix;
		var smalley:String = "";
		var stateo:String = state;
		var detailso:String = details;
		var largoText:String = 'The Destitution Mod ' + MainMenuState.psychEngineVersion;

		#if DEVELOPERBUILD
		stateo = 'State Redacted';
		detailso = 'Details Redacted';
		largoText = 'The Destitution Mod (DevBuild ' + CoolUtil.gitCommitBranch + ' : ' + CoolUtil.gitCommitHash + ')';
		#end

		if (smallImageKey != null)
		{
			#if DEVELOPERBUILD
			smalley = 'icon';
			#else
			smalley = smallImageKey;
			#end
		}

		DiscordRpc.presence(
		{
			details: detailso,
			state: stateo,
			largeImageKey: alrgey,
			largeImageText: largoText,
			smallImageKey : smalley,
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
	}
}