function new(){
    frames = Paths.getSparrowAtlas('characters/ovaries', 'shared');
    danceSteps = ["danceLeft","danceRight"];
    animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
    animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

    globalOffset = [0, 200];

    loadOffsetFile(curCharacter);

    barColor = FlxColor.fromString('#33de39');

    playAnim('danceRight');
}