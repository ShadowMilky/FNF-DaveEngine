function new(){
    frames = Paths.getSparowAtlas("assets/data/characters/" + curCharacter + "/character");
    animation.addByPrefix('idle', 'BF IDLE', 24, false);
    animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
    animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
    animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
    animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
    animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
    animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
    animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
    animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

    addOffset('idle');
    addOffset("singUP");
    addOffset("singRIGHT");
    addOffset("singLEFT");
    addOffset("singDOWN");
    addOffset("singUPmiss");
    addOffset("singRIGHTmiss");
    addOffset("singLEFTmiss");
    addOffset("singDOWNmiss");

    setGraphicSize(Std.int(width * 6));
    updateHitbox();

    playAnim('idle');

    width -= 100;
    height -= 100;

    antialiasing = false;

    flipX = true;
}