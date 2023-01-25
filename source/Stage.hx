package;

import flixel.FlxSprite;
import sys.FileSystem;
import sys.io.File;
import hstuff.HStage;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

// cant finish yet cuz of school so compile the "useless lol" commit instead ok bye

class Stage extends FlxTypedGroup<FlxBasic> {
    public var publicSprites:Map<String, FlxBasic>;
    public var foreground:FlxTypedGroup<FlxBasic>;
    public var infrontOfGf:FlxTypedGroup<FlxBasic>; // limo AUUUUUGH
    public var ScriptStage:Null<HStage> = null;
    public var curStage:String;
    public var defaultCamZoom:Float = 1.05;
    public var cameraDisplace:{x:Float,y:Float} = {
        x: 0.0,
        y: 0.0
    };
    public function new() {
        super();
        publicSprites = new Map();
        foreground = new FlxTypedGroup();
        infrontOfGf = new FlxTypedGroup();
        curStage = PlayState.curStage;
        switch (curStage) {
            // case "xyz": hardcoding auuuugh
            default:
                if (FileSystem.exists('assets/stages/$curStage/init.hx')) {
                    try {
                        ScriptStage = new HStage(this, 'assets/stages/$curStage/init.hx');
                        ScriptStage.exec("create", []);
                    }
                    catch (e) {
                        trace('Failed to load $curStage from hscript: ${e.message}');
                        ScriptStage = null;
                        loadStageInstead();
                    }
                }
                else loadStageInstead();
        }
    }

    public function reposCharacters() {
        if (ScriptStage != null && ScriptStage.exists("reposCharacters")) {
            ScriptStage.exec("reposCharacters", []);
            return;
        }
    }

    public function stepHit(curStep:Int) {
        if (ScriptStage != null && ScriptStage.exists("stepHit")) { 
            ScriptStage.exec("stepHit", [curStep]); 
            return;
        }
    } 

    public function beatHit(curBeat:Int) {
        if (ScriptStage != null && ScriptStage.exists("beatHit")) {
            ScriptStage.exec("beatHit", [curBeat]);
            return;
        }
    }

    public function stageUpdate(elapsed:Float) {
        super.update(elapsed);
        if (ScriptStage != null && ScriptStage.exists("update")) { 
            ScriptStage.exec("update", [elapsed]);
            return;
        }
    }

    public function createBackgroundSprites(bgName:String, revertedBG:Bool):FlxTypedGroup<FlxSprite>
        {
            var sprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
            var bgZoom:Float = 1.05;
            var stageName:String = '';
    
            // script.executeFunc("createBackgroundSprites", [bgName]);
    
            switch (bgName)
            {
                case 'spooky':
                    stageName = 'spooky';
                    halloweenLevel = true;
    
                    var hallowTex = Paths.getSparrowAtlas('stages/spooky/halloween_bg');
    
                    halloweenBG = new FlxSprite(-200, -100);
                    halloweenBG.frames = hallowTex;
                    halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
                    halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
                    halloweenBG.animation.play('idle');
                    halloweenBG.antialiasing = true;
                    sprites.add(halloweenBG);
                    add(halloweenBG);
    
                    isHalloween = true;
                case 'philly':
                    stageName = 'philly';
    
                    var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stages/philly/sky'));
                    bg.scrollFactor.set(0.1, 0.1);
                    sprites.add(bg);
                    add(bg);
    
                    var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('stages/philly/city'));
                    city.scrollFactor.set(0.3, 0.3);
                    city.setGraphicSize(Std.int(city.width * 0.85));
                    city.updateHitbox();
                    sprites.add(city);
                    add(city);
    
                    phillyCityLights = new FlxTypedGroup<FlxSprite>();
                    add(phillyCityLights);
    
                    for (i in 0...5)
                    {
                        var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('stages/philly/win' + i));
                        light.scrollFactor.set(0.3, 0.3);
                        light.visible = false;
                        light.setGraphicSize(Std.int(light.width * 0.85));
                        light.updateHitbox();
                        light.antialiasing = true;
                        phillyCityLights.add(light);
                    }
    
                    var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('stages/philly/behindTrain'));
                    sprites.add(streetBehind);
                    add(streetBehind);
    
                    phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('stages/philly/train'));
                    sprites.add(phillyTrain);
                    add(phillyTrain);
    
                    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
                    FlxG.sound.list.add(trainSound);
    
                    // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
    
                    var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('stages/philly/street'));
                    sprites.add(street);
                    add(street);
    
                    street.antialiasing = true;
                    streetBehind.antialiasing = true;
                    phillyTrain.antialiasing = true;
                case 'limo':
                    stageName = 'limo';
                    bgZoom = 0.9;
    
                    var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('stages/limo/limoSunset'));
                    skyBG.scrollFactor.set(0.1, 0.1);
                    sprites.add(skyBG);
                    add(skyBG);
    
                    var bgLimo:FlxSprite = new FlxSprite(-200, 480);
                    bgLimo.frames = Paths.getSparrowAtlas('stages/limo/bgLimo');
                    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
                    bgLimo.animation.play('drive');
                    bgLimo.scrollFactor.set(0.4, 0.4);
                    sprites.add(bgLimo);
                    add(bgLimo);
    
                    grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
                    add(grpLimoDancers);
    
                    for (i in 0...5)
                    {
                        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
                        dancer.scrollFactor.set(0.4, 0.4);
                        grpLimoDancers.add(dancer);
                    }
    
                    var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('stages/limo/limoOverlay'));
                    overlayShit.alpha = 0.5;
                    // add(overlayShit);
    
                    // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
    
                    // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
    
                    // overlayShit.shader = shaderBullshit;
    
                    var limoTex = Paths.getSparrowAtlas('stages/limo/limoDrive');
    
                    limo = new FlxSprite(-120, 550);
                    limo.frames = limoTex;
                    limo.animation.addByPrefix('drive', "Limo stage", 24);
                    limo.animation.play('drive');
                    limo.antialiasing = true;
    
                    fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('stages/limo/fastCarLol'));
                case 'mall':
                    stageName = 'mall';
                    bgZoom = 0.8;
    
                    var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('stages/christmas/bgWalls'));
                    bg.antialiasing = true;
                    bg.scrollFactor.set(0.2, 0.2);
                    bg.active = false;
                    bg.setGraphicSize(Std.int(bg.width * 0.8));
                    bg.updateHitbox();
                    sprites.add(bg);
                    add(bg);
    
                    upperBoppers = new FlxSprite(-240, -90);
                    upperBoppers.frames = Paths.getSparrowAtlas('stages/christmas/upperBop');
                    upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
                    upperBoppers.antialiasing = true;
                    upperBoppers.scrollFactor.set(0.33, 0.33);
                    upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
                    upperBoppers.updateHitbox();
                    sprites.add(upperBoppers);
                    add(upperBoppers);
    
                    var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('stages/christmas/bgEscalator'));
                    bgEscalator.antialiasing = true;
                    bgEscalator.scrollFactor.set(0.3, 0.3);
                    bgEscalator.active = false;
                    bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
                    bgEscalator.updateHitbox();
                    sprites.add(bgEscalator);
                    add(bgEscalator);
    
                    var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('stages/christmas/christmasTree'));
                    tree.antialiasing = true;
                    tree.scrollFactor.set(0.40, 0.40);
                    sprites.add(tree);
                    add(tree);
    
                    bottomBoppers = new FlxSprite(-300, 140);
                    bottomBoppers.frames = Paths.getSparrowAtlas('stages/christmas/bottomBop');
                    bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
                    bottomBoppers.antialiasing = true;
                    bottomBoppers.scrollFactor.set(0.9, 0.9);
                    bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
                    bottomBoppers.updateHitbox();
                    sprites.add(bottomBoppers);
                    add(bottomBoppers);
    
                    var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('stages/christmas/fgSnow'));
                    fgSnow.active = false;
                    fgSnow.antialiasing = true;
                    sprites.add(fgSnow);
                    add(fgSnow);
    
                    santa = new FlxSprite(-840, 150);
                    santa.frames = Paths.getSparrowAtlas('stages/christmas/santa');
                    santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
                    santa.antialiasing = true;
                    sprites.add(santa);
                    add(santa);
                case 'mallEvil':
                    stageName = 'mallEvil';
                    bgZoom = 0.8;
    
                    var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('stages/christmas/evilBG'));
                    bg.antialiasing = true;
                    bg.scrollFactor.set(0.2, 0.2);
                    bg.active = false;
                    bg.setGraphicSize(Std.int(bg.width * 0.8));
                    bg.updateHitbox();
                    sprites.add(bg);
                    add(bg);
    
                    var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('stages/christmas/evilTree'));
                    evilTree.antialiasing = true;
                    evilTree.scrollFactor.set(0.2, 0.2);
                    sprites.add(evilTree);
                    add(evilTree);
    
                    var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("stages/christmas/evilSnow"));
                    evilSnow.antialiasing = true;
                    sprites.add(evilSnow);
                    add(evilSnow);
                case 'school':
                    stageName = 'school';
                    // defaultCamZoom = 0.9;
    
                    var bgSky = new FlxSprite().loadGraphic(Paths.image('stages/weeb/weebSky'));
                    bgSky.scrollFactor.set(0.1, 0.1);
                    sprites.add(bgSky);
                    add(bgSky);
    
                    var repositionShit = -200;
    
                    var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('stages/weeb/weebSchool'));
                    bgSchool.scrollFactor.set(0.6, 0.90);
                    sprites.add(bgSchool);
                    add(bgSchool);
    
                    var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('stages/weeb/weebStreet'));
                    bgStreet.scrollFactor.set(0.95, 0.95);
                    sprites.add(bgStreet);
                    add(bgStreet);
    
                    var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('stages/weeb/weebTreesBack'));
                    fgTrees.scrollFactor.set(0.9, 0.9);
                    sprites.add(fgTrees);
                    add(fgTrees);
    
                    var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
                    var treetex = Paths.getPackerAtlas('stages/weeb/weebTrees');
                    bgTrees.frames = treetex;
                    bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
                    bgTrees.animation.play('treeLoop');
                    bgTrees.scrollFactor.set(0.85, 0.85);
                    sprites.add(bgTrees);
                    add(bgTrees);
    
                    var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
                    treeLeaves.frames = Paths.getSparrowAtlas('stages/weeb/petals');
                    treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
                    treeLeaves.animation.play('leaves');
                    treeLeaves.scrollFactor.set(0.85, 0.85);
                    sprites.add(treeLeaves);
                    add(treeLeaves);
    
                    var widShit = Std.int(bgSky.width * 6);
    
                    bgSky.setGraphicSize(widShit);
                    bgSchool.setGraphicSize(widShit);
                    bgStreet.setGraphicSize(widShit);
                    bgTrees.setGraphicSize(Std.int(widShit * 1.4));
                    fgTrees.setGraphicSize(Std.int(widShit * 0.8));
                    treeLeaves.setGraphicSize(widShit);
    
                    fgTrees.updateHitbox();
                    bgSky.updateHitbox();
                    bgSchool.updateHitbox();
                    bgStreet.updateHitbox();
                    bgTrees.updateHitbox();
                    treeLeaves.updateHitbox();
    
                    bgGirls = new BackgroundGirls(-100, 190);
                    bgGirls.scrollFactor.set(0.9, 0.9);
    
                    if (SONG.song.toLowerCase() == 'roses')
                    {
                        bgGirls.getScared();
                    }
    
                    bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
                    bgGirls.updateHitbox();
                    sprites.add(bgGirls);
                    add(bgGirls);
                case 'schoolEvil':
                    stageName = 'schoolEvil';
    
                    var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
                    var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
    
                    var posX = 400;
                    var posY = 200;
    
                    var bg:FlxSprite = new FlxSprite(posX, posY);
                    bg.frames = Paths.getSparrowAtlas('stages/weeb/animatedEvilSchool');
                    bg.animation.addByPrefix('idle', 'background 2', 24);
                    bg.animation.play('idle');
                    bg.scrollFactor.set(0.8, 0.9);
                    bg.scale.set(6, 6);
                    sprites.add(bg);
                    add(bg);
                case 'alley':
                    {
                        defaultCamZoom = 0.9;
                        curStage = 'whitty';
    
                        var wBg:FlxSprite;
    
                        wBg = new FlxSprite(-500, -300).loadGraphic(Paths.image('stages/alley/whittyBack'));
    
                        /*if (SONG.stage == 'ballisticAlley')
                            {
                              trace('pogging');
                              wBg.antialiasing = true;
                              var bgTex = Paths.getSparrowAtlas('BallisticBackground', 'bonusWeek');
                              nwBg = new FlxSprite(-600, -200);
                              nwBg.frames = bgTex;
                              nwBg.antialiasing = true;
                              nwBg.scrollFactor.set(0.9, 0.9);
                              nwBg.active = true;
                              nwBg.animation.addByPrefix('start', 'Background Whitty Start', 24, false);
                              nwBg.animation.addByPrefix('gaming', 'Background Whitty Startup', 24, false);
                              nwBg.animation.addByPrefix('gameButMove', 'Background Whitty Moving', 16, true);
                              add(wBg);
                              add(nwBg);
                              nwBg.alpha = 0;
                              wstageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('whittyFront', 'bonusWeek'));
                              wstageFront.setGraphicSize(Std.int(wstageFront.width * 1.1));
                              wstageFront.updateHitbox();
                              wstageFront.antialiasing = true;
                              wstageFront.scrollFactor.set(0.9, 0.9);
                              wstageFront.active = false;
                              add(wBg);
                              add(wstageFront);
                            }
                            else
                            { */
                        wBg.antialiasing = true;
                        wBg.scrollFactor.set(0.9, 0.9);
                        wBg.active = false;
    
                        var wstageFront:FlxSprite;
    
                        wstageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stages/alley/whittyFront'));
                        wstageFront.setGraphicSize(Std.int(wstageFront.width * 1.1));
                        wstageFront.updateHitbox();
                        wstageFront.antialiasing = true;
                        wstageFront.scrollFactor.set(0.9, 0.9);
                        wstageFront.active = false;
                        add(wBg);
                        add(wstageFront);
                        // }
                        // bg.setGraphicSize(Std.int(bg.width * 2.5));
                        // bg.updateHitbox();
                    }
                case 'ballisticAlley':
                    {
                        defaultCamZoom = 0.9;
                        curStage = 'ballisticAlley';
                        var wBg = new FlxSprite(-500, -300).loadGraphic(Paths.image('stages/alley/whittyBack', 'shared'));
    
                        trace('junkers on steroids');
                        wBg.antialiasing = true;
                        var bgTex = Paths.getSparrowAtlas('stages/ballisticAlley/BallisticBackground', 'shared');
                        var nwBg = new FlxSprite(-600, -200);
                        nwBg.frames = bgTex;
                        nwBg.antialiasing = true;
                        nwBg.scrollFactor.set(0.9, 0.9);
                        nwBg.active = true;
                        nwBg.animation.addByPrefix('start', 'Background Whitty Start', 24, false);
                        nwBg.animation.addByPrefix('gaming', 'Background Whitty Startup', 24, false);
                        nwBg.animation.addByPrefix('gameButMove', 'Background Whitty Moving', 16, true);
                        // add(wBg);
                        add(nwBg);
                        nwBg.alpha = 1;
                        var wstageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stages/alley/whittyFront', 'shared'));
                        wstageFront.setGraphicSize(Std.int(wstageFront.width * 1.1));
                        wstageFront.updateHitbox();
                        wstageFront.antialiasing = true;
                        wstageFront.scrollFactor.set(0.9, 0.9);
                        wstageFront.active = false;
                        /*
                            add(wBg);
                            add(wstageFront);
                         */
                        wBg.alpha = 0;
                        nwBg.alpha = 1;
                        var funneEffect = new FlxSprite(-600, -200).loadGraphic(Paths.image('stages/ballisticAlley/thefunnyeffect', 'shared'));
                        funneEffect.alpha = 0.5;
                        funneEffect.scrollFactor.set();
                        funneEffect.visible = true;
                        add(funneEffect);
    
                        funneEffect.cameras = [camHUD];
    
                        trace('funne: ' + funneEffect);
                        nwBg.animation.play("gameButMove");
                        remove(wstageFront);
                    }
                default:
                    bgZoom = 0.9;
                    stageName = 'stage';
    
                    var bg:BGSprite = new BGSprite('bg', -600, -200, Paths.image('stages/stage/stageback'), null, 0.9, 0.9);
                    sprites.add(bg);
                    add(bg);
    
                    var stageFront:BGSprite = new BGSprite('stageFront', -650, 600, Paths.image('stages/stage/stagefront'), null, 0.9, 0.9);
                    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
                    stageFront.updateHitbox();
                    sprites.add(stageFront);
                    add(stageFront);
    
                    var stageCurtains:BGSprite = new BGSprite('stageCurtains', -500, -300, Paths.image('stages/stage/stagecurtains'), null, 1.3, 1.3);
                    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
                    stageCurtains.updateHitbox();
                    sprites.add(stageCurtains);
                    add(stageCurtains);
            }
            if (!revertedBG)
            {
                defaultCamZoom = bgZoom;
                curStage = stageName;
            }
    
            return sprites;
        }

    function loadStageInstead() {
        // PlayState.defaultCamZoom = 0.9;
		var bg = new FlxSprite(-600, -200).loadGraphic(Paths.file('stage/stageback.png', IMAGE, 'stages'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.file('stage/stagefront.png', IMAGE, 'stages'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.file('stage/stagecurtains.png', IMAGE, 'stages'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
        foreground.add(stageCurtains);
    }

}