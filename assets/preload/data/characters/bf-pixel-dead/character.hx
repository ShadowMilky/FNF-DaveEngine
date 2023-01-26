function new(){
    frames = Paths.getSparowAtlas("assets/data/characters/" + curCharacter + "/character");
    animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
    animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
    animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
    animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
    animation.play('firstDeath');

    addOffset('firstDeath');
    addOffset('deathLoop', -37);
    addOffset('deathConfirm', -37);
    playAnim('firstDeath');
    // pixel bullshit
    setGraphicSize(Std.int(width * 6));
    updateHitbox();
    antialiasing = false;
    flipX = true;
}