function new(){
    frames = Paths.getSparrowAtlas('characters/rubber', 'shared');

    animation.addByPrefix('idle', 'idle', 24, false);
    animation.addByPrefix('singUP', 'up', 24, false);
    animation.addByPrefix('singRIGHT', 'right', 24, false);
    animation.addByPrefix('singDOWN', 'down', 24, false);
    animation.addByPrefix('singLEFT', 'left', 24, false);

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString(getColorCode(curCharacter));

    playAnim('idle');
}