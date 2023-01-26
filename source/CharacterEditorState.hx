package;

import flixel.addons.ui.FlxUICheckBox;
import AddAnimSubState;
import flixel.math.FlxRect;
import sys.FileSystem;
import openfl.Assets;
import haxe.Json;
import openfl.net.FileReference;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUIInputText;
import Character.CharacterJson;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;

using StringTools;

class CharacterEditorState extends MusicBeatState
{
	var file:FileReference;

	public var json:CharacterJson;

	public static var current:CharacterEditorState;

	public var uiCAM = new FlxCamera(0, 0, 1280, 720, 1);
	public var character:Character;
	public var animList:Array<String> = [];
	public var curAnim:String = "idle";

	var animsText:FlxText;
	var animDropDown:FlxUIDropDownMenu;
	var loopedCheckBox:FlxUICheckBox;
	var characterDropDown:FlxUIDropDownMenu;
	var uiBox:FlxUITabMenu;
	var saveBut:FlxButton;
	var offsetsTextBox:FlxUIInputText;
	var characterTab = new FlxSpriteGroup();
	var AnimTab = new FlxSpriteGroup();
	var addAnimBut:FlxButton;
	var textHitBox:FlxRect;
	var indicesTextBox:FlxUIInputText;
	var tabs = [
		{name: "Character", label: 'Character'},
		{name: "Animation", label: 'Animation'},
	];

	override function create()
	{
		current = this;
		FlxG.cameras.add(uiCAM, false);
		uiCAM.bgColor = 0;
		character = new Character(100, 100, "dad");
		if (character.json != null)
		{
			json = character.json;
			FlxG.log.notice("json Found For Character " + character.curCharacter);
		}
		else
		{
			FlxG.log.error("json not Found For Character " + character.curCharacter);
		}

		super.create();
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(300, 200);
		uiBox.x = 830;
		var charactersList:Array<String> = [];
		FlxG.mouse.useSystemCursor = true;
		for (dir in FileSystem.readDirectory('assets/data/characters'))
		{
			if (FileSystem.isDirectory('assets/data/characters/$dir'))
				charactersList.push(dir);
		}
		addAnimBut = new FlxButton(uiBox.x + uiBox.width / 8 + 12, 110, "Add Anim", function()
		{
			openSubState(new AddAnim());
		});
		indicesTextBox = new FlxUIInputText(uiBox.x + uiBox.width / 1.5, uiBox.y + uiBox.height / 2.5, 50, '', 8, 0xFF000000, 0xFFFFFFFF);
		indicesTextBox.callback = function(text:String, j:String)
		{
			for (anim in json.anims)
			{
				if (anim.name == curAnim)
				{
					var fakerIndices = text.split(",");
					var indices = [];
					for (number in fakerIndices)
					{
						indices.push(Std.parseInt(number.trim()));
					}

					anim.indices = indices;
					trace(indices);
				}
			}
		}
		offsetsTextBox = new FlxUIInputText(uiBox.x + uiBox.width / 8 + 6, 75, 100, '', 12, 0xFF000000, 0xFFFFFFFF);
		offsetsTextBox.callback = function(text:String, cool:String)
		{
			try
			{
				var oyeahaha = text.split(",");
				var offsets = [Std.parseFloat(oyeahaha[0]), Std.parseFloat(oyeahaha[1])];
				if (Math.isNaN(offsets[0]) || Math.isNaN(offsets[1]))
					return;
				var i:Int = 0;
				for (anims in json.anims)
				{
					var name = anims.name;
					if (name == curAnim)
					{
						json.anims[i].offsets = offsets;
						character.addOffset(curAnim, offsets[0], offsets[1]);
					}
					i++;
				}

				trace(json.anims[animList.indexOf(curAnim)].offsets);
			}
			catch (e)
			{
				FlxG.log.error(e.details());
			}
		}
		saveBut = new FlxButton(uiBox.x + uiBox.width / 8 + 12, uiBox.y + uiBox.height - 50, "Save Character", function()
		{
			FlxG.log.notice("saveing data");
			file = new FileReference();
			file.save(Json.stringify(json, "\t"), "character.json");
			trace(json);
		});
		characterDropDown = new FlxUIDropDownMenu(uiBox.x + uiBox.width / 8, uiBox.y + uiBox.height / 4,
			FlxUIDropDownMenu.makeStrIdLabelArray(charactersList, false), function(character:String)
		{
			try
			{
				this.character.changeCharacter(character);
				animList = this.character.animation.getNameList();
				animDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animList, false));
				json = this.character.json;
			}
			catch (e)
			{
				FlxG.log.error(e.details());
				json = {
					globalOffset: [0, 0],
					icon: "dad",
					singDur: 4.0,
					barColor: "0xFFFF0000",
					antialiasing: true,
					type: "SPARROW",
					danceSteps: ["idle"],
					camOffsets: [0, 0],
					anims: []
				}
			}
			FlxG.log.add(character);
		});

		animList = character.animation.getNameList();
		curAnim = animList[0];

		animDropDown = new FlxUIDropDownMenu(uiBox.x + uiBox.width / 8, 75 / 2, FlxUIDropDownMenu.makeStrIdLabelArray(animList, false), function(anim:String)
		{
			character.playAnim(anim, true);
			curAnim = anim;

			if (character != null || character.animOffsets.exists(curAnim))
			{
				offsetsTextBox.text = character.animOffsets.get(curAnim)[0] + "," + character.animOffsets.get(curAnim)[1];
				for (anim in json.anims)
				{
					if (curAnim == anim.name)
					{
						loopedCheckBox.checked = anim.looped;
					}
				}
			}
		});

		animDropDown.setSize(300, 150);
		loopedCheckBox = new FlxUICheckBox(uiBox.x + uiBox.width / 1.5, 40, null, null, "Looped", 50, null, function()
		{
			var i:Int = 0;
			for (anim in json.anims)
			{
				if (anim.name == curAnim)
				{
					anim.looped = loopedCheckBox.checked;
					trace(anim.looped);
				}
			}
		});
		var background = new Sprite(-600, -525).loadGraphic(Paths.image('stages/stage/stageback', 'shared'));
		var front = new Sprite(-650, 325).loadGraphic(Paths.image('stages/stage/stagefront', 'shared'));
		var curt = new Sprite(-500, -625).loadGraphic(Paths.image('stages/stage/stagecurtains', 'shared'));
		background.antialiasing = true;
		front.antialiasing = true;
		curt.antialiasing = true;

		background.screenCenter(X);
		background.scale.set(0.7, 0.7);
		front.screenCenter(X);
		front.scale.set(0.7, 0.7);
		curt.screenCenter(X);
		curt.scale.set(0.7, 0.7);

		background.scrollFactor.set(0.9, 0.9);
		curt.scrollFactor.set(0.9, 0.9);
		front.scrollFactor.set(0.9, 0.9);

		add(background);
		add(front);
		add(curt);
		add(character);
		add(uiBox);
		characterTab.add(saveBut);
		characterTab.add(characterDropDown);
		AnimTab.add(indicesTextBox);
		AnimTab.add(loopedCheckBox);
		AnimTab.add(offsetsTextBox);
		AnimTab.add(addAnimBut);
		AnimTab.add(animDropDown);
		add(characterTab);

		add(AnimTab);
		AnimTab.cameras = [uiCAM];
		characterTab.cameras = [uiCAM];
		uiBox.cameras = [uiCAM];
		offsetsTextBox.cameras = [uiCAM];
		saveBut.cameras = [uiCAM];
		animDropDown.cameras = [uiCAM];
		uiBox.getTab("Character").toggled = true;
	}

	public function addAnim(name:String, xmlName:String, fps:Int)
	{
		json.anims.push({
			name: name,
			indices: null,
			nameInXml: xmlName,
			offsets: [0, 0],
			frameRate: fps,
			looped: false
		});
		character.animation.addByPrefix(name, xmlName, fps, false);
		character.json = json;
		animDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animList));
	}

	override function update(elasped:Float)
	{
		// character.addOffset(animList[animList.indexOf(curAnim)], Std.parseFloat(offsetsTextBox.text.split(",")[0]),
		// 	Std.parseFloat(offsetsTextBox.text.split(",")[1]));
		// json.anims[animList.indexOf(curAnim)].offsets = cast((offsetsTextBox.text.split(",")));
		if (uiBox.getTab("Character").toggled)
		{
			characterTab.visible = true;
			AnimTab.visible = false;
		}
		else
		{
			characterTab.visible = false;
			AnimTab.visible = true;
		}
		super.update(elasped);
		if (FlxG.keys.justPressed.SPACE)
		{
			character.playAnim(curAnim, true);
			trace(curAnim);
		}
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= 1 * elasped;
		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += 1 * elasped;
	}
}
