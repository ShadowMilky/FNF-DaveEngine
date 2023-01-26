package;

import haxe.macro.Type.ClassKind;
import flixel.addons.ui.FlxUIText;
import cpp.Prime;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

using StringTools;

class AddAnim extends MusicBeatSubstate
{
	var tabs = [{name: "", label: ''},];
	var xmlAnimDropDown:FlxUIDropDownMenu;
	var curXmlFrame:String;

	public function new()
	{
		super();
		var availableAnims:Array<String> = [];
		FlxG.state.persistentUpdate = false;
		this.cameras = [CharacterEditorState.current.uiCAM];
		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		bg.alpha = 0.6;
		add(bg);
		var box = new FlxUITabMenu(null, tabs, true);
		box.getTab("").toggled = true;
		box.resize(450, 200);
		box.screenCenter();
		add(box);
		var closeBut = new FlxButton(box.x + box.width - 35, box.y + 5, "", function()
		{
			close();
		});
		closeBut.antialiasing = true;
		closeBut.color = 0xFFFF0000;
		closeBut.setGraphicSize(30, 30);
		closeBut.updateHitbox();

		var animHelpText = new FlxUIText(0, 0, 0, "Animation Name(like 'idle' 'singLEFT' 'singRIGHT')", 8);
		animHelpText.screenCenter();
		add(animHelpText);
		var xmlHelpText = new FlxUIText(0, 0, 0, "Frame Name(Name In Xml)", 8);
		xmlHelpText.screenCenter();
		xmlHelpText.y -= 25;
		add(xmlHelpText);
		animHelpText.y -= 75;

		var animTextBox = new FlxUIInputText(0, 0, 100, '${CharacterEditorState.current.curAnim}', 16, 0xFF000000, 0xFFFFFFFF);
		animTextBox.screenCenter();
		animTextBox.y -= 50;
		add(animTextBox);
		var numbers = "0123456789";
		for (frame in CharacterEditorState.current.character.frames.frames)
		{
			var animName = frame.name;
			while (numbers.contains(animName.substr(-1)))
			{
				animName = animName.substr(0, animName.length - 1);
			}
			if (!availableAnims.contains(animName))
				availableAnims.push(animName);
		}
		var addBut = new FlxButton(0, 0, "Add", function()
		{
			for (anim in CharacterEditorState.current.animList)
			{
				if (animTextBox.text.trim() == anim)
					return;
			}
			CharacterEditorState.current.animList.push(animTextBox.text);
			CharacterEditorState.current.addAnim(animTextBox.text, curXmlFrame, 24);
			trace(CharacterEditorState.current.json.anims);
			close();
		});
		addBut.screenCenter();
		addBut.y += 80;
		add(addBut);
		var xmlAnimDropDown = new FlxUIDropDownMenu(0, 0, FlxUIDropDownMenu.makeStrIdLabelArray(availableAnims, false), function(frame:String)
		{
			curXmlFrame = frame;
		});
		xmlAnimDropDown.canScroll = true;
		add(xmlAnimDropDown);
		xmlAnimDropDown.screenCenter(X);
		xmlAnimDropDown.scrollFactor.set();
        xmlAnimDropDown.y += 345;
		trace(availableAnims);
		add(closeBut);
	}
}