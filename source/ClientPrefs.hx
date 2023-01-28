package;

import flixel.FlxG;
import flixel.util.FlxSave;

class ClientPrefs {
	//TO DO: Redo ClientPrefs in a way that isn't too stupid
	public var downScroll:Bool = false;
	public var newInput:Bool = true;
	public var songPosition:Bool = true;
	public var doNoteClick:Bool = false;
	public var framerate:Int = 60;
	public var eyesores:Bool = true;
	public var msText:Bool = true;
	public var noteCamera:Bool = true;
	public var botplay:Bool = false;
	public var offset:Int = 0;

	public function saveSettings() {
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
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public function loadPrefs() {
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
	}
}