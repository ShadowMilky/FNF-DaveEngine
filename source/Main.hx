package;

import openfl.text.TextFormat;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.system.FlxSound;
import flixel.FlxG;
import lime.app.Application;
// import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import Discord.DiscordClient;
#if !html5
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var initialState:Class<FlxState> = StartStateSelector; // The FlxState the game starts with.

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.

	public static var framerate:Int = 144; // How many frames per second the game should run at.

	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fps:FpsDisplay;

	public static var applicationName:String = "Friday Night Funkin' | Vs. Foxa Expanded";

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static function toggleFuckedFPS(toggle:Bool)
	{
		fps.fuckFps = toggle;
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		initialState = StartStateSelector;
		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, skipSplash, startFullscreen));

		ClientPrefs.loadPrefs();
		
		framerate = ClientPrefs.framerate;

		#if !mobile
		fps = new FpsDisplay(10, 3, 0xFFFFFF);
		var fpsFormat = new TextFormat("_sans", 12, 0xFFFFFF, false);
		fps.defaultTextFormat = fpsFormat;
		addChild(fps);
		#end

		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	// #if CRASH_HANDLER
	/* function onCrash(e:UncaughtErrorEvent):Void
		{
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();

			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");

			path = "./crash/" + "VsFoxaPlus_" + dateNow + ".txt";

			trace('it crashed thanks a lot dummy');

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}

			errMsg += "\nUncaught Error: "
				+ e.error
				+ "\nPlease report this error to the GitHub page: https://github.com/VsFoxaTeam/FNF-VsFoxaPlus/issues\n\n> Crash Handler written by: sqirra-rng";

			if (!FileSystem.exists("./crash/"))
				FileSystem.createDirectory("./crash/");

			File.saveContent(path, errMsg + "\n");

			Sys.println(errMsg);
			Sys.println("Crash dump saved in " + Path.normalize(path));

			Application.current.window.alert(errMsg, "Error!");
			// DiscordClient.shutdown();
			Sys.exit(1);
		}
	 */
	// #end
}
