package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.ui.FlxInputText;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import lime.app.Application;
import sys.FileSystem;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'ost', 'options', 'discord'];

	var languagesOptions:Array<String> = [
		'main_story',
		'main_freeplay',
		'main_credits',
		'main_ost',
		'main_options',
		'main_discord'
	];

	var languagesDescriptions:Array<String> = [
		'desc_story',
		'desc_freeplay',
		'desc_credits',
		'desc_ost',
		'desc_discord',
		'desc_options'
	];

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;

	public static var daRealEngineVer:String = 'Foxa';
	public static var engineVer:String = '0.1 ALPHA';

	public static var engineVers:Array<String> = ['Foxa'];

	public static var kadeEngineVer:String = "FOXA";
	public static var gameVer:String = "0.2.8";

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var selectUi:FlxSprite;
	var bigIcons:FlxSprite;
	var camFollow:FlxObject;

	public static var bgPaths:Array<String> = ['menu', 'dorito',];

	var logoBl:FlxSprite;

	var lilMenuGuy:FlxSprite;

	var curOptText:FlxText;
	var curOptDesc:FlxText;

	var voidShader:Shaders.GlitchEffect;

	var prompt:Prompt;
	var canInteract:Bool = true;

	var black:FlxSprite;

	override function create()
	{
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		persistentUpdate = persistentDraw = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		KeybindPrefs.loadControls();

		// daRealEngineVer = engineVers[FlxG.random.int(0, 2)];

		bg = new FlxSprite(-80).loadGraphic(randomizeBG());
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF975299;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(bg.graphic);
		magenta.scrollFactor.set();
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xfffdc571;
		add(magenta);

		bg = new FlxBackdrop(Paths.image('ui/checkeredBG', 'preload'), #if (flixel_addons < "3.0.0") 1, 1, true, true, #else XY, #end 1, 1);
		bg.alpha = 0;
		bg.antialiasing = true;
		bg.scrollFactor.set();
		add(bg);

		var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/CoolOverlay'));
		overlay.alpha = 50;
		overlay.scrollFactor.set();
		add(overlay);

		selectUi = new FlxSprite(0, 0).loadGraphic(Paths.image('mainMenu/Select_Thing', 'preload'));
		selectUi.scrollFactor.set(0, 0);
		selectUi.antialiasing = true;
		selectUi.updateHitbox();
		add(selectUi);

		bigIcons = new FlxSprite(0, 0);
		bigIcons.frames = Paths.getSparrowAtlas('ui/menu_big_icons');
		for (i in 0...optionShit.length)
		{
			bigIcons.animation.addByPrefix(optionShit[i], optionShit[i] == 'freeplay' ? 'freeplay0' : optionShit[i], 24);
		}
		bigIcons.scrollFactor.set(0, 0);
		bigIcons.antialiasing = true;
		bigIcons.updateHitbox();
		bigIcons.animation.play(optionShit[0]);
		bigIcons.screenCenter(X);
		add(bigIcons);

		curOptText = new FlxText(0, 0, FlxG.width, CoolUtil.formatString(LanguageManager.getTextString(languagesOptions[curSelected]), ' '));
		curOptText.setFormat(Paths.font("funkin.otf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curOptText.scrollFactor.set(0, 0);
		curOptText.borderSize = 2.5;
		curOptText.antialiasing = true;
		curOptText.screenCenter(X);
		curOptText.y = FlxG.height / 2 + 42;
		add(curOptText);

		curOptDesc = new FlxText(0, 0, FlxG.width, LanguageManager.getTextString(languagesDescriptions[curSelected]));
		curOptDesc.setFormat(Paths.font("funkin.otf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curOptDesc.scrollFactor.set(0, 0);
		curOptDesc.borderSize = 1.8;
		curOptDesc.antialiasing = true;
		curOptDesc.screenCenter(X);
		curOptDesc.y = FlxG.height - 58;
		add(curOptDesc);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('ui/main_menu_icons');

		// camFollow = new FlxObject(0, 0, 1, 1);
		// add(camFollow);

		// FlxG.camera.follow(camFollow, null, 0.06);

		// camFollow.setPosition(640, 150.5);

		for (i in 0...optionShit.length)
		{
			var currentOptionShit = optionShit[i];
			var menuItem:FlxSprite = new FlxSprite(FlxG.width * 1.6, 0);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', (currentOptionShit == 'freeplay glitch' ? 'freeplay' : currentOptionShit) + " basic", 24);
			menuItem.animation.addByPrefix('selected', (currentOptionShit == 'freeplay glitch' ? 'freeplay' : currentOptionShit) + " white", 24);
			menuItem.animation.play('idle');
			menuItem.antialiasing = false;
			menuItem.setGraphicSize(128, 128);
			menuItem.ID = i;
			menuItem.updateHitbox();
			// menuItem.screenCenter(Y);
			// menuItem.alpha = 0; // TESTING
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			if (firstStart)
			{
				FlxTween.tween(menuItem, {x: FlxG.width / 2 - 350 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						// menuItem.screenCenter(Y);
						changeItem();
					}
				});
			}
			else
			{
				// menuItem.screenCenter(Y);
				menuItem.x = FlxG.width / 2 - 350 + (i * 160);
				changeItem();
			}
		}

		firstStart = false;

		// var versionShit:FlxText = new FlxText(1, FlxG.height - 45, FlxG.width, '${daRealEngineVer} Engine v${engineVer}\nFNF v${gameVer}', 12);
		var versionShit:FlxText = new FlxText(1, FlxG.height - 45, FlxG.width, 'Foxa Engine - Vs. Foxa Expanded BETA\nFNF v${gameVer}', 12);
		versionShit.antialiasing = true;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var pressR:FlxText = new FlxText(1, 10, FlxG.width, LanguageManager.getTextString("main_resetdata"), 12);
		pressR.setFormat("Funkin", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pressR.antialiasing = true;
		pressR.alpha = 0;
		pressR.scrollFactor.set();
		add(pressR);

		FlxTween.tween(pressR, {alpha: 1}, 1);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.y = FlxG.height / 2 + 130;
		});

		// NG.core.calls.event.logEvent('swag').send();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		#if SHADERS_ENABLED
		if (voidShader != null)
		{
			voidShader.shader.uTime.value[0] += elapsed;
		}
		#end
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (canInteract)
		{
			#if debug
			if (FlxG.keys.justPressed.EIGHT)
			{
				FlxG.sound.play(Paths.sound('selectMenu'), 0.4);

				FlxG.switchState(new ChartingState());
			}
			#end
			#if release
			if (FlxG.keys.justPressed.SEVEN)
			{
				var deathSound:FlxSound = new FlxSound();
				deathSound.loadEmbedded(Paths.soundRandom('missnote', 1, 3));
				deathSound.volume = FlxG.random.float(0.6, 1);
				deathSound.play();
			}
			#end
			if (FlxG.keys.justPressed.R)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));

				prompt = new Prompt(LanguageManager.getTextString("main_warningdata"), controls);
				prompt.canInteract = true;
				prompt.alpha = 0;
				canInteract = false;

				black = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.screenCenter();
				black.alpha = 0;
				add(black);

				FlxTween.tween(black, {alpha: 0.6}, 0.3);

				FlxTween.tween(prompt, {alpha: 1}, 0.5, {
					onComplete: function(tween:FlxTween)
					{
						prompt.canInteract = true;
					}
				});
				prompt.noFunc = function()
				{
					FlxTween.tween(black, {alpha: 0}, 0.3, {
						onComplete: function(tween:FlxTween)
						{
							remove(black);
						}
					});
					prompt.canInteract = false;
					FlxTween.tween(prompt, {alpha: 0}, 0.5, {
						onComplete: function(tween:FlxTween)
						{
							remove(prompt);
							FlxG.mouse.visible = false;
							canInteract = true;
						}
					});
				}
				prompt.yesFunc = function()
				{
					resetData();
				}
				add(prompt);
			}
		}

		if (!selectedSomethin && canInteract)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'discord' || optionShit[curSelected] == 'merch')
				{
					switch (optionShit[curSelected])
					{
						case 'discord':
							fancyOpenURL("https://discord.gg/TtrjPDDQSJ");
					}
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];
								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
									case 'freeplay' | 'freeplay glitch':
										if (FlxG.random.bool(0.1))
										{
											fancyOpenURL("https://www.youtube.com/watch?v=8rlukRq8vhw&t=239s");
										}
										FlxG.switchState(new FreeplayState());
									case 'options':
										FlxG.switchState(new OptionsStateNew());
									case 'ost':
										FlxG.switchState(new MusicPlayerState());
									case 'credits':
										FlxG.switchState(new CreditsMenuState());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
			// spr.screenCenter(Y);
			spr.updateHitbox();
		});

		bigIcons.animation.play(optionShit[curSelected]);
		curOptText.text = CoolUtil.formatString(LanguageManager.getTextString(languagesOptions[curSelected]), ' ');
		curOptDesc.text = LanguageManager.getTextString(languagesDescriptions[curSelected]);
	}

	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		return Paths.image('backgrounds/${bgPaths[chance]}');
	}

	function resetData()
	{
		FlxG.save.bind('vsfoxa', 'PowderTeam');

		FlxG.save.erase();

		FlxG.save.flush();

		FlxG.save.bind('controls', 'PowderTeam');

		FlxG.save.erase();

		FlxG.save.flush();

		FlxG.save.bind('language', 'PowderTeam');

		FlxG.save.erase();

		FlxG.save.flush();

		FlxG.save.bind('vsfoxa', 'PowderTeam');

		Highscore.songScores = new Map();
		Highscore.songChars = new Map();

		SaveDataHandler.initSave();
		LanguageManager.init();

		Highscore.load();

		CoolUtil.init();

		CharacterSelectState.unlockCharacter('bf');
		CharacterSelectState.unlockCharacter('bf-pixel');

		FlxG.switchState(new StartStateSelector());
	}
}
