package backend;

import Sys.sleep;
import discord_rpc.DiscordRpc;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

using StringTools;

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

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		var alrgey:String = "icon";
		var smalley:String = "";

		if(smallImageKey != null)
		{
			alrgey = smallImageKey;
			smalley = "icon";
		}

		DiscordRpc.presence(
		{
			details: details,
			state: state,
			largeImageKey: alrgey,
			largeImageText: "The Destitution Mod",
			smallImageKey : smalley,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
	}
}