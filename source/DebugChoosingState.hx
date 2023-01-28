package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

using StringTools;

// took from psych because lazy
class DebugChoosingState extends MusicBeatState
{
	var options:Array<String> = [
		'Character Editor',
		'Stage Editor',
		'Credits Editor',
		'Notepad',
		'Character Testing'
	];

	public static var debugSongsData:Array<Dynamic> = [
		// ['Nadalyn-Sings-Spookeez', 'Nadbattle', 'Nadders'],
		// ['Start-Conjunction', 'Energy-Lights', 'Telegroove'],
		['Ridge', 'Test']
	];

	var curDebugSong:Int = 1;

	private var grpTexts:FlxTypedGroup<Alphabet>;

	private var curSelected = 0;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
		}

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.G)
		{
			openSubState(new DebugSongFreeplaySubState(debugSongsData[curDebugSong]));
		}

		if (controls.ACCEPT)
		{
			switch (options[curSelected])
			{
				case 'Character Editor':
					FlxG.switchState(new editors.CharacterEditor());
				case 'Stage Editor':
					FlxG.switchState(new editors.StageEditor());
				case 'Character Testing':
					FlxG.switchState(new CharacterTestState());
				case 'Credits Editor':
					FlxG.switchState(new editors.CreditsEditor());
				case 'Notepad':
					FlxG.switchState(new NotepadThing());
			}
			FlxG.sound.music.volume = 0;
		}

		var bullShit:Int = 0;
		for (item in grpTexts.members)
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
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}
}