package hstuff;

import SScript.*;
import flixel.FlxG;

// @:enum abstract FlxColor(String) to String {}
// HSCRIPT?!? REFLECT?!? REAL.
class HBase extends SScript
{
	public function new(?path:String)
	{
		super(path);
		set("PlayState", PlayState);
		set("GameOverSubstate", GameOverSubstate);
		set("importLib", importLib);
		set("Reflect", Reflect);
		set("Type", Type);
		set("Conductor", Conductor);
		set("SaveDataHandler", SaveDataHandler);
		parser.line = 1;
		parser.allowTypes = true;
		parser.allowJSON = true;
	}

	// psych engine??? i might switch to a different lib which will deprecate this
	function importLib(lib:String, alias = "")
	{
		var name = alias != "" ? alias : lib.split(".").pop();
		var target = Type.resolveClass(lib);
		if (target != null && get(name) == null)
			set(name, target);
	}
}
