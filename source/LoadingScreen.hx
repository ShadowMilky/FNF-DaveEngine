import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.crypto.Md5;
import hscript.Interp;
import lime.system.System;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;

class LoadingScreen extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var targetShit:Float = 0;

	public static var globeTrans:Bool = true;

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

	public function new()
	{
		super();
		screenThing();
	}

	public function screenThing()
	{
		var loading:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loadingscreen'));
		add(loading);

		trace('please work please');

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

	var aborted = false;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		loadingCirc.angle += elapsed * loadingCircSpeed;

		#if !sys
		if (switchin || aborted)
			return;

		if (step >= loadSections.length)
		{
			switchin = true;
			FlxG.autoPause = true;
			var e = new TitleState();
			trace(e);
			FlxG.switchState(e);
		}
		#end
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
}
