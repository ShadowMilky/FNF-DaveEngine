function new(){
    frames = Paths.getSparowAtlas("assets/data/characters/" + curCharacter + "/character");
    animation.addByPrefix('idle', 'BF idle dance', 24, false);
    animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
    animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
    animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
    animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
    animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
    animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
    animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
    animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
    animation.addByPrefix('hey', 'BF HEY', 24, false);

    addOffset('idle', -5);
    addOffset("singUP", -29, 27);
    addOffset("singRIGHT", -38, -7);
    addOffset("singLEFT", 12, -6);
    addOffset("singDOWN", -10, -50);
    addOffset("singUPmiss", -29, 27);
    addOffset("singRIGHTmiss", -30, 21);
    addOffset("singLEFTmiss", 12, 24);
    addOffset("singDOWNmiss", -11, -19);
    addOffset("hey", 7, 4);

    playAnim('idle');

    flipX = true;
}