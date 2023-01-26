function new(){
    frames = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
    danceSteps = ["danceLeft","danceRight"];
    animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
    animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

    loadOffsetFile(curCharacter);

    globalOffset = [300, 280];

    setGraphicSize(Std.int(width * PlayState.daPixelZoom));
    updateHitbox();
    antialiasing = false;
    barColor = FlxColor.fromString('#33de39');

    playAnim('danceRight');
}