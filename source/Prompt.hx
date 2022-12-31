package;

import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;


class Prompt extends FlxSpriteGroup
{
	var promptText:FlxText;
	var yesText:FlxText;
	var noText:FlxText;
	var texts:Array<FlxText>;

	public var yesFunc:Void->Void;
	public var noFunc:Void->Void;
	public var canInteract:Bool = true;
	public var controls:Controls;

	var curSelected:Int = 0;

	public function new(question:String, controls:Controls)
	{
		super();

		this.controls = controls;

		FlxG.mouse.visible = true;

		promptText = new FlxText(0, FlxG.height / 2 - 200, FlxG.width, question, 16);
		promptText.setFormat("Funkin", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		promptText.screenCenter(X);
		promptText.scrollFactor.set(0, 0);
		promptText.borderSize = 2.5;
		promptText.antialiasing = true;
		add(promptText);

		noText = new FlxText(0, FlxG.height / 2 + 100, 0, "No", 16);
		noText.screenCenter(X);
		noText.x += 200;
		noText.setFormat("Funkin", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.scrollFactor.set(0, 0);
		noText.borderSize = 1.5;
		noText.antialiasing = true;
		add(noText);

		yesText = new FlxText(0, FlxG.height / 2 + 100, 0, "Yes", 16);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.setFormat("Funkin", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.scrollFactor.set(0, 0);
		yesText.borderSize = 1.5;
		yesText.antialiasing = true;
		add(yesText);

		texts = [yesText, noText];

		updateText();
	}

	override function update(elapsed:Float)
	{
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var enter = controls.ACCEPT;

		if (leftP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected--;
			if (curSelected < 0)
			{
				curSelected = 1;
			}
			updateText();
		}
		if (rightP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected++;
			if (curSelected > 1)
			{
				curSelected = 0;
			}
			updateText();
		}
		if (enter)
		{
			select(texts[curSelected]);
		}

		/*
			if (FlxG.mouse.overlaps(noText) && curSelected != texts.indexOf(noText))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = texts.indexOf(noText);
				updateText();
			}
			if (FlxG.mouse.overlaps(yesText) && curSelected != texts.indexOf(yesText))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = texts.indexOf(yesText);
				updateText();
		}*/
		if (FlxG.mouse.justMoved)
		{
			for (i in 0...texts.length)
			{
				if (i != curSelected)
				{
					if (FlxG.mouse.overlaps(texts[i]) && !FlxG.mouse.overlaps(texts[curSelected]))
					{
						curSelected = i;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						updateText();
					}
				}
			}
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(texts[curSelected]))
			{
				select(texts[curSelected]);
			}
		}
		super.update(elapsed);
	}

	function updateText()
	{
		switch (curSelected)
		{
			case 0:
				yesText.borderColor = FlxColor.YELLOW;
				noText.borderColor = FlxColor.BLACK;
			case 1:
				noText.borderColor = FlxColor.YELLOW;
				yesText.borderColor = FlxColor.BLACK;
		}
	}

	function select(text:FlxText)
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		var select = texts.indexOf(text);

		FlxFlicker.flicker(text, 1.1, 0.1, false, false, function(flicker:FlxFlicker)
		{
			switch (select)
			{
				case 0:
					yesFunc();
				case 1:
					noFunc();
			}
		});
	}
}
