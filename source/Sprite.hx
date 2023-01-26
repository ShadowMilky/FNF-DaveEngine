package;

import flixel.ui.FlxBar;
import flixel.FlxSprite;
/**
 * sprite class the uses flxsprite for a base
 */
class Sprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>> = [];

	public function new(x:Float = 0, y:Float = 0, antialiasing:Bool = true, flipX:Bool = false)
	{
		super(x, y);
		this.antialiasing = antialiasing;
		this.flipX = flipX;
	}

	/**
	 * It plays the animation with the name `name` and forcing it to play if `force` is true.
	 */
	public function play(name:String, force:Bool)
	{
		animation.play(name, force);
		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	/**
	 * It's adding an offset to the animation with the name `name`.
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
