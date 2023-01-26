function new(){
    frames = Paths.getSparrowAtlas('characters/FoxaNewSupaMadSprite', 'shared');

    animation.addByPrefix('idle', 'FoxaUltra Idle', 24);
    animation.addByPrefix('singUP', 'FoxaUltra up', 24);
    animation.addByPrefix('singRIGHT', 'FoxaUltra right', 24);
    animation.addByPrefix('singDOWN', 'FoxaUltra down', 24);
    animation.addByPrefix('singLEFT', 'FoxaUltra left', 24);

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString(getColorCode(curCharacter));

    setGraphicSize(Std.int(width * 0.8));
    updateHitbox();

    playAnim('idle');
}