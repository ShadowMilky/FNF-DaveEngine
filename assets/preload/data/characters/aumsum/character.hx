function new(){
    frames = Paths.getSparrowAtlas('characters/AumSum_Remake', 'shared');

    animation.addByPrefix('idle', 'aumsum idle dance', 24, false);
    animation.addByPrefix('singUP', 'aumsum up', 24, false);
    animation.addByPrefix('singRIGHT', 'aumsum right', 24, false);
    animation.addByPrefix('singDOWN', 'aumsum down', 24, false);
    animation.addByPrefix('singLEFT', 'aumsum left', 24, false);

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString(getColorCode(curCharacter));

    setGraphicSize(Std.int(width * 0.8));
    updateHitbox();

    playAnim('idle');
}