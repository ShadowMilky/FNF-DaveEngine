package;

import flixel.FlxG;
import flixel.FlxState;

class StartStateSelector extends FlxState
{
	public override function create()
	{
		LanguageManager.initSave();
		LanguageManager.save.data.language == null;
		if (LanguageManager.save.data.language == null)
		{
			trace('choose your language!\nalso this is your first time compiling this mod\nso thank you for that.');
			FlxG.switchState(new SelectLanguageState());
		}
		else
		{
			FlxG.switchState(new TitleState());
		}
	}
}
