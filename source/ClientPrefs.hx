package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import Controls;

class ClientPrefs {
	//TO DO: Redo ClientPrefs in a way that isn't too stupid
	public static var downScroll:Bool = false;
	public static var newInput:Bool = true;
	public static var songPosition:Bool = true;
	public static var doNoteClick:Bool = false;
	public static var framerate:Int = 60;
	public static var eyesores:Bool = true;
	public static var msText:Bool = true;
	public static var noteCamera:Bool = true;
	public static var botplay:Bool = false;
	public static var offset:Int = 0;

	public static var defaultKeys:Array<FlxKey> = [
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		SPACE, ENTER,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE		//Pause
	];
	//Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState)'s list
	public static var keyBinds:Array<Dynamic> = [
		//Key Bind, Name for ControlsSubState
		[Control.NOTE_LEFT, 'Left'],
		[Control.NOTE_DOWN, 'Down'],
		[Control.NOTE_UP, 'Up'],
		[Control.NOTE_RIGHT, 'Right'],

		[Control.UI_LEFT, 'Left '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_DOWN, 'Down '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_UP, 'Up '],			//Added a space for not conflicting on ControlsSubState
		[Control.UI_RIGHT, 'Right '],	//Added a space for not conflicting on ControlsSubState

		[Control.RESET, 'Reset'],
		[Control.ACCEPT, 'Accept'],
		[Control.BACK, 'Back'],
		[Control.PAUSE, 'Pause']
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.newInput = newInput;
		FlxG.save.data.songPosition = songPosition;
		FlxG.save.data.doNoteClick = doNoteClick;
		FlxG.save.data.eyesores = eyesores;
		FlxG.save.data.msText = msText;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.botplay = botplay;
		FlxG.save.data.noteCamera = noteCamera;
		FlxG.save.data.offset = offset;

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'PowderTeam'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff.
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.songPosition != null) {
			songPosition = FlxG.save.data.songPosition;
		}
		if(FlxG.save.data.doNoteClick != null) {
			doNoteClick = FlxG.save.data.doNoteClick;
		}
		if(FlxG.save.data.eyesores != null) {
			eyesores = FlxG.save.data.eyesores;
		}
		if(FlxG.save.data.msText != null) {
			msText = FlxG.save.data.msText;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(FlxG.save.data.botplay != null) {
			botplay = FlxG.save.data.botplay;
		}
		if(FlxG.save.data.noteCamera != null) {
			noteCamera = FlxG.save.data.noteCamera;
		}
		if(FlxG.save.data.newInput != null) {
			newInput = FlxG.save.data.newInput;
		}
		if(FlxG.save.data.offset != null) {
			offset = FlxG.save.data.offset;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'PowderTeam');
		if(save != null && save.data.customControls != null) {
			reloadControls(save.data.customControls);
		}
	}

	public static function reloadControls(newKeys:Array<FlxKey>) {
		ClientPrefs.removeControls(ClientPrefs.lastControls);
		ClientPrefs.lastControls = newKeys.copy();
		ClientPrefs.loadControls(ClientPrefs.lastControls);
	}

	private static function removeControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToRemove:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToRemove.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToRemove.length > 0) {
				PlayerSettings.player1.controls.unbindKeys(keyBinds[i][0], controlsToRemove);
			}
		}
	}
	private static function loadControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToAdd:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToAdd.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToAdd.length > 0) {
				PlayerSettings.player1.controls.bindKeys(keyBinds[i][0], controlsToAdd);
			}
		}
	}
}