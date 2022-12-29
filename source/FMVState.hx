package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class FMVState extends FlxSprite
{
	public var offsetScale:Float = 1;

	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new()
	{
		super();
	}

	function create()
	{
		FlxG.sound.music.stop();

		animOffsets = new Map<String, Array<Dynamic>>();

		var frames = Paths.getSparrowAtlas('cutscenes/burningflames_cut');

		animation.addByPrefix('cutscene', 'cutscene', 20);

		FlxG.sound.play(Paths.sound('cutscene/burningflamesCutscene'));

		playAnim('cutscene');

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxG.switchState(new PlayState());
		});
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
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) == null)
		{
			return; // why wasn't this a thing in the first place
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * offsetScale, daOffset[1] * offsetScale);
		}
		else
			offset.set(0, 0);
	}
}
