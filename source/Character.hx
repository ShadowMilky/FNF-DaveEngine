package;

import SScript.*;
import sys.FileSystem;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;
import hstuff.HCharacter;
import sys.FileSystem;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile =
{
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var furiosityScale:Float = 1.02;
	public var canDance:Bool = true;
	public var colorTween:FlxTween;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned2:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"

	public var nativelyPlayable:Bool = false;

	public var globalOffset:Array<Float> = new Array<Float>();
	public var offsetScale:Float = 1;

	var hairFramesLoop:Int = 4; // ADVANCED: This is used for mom and bf on Week 4. They go back 4 frames once their singing animation is completed to give an impression that it's looping perfectly

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var barColor:FlxColor;

	public var canSing:Bool = true;
	public var skins:Map<String, String> = new Map<String, String>();

	public static var DEFAULT_CHARACTER:String = 'bf'; // In case a character is missing, it will use BF on its place

	public var charList:Array<String> = [];

	public var bopSpeed:Int = 2;
	public var stopAnims = false;
	public var stopSinging = false;
	public var stopDancing = false;

	var charScript:Null<HCharacter> = null;

	// Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		charList = CoolUtil.coolTextFile(Paths.file('data/characterList.txt', TEXT, 'preload'));

		skins.set('normal', curCharacter);
		skins.set('gfSkin', 'gf-none');

		antialiasing = true;

		switch (curCharacter)
		{
			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);

				loadOffsetFile(curCharacter);

				skins.set('gfSkin', 'gf');

				barColor = FlxColor.fromRGB(49, 176, 209);

				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFile(curCharacter);

				skins.set('gfSkin', 'gf-pixel');

				globalOffset = [196, 163];

				barColor = FlxColor.fromRGB(49, 176, 209);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				antialiasing = false;
				nativelyPlayable = true;

				playAnim('idle');
				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
				nativelyPlayable = true;
				flipX = true;
				playAnim('firstDeath');
			case 'generic-death':
				frames = Paths.getSparrowAtlas('ui/lose', 'shared');
				animation.addByPrefix('firstDeath', "lose... instance 1", 24, false);
				animation.addByPrefix('deathLoop', "still", 24, true);
				animation.addByPrefix('deathConfirm', "still", 24, false);

				loadOffsetFile(curCharacter);
				flipX = true;
				playAnim('firstDeath');
			case 'gf':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('characters/GF_assets', 'shared');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-junkers':
				// GIRLFRIEND CODE BUT LOL
				frames = Paths.getSparrowAtlas('characters/ovaries', 'shared');

				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				globalOffset = [0, 200];

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-whitty':
				// GIRLFRIEND FUNNI CODE
				frames = Paths.getSparrowAtlas('characters/GF_Standing_Sway', 'shared');

				animation.addByPrefix('sad', 'gf sad', 24);
				animation.addByPrefix('danceLeft', 'gf dance left', 24, false);
				animation.addByPrefix('danceRight', 'gf dance right', 24, false);
				animation.addByPrefix('scared', 'gf scared', 24);

				addOffset('sad', -140, -153);
				addOffset('danceLeft', -140, -153);
				addOffset('danceRight', -140, -153);
				addOffset('scared', -140, -153);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-pixel':
				frames = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				globalOffset = [300, 280];

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-christmas':
				frames = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');

			case 'gf-car':
				frames = Paths.getSparrowAtlas('characters/gfCar', 'shared');

				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');

				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'foxa-scrapped': // foxa regular newer
				frames = Paths.getSparrowAtlas('characters/goofy_ahh_foxa', 'shared');

				animation.addByPrefix('idle', 'FoxaIdle', 24, false);
				animation.addByPrefix('singUP', 'Foxa up', 24, false);
				animation.addByPrefix('singRIGHT', 'Foxa right', 24, false);
				animation.addByPrefix('singDOWN', 'Foxa down', 24, false);
				animation.addByPrefix('singLEFT', 'Foxa left', 24, false);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				globalOffset = [0, 200];

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
			case 'foxa-new': // foxa regular new
				frames = Paths.getSparrowAtlas('characters/foxa_newer', 'shared');

				animation.addByPrefix('idle', 'foxa idle dance', 24, false);
				animation.addByPrefix('singUP', 'foxa up', 24, false);
				animation.addByPrefix('singRIGHT', 'foxa right', 24, false);
				animation.addByPrefix('singDOWN', 'foxa down', 24, false);
				animation.addByPrefix('singLEFT', 'foxa left', 24, false);

				addOffset('idle', 0, -100);
				addOffset("singUP", 10, -40);
				addOffset("singRIGHT", -20, -100);
				addOffset("singLEFT", 61, -110);
				addOffset("singDOWN", 30, -160);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				globalOffset = [0, 260];

				setGraphicSize(Std.int(width * 2.1));
				updateHitbox();

				playAnim('idle');
			case 'aumsum': // ITS AUMSUM TIME!!!!
				frames = Paths.getSparrowAtlas('characters/AumSum_Remake', 'shared');

				animation.addByPrefix('idle', 'aumsum idle dance', 24, false);
				animation.addByPrefix('singUP', 'aumsum up', 24, false);
				animation.addByPrefix('singRIGHT', 'aumsum right', 24, false);
				animation.addByPrefix('singDOWN', 'aumsum down', 24, false);
				animation.addByPrefix('singLEFT', 'aumsum left', 24, false);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
			case 'foxa-angy-new': // foxa regular new
				frames = Paths.getSparrowAtlas('characters/FoxaNewMadSprite', 'shared');

				animation.addByPrefix('idle', 'FoxaMad Idle', 24, false);
				animation.addByPrefix('singUP', 'FoxaMad up', 24, false);
				animation.addByPrefix('singRIGHT', 'FoxaMad right', 24, false);
				animation.addByPrefix('singDOWN', 'FoxaMad down', 24, false);
				animation.addByPrefix('singLEFT', 'FoxaMad left', 24, false);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
			case 'creation-new': // foxa regular new
				frames = Paths.getSparrowAtlas('characters/FoxaNewSupaMadSprite', 'shared');

				animation.addByPrefix('idle', 'FoxaUltra Idle', 24);
				animation.addByPrefix('singUP', 'FoxaUltra up', 24);
				animation.addByPrefix('singRIGHT', 'FoxaUltra right', 24);
				animation.addByPrefix('singDOWN', 'FoxaUltra down', 24);
				animation.addByPrefix('singLEFT', 'FoxaUltra left', 24);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
			case 'whitty-ghost': // whitty ghost, for burning flames lol
				frames = Paths.getSparrowAtlas('characters/WhittyGhost', 'shared');

				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

				addOffset('idle', 0, 0);
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');
			case 'rubber': // no.
				frames = Paths.getSparrowAtlas('characters/rubber', 'shared');

				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'creation-new-player': // foxa regular new (player)
				frames = Paths.getSparrowAtlas('characters/FoxaNewSupaMadSprite', 'shared');

				animation.addByPrefix('idle', 'FoxaUltra Idle', 24);
				animation.addByPrefix('singUP', 'FoxaUltra up', 24, false);
				animation.addByPrefix('singRIGHT', 'FoxaUltra right', 24, false);
				animation.addByPrefix('singDOWN', 'FoxaUltra down', 24, false);
				animation.addByPrefix('singLEFT', 'FoxaUltra left', 24, false);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
			case 'foxa': // foxa regular
				frames = Paths.getSparrowAtlas('characters/foxa', 'shared');

				animation.addByPrefix('idle', 'Idle', 24);
				animation.addByPrefix('singUP', 'Sing Up', 24);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24);
				animation.addByPrefix('singDOWN', 'Sing Down', 24);
				animation.addByPrefix('singLEFT', 'Sing Left', 24);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'foxa-angy': // foxa angy
				frames = Paths.getSparrowAtlas('characters/foxa_angy', 'shared');

				animation.addByPrefix('idle', 'Idle', 24);
				animation.addByPrefix('singUP', 'Sing Up', 24);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24);
				animation.addByPrefix('singDOWN', 'Sing Down', 24);
				animation.addByPrefix('singLEFT', 'Sing Left', 24);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'whitty-christmas': // whitty christmas, the only whitty sprites in this mod (currently)
				var tex = Paths.getSparrowAtlas('characters/whitty-christmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24);
				animation.addByPrefix('singUP', 'Sing Up', 24);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24);
				animation.addByPrefix('singDOWN', 'Sing Down', 24);
				animation.addByPrefix('singLEFT', 'Sing Left', 24);
				addOffset('idle', 0, 0);
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);
			case 'foxa-christmas': //
				var tex = Paths.getSparrowAtlas('characters/foxa-christmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Foxa idle dance', 24, false);
				animation.addByPrefix('singUP', 'Foxa NOTE UP', 24, false);
				animation.addByPrefix('singLEFT', 'Foxa NOTE LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'Foxa NOTE RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Foxa NOTE DOWN', 24, false);
				animation.addByPrefix('singUPmiss', 'Foxa NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Foxa NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Foxa NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Foxa NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'Foxa HEY!!', 24, false);

				animation.addByPrefix('firstDeath', "Foxa dies", 24, false);
				animation.addByPrefix('deathLoop', "Foxa Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "Foxa Dead confirm", 24, false);

				animation.addByPrefix('scared', 'Foxa idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				nativelyPlayable = true;
			case 'spooky':
				frames = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');

				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				globalOffset = [0, 200];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('danceRight');
			case 'mom':
				frames = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

			case 'mom-car':
				frames = Paths.getSparrowAtlas('characters/momCar', 'shared');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'monster':
				frames = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);

				globalOffset = [0, 100];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'monster-christmas':
				frames = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);

				globalOffset = [0, 130];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'pico':
				frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');

				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -68, -7);
				addOffset("singLEFT", 65, 9);
				addOffset("singDOWN", 200, -70);
				addOffset("singUPmiss", -19, 67);
				addOffset("singRIGHTmiss", -60, 41);
				addOffset("singLEFTmiss", 62, 64);
				addOffset("singDOWNmiss", 210, -28);

				globalOffset = [0, 300];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				flipX = true;
			case 'bf-christmas':
				frames = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				skins.set('gfSkin', 'gf-christmas');

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				nativelyPlayable = true;
				flipX = true;
			case 'bf-car':
				frames = Paths.getSparrowAtlas('characters/bfCar', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);

				skins.set('gfSkin', 'gf-car');

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				nativelyPlayable = true;
				flipX = true;
			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				globalOffset = [150, 360];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				globalOffset = [150, 360];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				globalOffset = [-150, 100];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				globalOffset = [-500, 0];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
				animation.addByPrefix('idle', 'Tankman Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note 1', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left 1', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note 1', 24, false);

				animation.addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman', 24, false);

				animation.addByPrefix('singUPmiss', 'Tankman UP note MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Tankman DOWN note MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Tankman Right Note MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Tankman Note Left MISS', 24, false);

				addOffset('idle');
				addOffset("singUP", 48, 54);
				addOffset("singDOWN", 76, -101);
				addOffset("singLEFT", 84, -14);
				addOffset("singRIGHT", -21, -31);
				addOffset("singUP-alt", -15, -8);
				addOffset('singDOWN-alt', 1, 16);
				addOffset("singUPmiss", 48, 54);
				addOffset("singRIGHTmiss", 84, -14);
				addOffset("singLEFTmiss", -21, -31);
				addOffset("singDOWNmiss", 76, 101);

				globalOffset = [0, 240];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				flipX = true;
			default:
				if (FileSystem.exists('assets/data/characters/$curCharacter/Init.hx'))
				{
					// var charCode = File.getContent('assets/characters/$curCharacter/Init.hx');
					try
					{
						charScript = new HCharacter(this, 'assets/data/characters/$curCharacter/Init.hx');
						charScript.exec("create", []);
					}
					catch (e)
					{
						charScript = null;
						trace('Failed to load $curCharacter from HScript: ${e.message}');
						loadBfInstead();
					}
				}
				else
					loadBfInstead();
		}
		dance();

		if (isPlayer)
		{
			flipX = !flipX;
		}

		if (charScript != null && charScript.exists("createPost"))
			charScript.exec("createPost", []);
	}

	function loadOffsetFile(character:String)
	{
		var offsetStuffs:Array<String> = CoolUtil.coolTextFile(Paths.offsetFile(character));

		for (offsetframest in offsetStuffs)
		{
			var offsetInfo:Array<String> = offsetframest.split(' ');

			addOffset(offsetInfo[0], Std.parseFloat(offsetInfo[1]), Std.parseFloat(offsetInfo[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (animation == null)
		{
			super.update(elapsed);
			return;
		}
		else if (animation.curAnim == null)
		{
			super.update(elapsed);
			return;
		}
		if (!nativelyPlayable && !isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (heyTimer > 0)
		{
			heyTimer -= elapsed;
			if (heyTimer <= 0)
			{
				if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if (specialAnim && animation.curAnim.finished)
		{
			specialAnim = false;
			dance();
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);

		if (charScript != null && charScript.exists("update"))
		{
			charScript.exec("update", [elapsed]);
			return;
		}
	}

	private var danced:Bool = false;

	/**
	 * FOR DANCING SHIT
	 */
	public function dance()
	{
		if (charScript != null && charScript.exists("dance"))
		{
			charScript.exec("dance", []);
			return;
		}

		if (!debugMode && canDance)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-whitty' | 'gf-junkers':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	// skibbidy beep po
	// (in case there's an issue with hscript ofc)
	function loadBfInstead()
	{
		curCharacter = "bf";
		frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		animation.addByPrefix('hey', 'BF HEY', 24, false);

		animation.addByPrefix('firstDeath', "BF dies", 24, false);
		animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
		animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

		animation.addByPrefix('scared', 'BF idle shaking', 24);

		addOffset('idle', -5);
		addOffset("singUP", -29, 27);
		addOffset("singRIGHT", -38, -7);
		addOffset("singLEFT", 12, -6);
		addOffset("singDOWN", -10, -50);
		addOffset("singUPmiss", -29, 27);
		addOffset("singRIGHTmiss", -30, 21);
		addOffset("singLEFTmiss", 12, 24);
		addOffset("singDOWNmiss", -11, -19);
		addOffset("hey", 7, 4);
		addOffset('firstDeath', 37, 11);
		addOffset('deathLoop', 37, 5);
		addOffset('deathConfirm', 37, 69);
		addOffset('scared', -4);

		playAnim('idle');

		flipX = true;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) == null)
		{
			return; // why wasn't this a thing in the first place
		}
		if ((AnimName.toLowerCase() == 'idle' || AnimName.toLowerCase().startsWith('dance')) && !canDance)
		{
			return;
		}

		if (AnimName.toLowerCase().startsWith('sing') && !canSing)
		{
			return;
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * offsetScale, daOffset[1] * offsetScale);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function getColorCode(char:String):String
	{
		var returnedString:String = '';
		for (i in 0...charList.length)
		{
			var currentValue = charList[i].trim().split(':');
			if (currentValue[0] != char)
			{
				continue;
			}
			else
			{
				returnedString = currentValue[2]; // this is the color code one
			}
		}
		if (returnedString == '')
		{
			return char;
		}
		else
		{
			return returnedString;
		}
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
