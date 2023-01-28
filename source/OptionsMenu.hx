package;

/* import Controls.Control;
import Controls.KeyboardScheme;
import OptionsMenu;
import flash.system.System;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var controlsStrings:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;

	var bgShader:Shaders.GlitchEffect;

	var languages:Array<Language> = new Array<Language>();
	var currentLanguage:Int = 0;
	var curLanguage:String = LanguageManager.save.data.language;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Options Menu", null);
		#end

		FlxG.mouse.visible = true;

		var menuBG:FlxSprite = new FlxSprite();

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.antialiasing = true;
		menuBG.loadGraphic(MainMenuState.randomizeBG());
		add(menuBG);

		languages = LanguageManager.getLanguages();

		controlsStrings = CoolUtil.coolStringFile(LanguageManager.getTextString('option_change_keybinds')
			+ "\n"
			+ (FlxG.save.data.newInput ? LanguageManager.getTextString('option_ghostTapping_on') : LanguageManager.getTextString('option_ghostTapping_off'))
			+ "\n"
			+ (FlxG.save.data.downscroll ? LanguageManager.getTextString('option_downscroll') : LanguageManager.getTextString('option_upscroll'))
			+ "\n"
			+ (FlxG.save.data.songPosition ? LanguageManager.getTextString('option_songPosition_on') : LanguageManager.getTextString('option_songPosition_off'))
			+ "\n"
			+ (FlxG.save.data.eyesores ? LanguageManager.getTextString('option_eyesores_enabled') : LanguageManager.getTextString('option_eyesores_disabled'))
			+ "\n"
			+ (FlxG.save.data.donoteclick ? LanguageManager.getTextString('option_hitsound_on') : LanguageManager.getTextString('option_hitsound_off'))
			+ "\n"
			+ (FlxG.save.data.noteCamera ? LanguageManager.getTextString('option_noteCamera_on') : LanguageManager.getTextString('option_noteCamera_off'))
			+ "\n"
			+ LanguageManager.getTextString('option_change_langauge')
			+ "\n"
			+ (FlxG.save.data.disableFps ? LanguageManager.getTextString('option_enable_fps') : LanguageManager.getTextString('option_disable_fps'))
			+ "\n"
			+ (CompatTool.save.data.compatMode ? LanguageManager.getTextString('option_disable_compat') : LanguageManager.getTextString('option_enable_compat'))
			+ "\n"
			+ (FlxG.save.data.botplay ? LanguageManager.getTextString('option_botplay_on') : LanguageManager.getTextString('option_botplay_off'))
			+ "\n"
			+ (FlxG.save.data.msText ? LanguageManager.getTextString('option_mstext_on') : LanguageManager.getTextString('option_mstext_off'))
			+ "\n"
			+ 'Account Settings');

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.screenCenter(X);
			controlLabel.itemType = 'Vertical';
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		versionShit = new FlxText(5, FlxG.height - 18, 0, "Select an option. | Offset (Left, Right): " + FlxG.save.data.offset, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if SHADERS_ENABLED
		if (bgShader != null)
		{
			bgShader.shader.uTime.value[0] += elapsed;
		}
		#end

		if (controls.BACK)
		{
			FlxG.save.flush();
			CompatTool.save.flush();
			FlxG.switchState(new MainMenuState());
		}
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.RIGHT_R)
		{
			FlxG.save.data.offset++;
			versionShit.text = "Select an option. | Offset (Left, Right): " + FlxG.save.data.offset;
		}

		if (controls.LEFT_R)
		{
			FlxG.save.data.offset--;
			versionShit.text = "Select an option. | Offset (Left, Right): " + FlxG.save.data.offset;
		}
		if (controls.ACCEPT)
		{
			grpControls.remove(grpControls.members[curSelected]);
			switch (curSelected)
			{
				case 0:
					new FlxTimer().start(0.01, function(timer:FlxTimer)
					{
						FlxG.switchState(new ChangeKeybinds());
					});
					updateGroupControls(LanguageManager.getTextString('option_change_keybinds'), 0, 'Vertical');
				case 1:
					FlxG.save.data.newInput = !FlxG.save.data.newInput;
					updateGroupControls((FlxG.save.data.newInput ? LanguageManager.getTextString('option_ghostTapping_on') : LanguageManager.getTextString('option_ghostTapping_off')),
						1, 'Vertical');
				case 2:
					FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
					updateGroupControls((FlxG.save.data.downscroll ? LanguageManager.getTextString('option_downscroll') : LanguageManager.getTextString('option_upscroll')),
						2, 'Vertical');
				case 3:
					FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
					updateGroupControls((FlxG.save.data.songPosition ? LanguageManager.getTextString('option_songPosition_on') : LanguageManager.getTextString('option_songPosition_off')),
						3, 'Vertical');
				case 4:
					FlxG.save.data.eyesores = !FlxG.save.data.eyesores;
					updateGroupControls((FlxG.save.data.eyesores ? LanguageManager.getTextString('option_eyesores_enabled') : LanguageManager.getTextString('option_eyesores_disabled')),
						4, 'Vertical');
				case 5:
					FlxG.save.data.donoteclick = !FlxG.save.data.donoteclick;
					updateGroupControls((FlxG.save.data.donoteclick ? LanguageManager.getTextString('option_hitsound_on') : LanguageManager.getTextString('option_hitsound_off')),
						5, 'Vertical');
				case 6:
					FlxG.save.data.noteCamera = !FlxG.save.data.noteCamera;
					updateGroupControls((FlxG.save.data.noteCamera ? LanguageManager.getTextString('option_noteCamera_on') : LanguageManager.getTextString('option_noteCamera_off')),
						6, 'Vertical');
				case 7:
					updateGroupControls(LanguageManager.getTextString('option_change_langauge'), 7, 'Vertical');
					FlxG.switchState(new ChangeLanguageState());
				case 8:
					FlxG.save.data.disableFps = !FlxG.save.data.disableFps;
					Main.fps.visible = !FlxG.save.data.disableFps;
					updateGroupControls(FlxG.save.data.disableFps ? LanguageManager.getTextString('option_enable_fps') : LanguageManager.getTextString('option_disable_fps'),
						8, 'Vertical');
				case 9:
					CompatTool.save.data.compatMode = !CompatTool.save.data.compatMode;
					updateGroupControls(CompatTool.save.data.compatMode ? LanguageManager.getTextString('option_disable_compat') : LanguageManager.getTextString('option_enable_compat'),
						10, 'Vertical');
				case 10:
					FlxG.save.data.botplay = !FlxG.save.data.botplay;
					updateGroupControls(FlxG.save.data.botplay ? LanguageManager.getTextString('option_botplay_on') : LanguageManager.getTextString('option_botplay_off'),
						10,
						'Vertical');
				case 11:
					FlxG.save.data.msText = !FlxG.save.data.msText;
					updateGroupControls(FlxG.save.data.msText ? LanguageManager.getTextString('option_mstext_on') : LanguageManager.getTextString('option_mstext.off'),
						8,
						'Vertical');
				case 12:
					updateGroupControls('Account Settings', 7, 'Vertical');
					trace('log in pls');
					FlxG.switchState(new LogInScreen(new AccountOption()));
			}
		}
	}

	var isSettingControl:Bool = false;

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom: 1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	function updateGroupControls(controlText:String, yIndex:Int, controlTextItemType:String)
	{
		FlxG.sound.play(Paths.sound('selectMenu'), 0.4);
		
		var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, controlText, true, false);
		ctrl.screenCenter(X);
		ctrl.isMenuItem = true;
		ctrl.targetY = curSelected - yIndex;
		ctrl.itemType = controlTextItemType;
		grpControls.add(ctrl);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
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

		backDrop = new FlxBackdrop(Paths.image('ui/checkeredBG', 'preload'),  #if (flixel_addons < "3.0.0") 1, 1, true, true, #else XY, #end 1, 1);
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
			FlxG.switchState(new MainMenuState());
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
*/