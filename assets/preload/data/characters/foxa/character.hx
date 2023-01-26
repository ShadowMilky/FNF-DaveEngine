function new(){
    frames = Paths.getSparrowAtlas('characters/goofy_ahh_foxa', 'shared');

    animation.addByPrefix('idle', 'FoxaIdle', 24, false);
    animation.addByPrefix('singUP', 'Foxa up', 24, false);
    animation.addByPrefix('singRIGHT', 'Foxa right', 24, false);
    animation.addByPrefix('singDOWN', 'Foxa down', 24, false);
    animation.addByPrefix('singLEFT', 'Foxa left', 24, false);

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString(getColorCode(curCharacter));

    globalOffset = [0, 200];

    setGraphicSize(Std.int(width * 0.8));
    updateHitbox();

    playAnim('idle');
}