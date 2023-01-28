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

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

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
		save.data.customControls = keyBinds;
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
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}