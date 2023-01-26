function new(){
    frames = Paths.getSparrowAtlas('characters/gfCar', 'shared');
    danceSteps = ["danceLeft","danceRight"];
    animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
    animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
        false);

    addOffset('danceLeft', 0);
    addOffset('danceRight', 0);

    playAnim('danceRight');
}