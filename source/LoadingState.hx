package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import haxe.io.Path;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;

	public static var globeTrans:Bool = true;

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;

		screenThing();
	}

	var loadBar:FlxSprite;
	var callbackTxt:FlxText;
	var loadingTxt:FlxSprite;
	var loadingCirc:FlxSprite;
	var loadingCircSpeed = FlxG.random.int(50, 200);
	var tipTxt:FlxText;
	var tips:Array<String> = [
		"This mod was made with Dave Engine, because Whitty exists in both Kade Engine and Psych Engine.",
		"GF doesn't work properly, I'm not sure if I can fix it right now.",
		"Foxa is not a furry.",
		"I'm inside your walls.",
		"Screw you!",
		"It's AumSum Time!!!!!",
		"It's AumSum Time!!!!!",
	];

	override function create()
	{
		/*var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
			add(bg); */

		screenThing();

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLoadSong(getSongPath());
			if (PlayState.SONG.needsVoices)
				checkLoadSong(getVocalPath());
			checkLibrary("shared");
			if (PlayState.storyWeek > 0)
				checkLibrary("week" + PlayState.storyWeek);
			else
				checkLibrary("tutorial");

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
	}

	public function screenThing()
	{
		var loading:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loadingscreen'));
		add(loading);

		flixel.addons.transition.FlxTransitionableState.skipNextTransIn = false;
		flixel.addons.transition.FlxTransitionableState.skipNextTransOut = false;
		if (!globeTrans)
		{
			flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
		}
		globeTrans = true;

		loadingTxt = new FlxSprite(100, 0).loadGraphic(Paths.image('loading'));
		loadingTxt.antialiasing = true;
		loadingTxt.scale.set(0.45, 0.45);
		loadingTxt.updateHitbox();
		loadingTxt.screenCenter(Y);
		add(loadingTxt);

		flixel.tweens.FlxTween.angle(loadingTxt, -5, 5, 1, {ease: flixel.tweens.FlxEase.quadInOut, type: flixel.tweens.FlxTween.FlxTweenType.PINGPONG});
		flixel.tweens.FlxTween.tween(loadingTxt, {"scale.x": 0.47, "scale.y": 0.47}, 0.5,
			{ease: flixel.tweens.FlxEase.quadInOut, type: flixel.tweens.FlxTween.FlxTweenType.PINGPONG});

		loadingCirc = new FlxSprite(loadingTxt.x, 0).loadGraphic(Paths.image('loadingicon'));
		loadingCirc.x += loadingTxt.width;
		loadingCirc.scale.set(0.45, 0.45);
		loadingCirc.updateHitbox();
		loadingCirc.antialiasing = true;
		loadingCirc.screenCenter(Y);
		add(loadingCirc);

		loadBar = new FlxSprite(10, 0).makeGraphic(10, FlxG.height - 150, 0xffffffff);
		loadBar.screenCenter(Y);
		loadBar.antialiasing = true;
		loadBar.color = 0xffff00ff;
		add(loadBar);

		var loadColors:Array<flixel.util.FlxColor> = [0xffff0000, 0xffff7b00, 0xffffff00, 0xff00ff00, 0xff0000ff, 0xffff00ff];
		var loadIncrement:Int = 0;
		clrBarTwn(loadIncrement, loadBar, loadColors, 1);

		callbackTxt = new FlxText(30, 0, 0, "");
		callbackTxt.scrollFactor.set();
		callbackTxt.setFormat("VCR OSD Mono", 16, 0xffffffff, CENTER);
		callbackTxt.screenCenter(Y);
		add(callbackTxt);

		tipTxt = new FlxText(0, FlxG.height - 48, 0, tips[FlxG.random.int(0, tips.length - 1)]);
		tipTxt.scrollFactor.set();
		tipTxt.setFormat("VCR OSD Mono", 16, 0xffffffff, LEFT);
		add(tipTxt);

		var timer = new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			tipTxt.text = tips[FlxG.random.int(0, tips.length - 1)];
		}, 0);
	}

	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end

		loadingCirc.angle += elapsed * loadingCircSpeed;

		if (callbacks != null)
		{
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.y += 0.5 * (targetShit - loadBar.scale.y);
			callbackTxt.text = (callbacks.length - callbacks.numRemaining) + '/' + callbacks.length;
		}
	}

	function clrBarTwn(incrementor:Int, sprite:FlxSprite, clrArray:Array<flixel.util.FlxColor>, duration:Int)
	{
		flixel.tweens.FlxTween.color(sprite, duration, sprite.color, clrArray[incrementor], {
			onComplete: function(_)
			{
				incrementor++;
				if (incrementor > 5)
					incrementor = 0;
				clrBarTwn(incrementor, sprite, clrArray, duration);
			}
		});
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		// var loadup = new LoadingScreen();
		FlxG.sound.music.stop();
		FlxG.switchState(getNextState(target, stopMusic));
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		#if NO_PRELOAD_ALL
		var loaded = isSoundLoaded(getSongPath())
			&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
			&& isLibraryLoaded("shared");

		if (!loaded)
			return new FunkinLoadState(target);
		#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
