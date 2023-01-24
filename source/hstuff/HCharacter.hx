package hstuff;

import SScript.*;

class HCharacter extends CallbackScript
{
	override public function new(charClass:Character, path:String)
	{
		super(path);
		name = "Character:" + charClass.curCharacter;
		set("this", charClass);
		set("char", charClass);
		set("Paths", new CustomPaths(charClass.curCharacter, "preload"));
		set("_Paths", Paths);
	}
}
