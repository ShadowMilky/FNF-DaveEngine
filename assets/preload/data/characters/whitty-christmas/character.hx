function new(){
    frames = Paths.getSparrowAtlas('characters/whitty-christmas', 'shared');

    animation.addByPrefix('idle', 'Idle', 24, false);
    animation.addByPrefix('singUP', 'Sing Up', 24, false);
    animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
    animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
    animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

    addOffset('idle', 0, 0);
    addOffset("singUP", -6, 50);
    addOffset("singRIGHT", 0, 27);
    addOffset("singLEFT", -10, 10);
    addOffset("singDOWN", 0, -30);

    playAnim('idle');
}