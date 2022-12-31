package;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

// this gotta scare people lol

class GameOverCreationState extends FlxTransitionableState
{
	override function create()
	{
        FlxG.sound.playMusic(Paths.music('gameOver'));

		var restart:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/foxaIsAngry', 'shared'));
		restart.setGraphicSize(Std.int(restart.width * 0.6));
		restart.updateHitbox();
		restart.antialiasing = true;
		add(restart);
		restart.screenCenter();


		super.create();
	}

	private var fading:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && !fading)
		{
			fading = true;
            FlxG.sound.music.stop();
            FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
		super.update(elapsed);
	}
}