package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

/**
 * handles save data initialization
 */
class SaveDataHandler
{
	public static function initSave()
	{
		if (ClientPrefs.newInput == null)
			ClientPrefs.newInput = true;

		if (ClientPrefs.downScroll == null)
			ClientPrefs.downScroll = false;

		if (FlxG.save.data.freeplayCuts == null)
			FlxG.save.data.freeplayCuts = false;

		if (ClientPrefs.eyesores == null)
			ClientPrefs.eyesores = true;

		if (ClientPrefs.doNoteClick == null)
			ClientPrefs.doNoteClick = false;

		if (ClientPrefs.newInput != null && FlxG.save.data.lastversion == null)
			FlxG.save.data.lastversion = "pre-beta2";

		if (ClientPrefs.newInput == null && FlxG.save.data.lastversion == null)
			FlxG.save.data.lastversion = "beta2";

		if (ClientPrefs.songPosition == null)
			ClientPrefs.songPosition = true;

		if (ClientPrefs.noteCamera == null)
			ClientPrefs.noteCamera = true;

		if (ClientPrefs.offset == null)
			ClientPrefs.offset = 0;

		if (ClientPrefs.framerate == null)
			ClientPrefs.framerate = 144;

		if (FlxG.save.data.selfAwareness == null)
			FlxG.save.data.selfAwareness = true;

		if (FlxG.save.data.wasInCharSelect == null)
			FlxG.save.data.wasInCharSelect = false;

		if (FlxG.save.data.charactersUnlocked == null)
			FlxG.save.data.charactersUnlocked = ['bf', 'bf-pixel', 'bf-christmas']; // i didnt notice this was used to unlock characters woops -redstoneSC

		if (FlxG.save.data.disableFps == null)
			FlxG.save.data.disableFps = false;

		if (ClientPrefs.botplay == null)
			ClientPrefs.botplay = false;

		if (ClientPrefs.msText == null)
			ClientPrefs.msText = false;
	}
}
