package backend;

import sys.thread.Thread;
import cpp.RawConstPointer;
import cpp.ConstCharStar;
import cpp.Callable;
import lime.app.Application;
import util.CoolUtil;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

/**
 * Handles all Discord API and Rich Presence related functions.
 */
class DiscordClient
{
  public static var isInitialized:Bool = false;

  public static var discordHandlers:DiscordEventHandlers;

  public function new()
  {
    #if DEVELOPERBUILD
    trace("Initializing Discord RPC...");
    #end

    discordHandlers = DiscordEventHandlers.create();
    discordHandlers.ready = Callable.fromStaticFunction(onReady);
    discordHandlers.errored = Callable.fromStaticFunction(onError);
    discordHandlers.disconnected = Callable.fromStaticFunction(onDisconnected);

    Discord.initialize("1104955579979542548", discordHandlers);

    // not effected by multi threading option because otherwise the game would hang, lol!
    Thread.create(function():Void {
      while (true)
      {
        #if DISCORD_DISABLE_IO_THREAD
        Discord.UpdateConnection();
        #end

        Discord.runCallbacks();

        Sys.sleep(2);
      }
    });
  }

  public static function shutdown()
  {
    Discord.shutdown();
  }

  static function onReady(that:RawConstPointer<DiscordUser>)
  {
    var pres:DiscordRichPresence;

    pres = DiscordRichPresence.create();

    pres.details = ConstCharStar.fromString("In the Menus");
    pres.state = null;

    pres.largeImageKey = ConstCharStar.fromString("icon");
    pres.largeImageText = ConstCharStar.fromString("The Destitution Mod v" + Application.current.meta.get('version'));

    final button1:DiscordButton = DiscordButton.create();
    button1.label = "Download";
    button1.url = ConstCharStar.fromString('https://gamejolt.com/games/destitution/844229');
    pres.buttons[0] = button1;

    final button2:DiscordButton = DiscordButton.create();
    button2.label = "Team";
    button2.url = ConstCharStar.fromString('https://twitter.com/TeamProdPresent/');
    pres.buttons[1] = button2;

    Discord.updatePresence(pres);
  }

  static function onError(_code:Int, _message:ConstCharStar) {}

  static function onDisconnected(_code:Int, _message:ConstCharStar) {}

  public static function initialize()
  {
    var DiscordDaemon = Thread.create(() -> {
      new DiscordClient();
    });

    isInitialized = true;
  }

  public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, iconSuffix:String = '', ?hasStartTimestamp:Bool,
      ?endTimestamp:Float)
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
    var largoText:String = 'The Destitution Mod v' + Application.current.meta.get('version');

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

    var pres:DiscordRichPresence;

    pres = DiscordRichPresence.create();

    pres.type = DiscordActivityType_Playing;

    pres.details = ConstCharStar.fromString(detailso);
    pres.state = ConstCharStar.fromString(stateo);

    pres.largeImageKey = ConstCharStar.fromString(alrgey);
    pres.largeImageText = ConstCharStar.fromString(largoText);
    pres.smallImageKey = ConstCharStar.fromString(smalley);

    final button1:DiscordButton = DiscordButton.create();
    button1.label = "Download";
    button1.url = ConstCharStar.fromString('https://gamejolt.com/games/destitution/844229');
    pres.buttons[0] = button1;

    final button2:DiscordButton = DiscordButton.create();
    button2.label = "Team";
    button2.url = ConstCharStar.fromString('https://twitter.com/TeamProdPresent/');
    pres.buttons[1] = button2;

    Discord.updatePresence(pres);
  }
}