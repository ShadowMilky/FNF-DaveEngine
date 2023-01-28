package;

#if desktop
import Discord.DiscordClient;
#end
import Controls;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

// TO DO: Redo the menu creation system for not being as dumb
class OptionsStateNew extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Language', 'Preferences', 'Account'];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		menuBG = new FlxSprite().loadGraphic(MainMenuState.randomizeBG());
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210, options[i], true, false);
			optionText.screenCenter(X);
			grpOptions.add(optionText);
		}
		changeSelection();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}

			switch (options[curSelected])
			{
				case 'Controls':
					openSubState(new ControlsSubState());
				case 'Language':
					FlxG.switchState(new ChangeLanguageState());
				case 'Preferences':
					openSubState(new PreferencesSubstate());
				case 'Account':
					trace('log in pls');
					FlxG.switchState(new LogInScreen(new AccountOption()));
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}

class PreferencesSubstate extends MusicBeatSubstate
{
	var versionShit:FlxText;

	private static var curSelected:Int = 0;
	static var unselectableOptions:Array<String> = ['GRAPHICS', 'GAMEPLAY'];
	static var noCheckbox:Array<String> = ['Framerate', 'Note Delay'];
	static var options:Array<String> = [
		unselectableOptions[0],
		'Eyesores',
		#if !html5
		noCheckbox[0], // Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		#end
		unselectableOptions[1],
		'Downscroll',
		noCheckbox[1],
		'Hitsounds',
		'Botplay',
		'MS Text',
		'Time Bar',
		'Ghost Tapping',
		'Camera Movement'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var characterLayer:FlxTypedGroup<Character>;
	private var showCharacter:Character = null;
	private var descText:FlxText;

	public function new()
	{
		super();
		characterLayer = new FlxTypedGroup<Character>();
		add(characterLayer);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			optionText.itemType = 'Vertical';
			optionText.targetY = i;
			optionText.scrollFactor.set();
			optionText.alpha = 0;
			optionText.y += 1000;
			grpOptions.add(optionText);

			if (!isCentered)
			{
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length)
				{
					if (options[i] == noCheckbox[j])
					{
						useCheckbox = false;
						break;
					}
				}

				if (useCheckbox)
				{
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				}
				else
				{
					var valueText:AttachedText = new AttachedText('0', optionText.width + 80);
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		versionShit = new FlxText(5, FlxG.height - 18, 0, "Select an option.", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		for (i in 0...options.length)
		{
			if (!unselectableCheck(i))
			{
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			grpOptions.forEachAlive(function(spr:Alphabet)
			{
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText)
			{
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length)
			{
				var spr:CheckboxThingie = checkboxArray[i];
				if (spr != null)
				{
					spr.alpha = 0;
				}
			}
			if (showCharacter != null)
			{
				showCharacter.alpha = 0;
			}
			descText.alpha = 0;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		var usesCheckbox = true;
		for (i in 0...noCheckbox.length)
		{
			if (options[curSelected] == noCheckbox[i])
			{
				usesCheckbox = false;
				break;
			}
		}

		if (usesCheckbox)
		{
			if (controls.ACCEPT && nextAccept <= 0)
			{
				switch (options[curSelected])
				{
					case 'Time Bar':
						ClientPrefs.songPosition = !ClientPrefs.songPosition;
					case 'Eyesores':
						ClientPrefs.eyesores = !ClientPrefs.eyesores;
					case 'MS Text':
						ClientPrefs.msText = !ClientPrefs.msText;

					case 'Hitsounds':
						ClientPrefs.doNoteClick = !ClientPrefs.doNoteClick;

					case 'Botplay':
						ClientPrefs.botplay = !ClientPrefs.botplay;

					case 'Camera Movement':
						ClientPrefs.noteCamera = !ClientPrefs.noteCamera;

					case 'Downscroll':
						ClientPrefs.downScroll = !ClientPrefs.downScroll;

					case 'Ghost Tapping':
						ClientPrefs.newInput = !ClientPrefs.newInput;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadValues();
			}
		}
		else
		{
			if (controls.UI_LEFT || controls.UI_RIGHT)
			{
				var add:Int = controls.UI_LEFT ? -1 : 1;
				if (holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
					switch (options[curSelected])
					{
						case 'Framerate':
							ClientPrefs.framerate += add;
							if (ClientPrefs.framerate < 60)
								ClientPrefs.framerate = 60;
							else if (ClientPrefs.framerate > 240)
								ClientPrefs.framerate = 240;

							if (ClientPrefs.framerate > FlxG.drawFramerate)
							{
								FlxG.updateFramerate = ClientPrefs.framerate;
								FlxG.drawFramerate = ClientPrefs.framerate;
							}
							else
							{
								FlxG.drawFramerate = ClientPrefs.framerate;
								FlxG.updateFramerate = ClientPrefs.framerate;
							}
						case 'Note Delay':
							var mult:Int = 1;
							if (holdTime > 1.5)
							{ // Double speed after 1.5 seconds holding
								mult = 2;
							}
							ClientPrefs.offset += add * mult;
							if (ClientPrefs.offset < 0)
								ClientPrefs.offset = 0;
							else if (ClientPrefs.offset > 500)
								ClientPrefs.offset = 500;
					}
				reloadValues();

				if (holdTime <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));
				holdTime += elapsed;
			}
			else
			{
				holdTime = 0;
			}
		}

		if (showCharacter != null && showCharacter.animation.curAnim.finished)
		{
			showCharacter.dance();
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var daText:String = '';
		switch (options[curSelected])
		{
			case 'Framerate':
				daText = "Pretty self explanatory, isn't it?\nDefault value is 60.";
			case 'Note Delay':
				daText = "Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones.";
			case 'Camera Movement':
				daText = "If unchecked, the camera would not move when the notes get hit.";
			case 'Time Bar':
				daText = "If checked, shows the time bar.";
			case 'Eyesores':
				daText = "If unchecked, the shaders won't appear.";
			case 'Downscroll':
				daText = "If checked, notes go Down instead of Up, simple enough.";
			case 'MS Text':
				daText = "If checked, the milisecond precise text will display\nevery time a note gets hit.";
			case 'Botplay':
				daText = "If unchecked, you would have to play the songs yourself.";
			case 'Hitsounds':
				daText = "If checked, the hitsounds wil play.";
			case 'Ghost Tapping':
				daText = "If unchecked, you would miss even if there's no notes to be hit.";
			default:
				daText = "I don't know what to say here, though.";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}

				for (j in 0...checkboxArray.length)
				{
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if (tracker == item)
					{
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				text.alpha = 0.6;
				if (textNumber[i] == curSelected)
				{
					text.alpha = 1;
				}
			}
		}

		if (options[curSelected] == 'Eyesores')
		{
			if (showCharacter == null)
			{
				showCharacter = new Character(840, 170, 'bf', true);
				showCharacter.setGraphicSize(Std.int(showCharacter.width * 0.8));
				showCharacter.updateHitbox();
				showCharacter.dance();
				characterLayer.add(showCharacter);
			}
		}
		else if (showCharacter != null)
		{
			characterLayer.clear();
			showCharacter = null;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadValues()
	{
		for (i in 0...checkboxArray.length)
		{
			var checkbox:CheckboxThingie = checkboxArray[i];
			if (checkbox != null)
			{
				var daValue:Bool = false;
				switch (options[checkboxNumber[i]])
				{
					case 'Time Bar':
						daValue = ClientPrefs.songPosition;
					case 'Eyesores':
						daValue = ClientPrefs.eyesores;
					case 'MS Text':
						daValue = ClientPrefs.msText;
					case 'Hitsounds':
						daValue = ClientPrefs.doNoteClick;
					case 'Downscroll':
						daValue = ClientPrefs.downScroll;
					case 'Camera Movement':
						daValue = ClientPrefs.noteCamera;
					case 'Botplay':
						daValue = ClientPrefs.botplay;
					case 'Ghost Tapping':
						daValue = ClientPrefs.newInput;
				}
				checkbox.set_daValue(daValue);
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var daText:String = '';
			switch (options[textNumber[i]])
			{
				case 'Framerate':
					daText = 'Select an option. | Framerate: ' + ClientPrefs.framerate;
				case 'Note Delay':
					daText = 'Select an option. | Framerate: ' + ClientPrefs.offset + 'ms';
				default:
					daText = "Select an option.";
			}
			versionShit.text = daText;
		}
	}

	private function unselectableCheck(num:Int):Bool
	{
		for (i in 0...unselectableOptions.length)
		{
			if (options[num] == unselectableOptions[i])
			{
				return true;
			}
		}
		return options[num] == '';
	}
}

class LogInScreen extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var name:FlxText;
	var backDrop:FlxBackdrop;
	var nameBox:FlxInputText;
	var option:AccountOption;
	var incorrect:FlxText;
	var initialized:Bool = false;

	public var username:String = Assets.getText(Paths.txt('userAccount'));

	public function new(option:AccountOption)
	{
		this.option = option;
		super();

		FlxG.sound.music.stop();

		FlxG.sound.playMusic(Paths.music('selectLanguageMenu'), 0.7);

		FlxG.mouse.visible = true;

		bg = new FlxSprite();
		bg.color = 0xffc58fc1;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.antialiasing = true;
		bg.loadGraphic(MainMenuState.randomizeBG());
		add(bg);

		backDrop = new FlxBackdrop(Paths.image('ui/checkeredBG', 'preload'), #if (flixel_addons < "3.0.0") 1, 1, true, true, #else XY, #end 1, 1);
		backDrop.antialiasing = true;
		add(backDrop);

		name = new FlxText(100, 100, 0, "Account Name", 60);
		name.font = "VCR OSD Mono";
		name.color = 0xFFffffff;
		add(name);

		nameBox = new FlxInputText(600, 100, 600, "", 60, FlxColor.BLACK, 0xffffb6fb);
		nameBox.font = "VCR OSD Mono";
		add(nameBox);

		// might add a password thingy later lol

		incorrect = new FlxText(300, 500, 0, "Press Enter to log in, escape to cancel.", 30);
		incorrect.font = "VCR OSD Mono";
		incorrect.color = 0xFFffffff;
		add(incorrect);
	}

	override function update(elapsed:Float)
	{
		var scrollSpeed:Float = 50;
		backDrop.x -= scrollSpeed * elapsed;
		backDrop.y -= scrollSpeed * elapsed;

		if (FlxG.keys.justPressed.ENTER)
		{
			trace(nameBox.text);
			trace(initialized);
			if (nameBox.text == username)
			{
				FlxG.save.data.userName = nameBox.text;
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				trace(FlxG.save.data.userName + "has been signed in!");
				option.log();
				close();
			}
			else
			{
				FlxG.sound.play(Paths.sound('errorMenu'), 0.4);
				trace('you failed lol');
				incorrect.text = "Log in failed, please check your account again.";
				incorrect.color = 0xffff0000;
				incorrect.x = 150;
			}
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			trace('aight imma head out');
			FlxG.sound.music.stop();

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			FlxG.switchState(new OptionsStateNew());
		}

		super.update(elapsed);
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
		display2 = updateDisplay2();
	}

	private var description:String = "";
	private var display:String;
	private var display2:Array<String>;
	private var acceptValues:Bool = false;

	public var selected:Int = 0;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getDisplay2():Array<String>
	{
		return display2;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String
	{
		return throw "stub!";
	};

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	private function updateDisplay2():Array<String>
	{
		return [];
	}

	public function updateCheck():Bool
	{
		return throw "noCheck";
	}

	public function left():Bool
	{
		return throw "stub!";
	}

	public function right():Bool
	{
		return throw "stub!";
	}
}

class AccountOption extends Option
{
	public override function updateCheck():Bool
	{
		return throw "noCheck";
	}

	public function log()
	{
		var display = updateDisplay();
		var display2 = updateDisplay2();
	}

	var initialized:Bool = false;
	var good:Bool = false;

	public override function press():Bool
	{
		if (initialized)
		{
			PlayState.instance.openSubState(new LogInScreen(this));
		}
		else
		{
			FlxG.save.data.userName = null;
			System.exit(0);
		}
		return false;
	}

	private override function updateDisplay():String
	{
		if (initialized)
			return "Log In";
		return "Log Out";
	}

	private override function updateDisplay2():Array<String>
	{
		if (initialized)
			return [""];
		return [FlxG.save.data.userName];
	}
}
