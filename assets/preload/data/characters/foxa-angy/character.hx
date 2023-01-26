function new(){
    frames = Paths.getSparrowAtlas('characters/FoxaNewMadSprite', 'shared');

    animation.addByPrefix('idle', 'FoxaMad Idle', 24, false);
    animation.addByPrefix('singUP', 'FoxaMad up', 24, false);
    animation.addByPrefix('singRIGHT', 'FoxaMad right', 24, false);
    animation.addByPrefix('singDOWN', 'FoxaMad down', 24, false);
    animation.addByPrefix('singLEFT', 'FoxaMad left', 24, false);

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString(getColorCode(curCharacter));

    setGraphicSize(Std.int(width * 0.8));
    updateHitbox();

    playAnim('idle');
}