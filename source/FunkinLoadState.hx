import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import sys.thread.Thread;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

class FunkinLoadState extends MusicBeatState {
    // LOADING STUFF
    public var nextState:FlxState;
    public var done:Bool = false;
    public var doingTrans:Bool = false;

    // TIME ELAPSED
    public var time:Float = 0;

    // VISUALS (art by gray shes amazing)
    public var loadingText:Alphabet;
    public var bg:FlxSpriteGroup;
    public var w:Float = 775;
    public var h:Float = 550;

    // CAMERA MANAGEMENT WITHOUT FUCKING EVERYTHING UP
    public var curCamera:FlxCamera;

    public function new(state:FlxState) {
        super();
        nextState = state;
    }

    public override function create() {
        FlxTransitionableState.skipNextTransIn = true;
        super.create();
        
        bg = new FlxSpriteGroup();
        bg.x = 0;
        bg.y = 0;
        add(bg);

        var bgLol = new FlxSprite(FlxG.width, FlxG.height);
        bgLol.loadGraphic(Paths.image("loading/bg", "preload"));
        bgLol.antialiasing = true;
        bg.add(bgLol);
        
        loadingText = new Alphabet(0, 0, "Loading...", false);
        loadingText.x = FlxG.width - 25 - loadingText.width;
        loadingText.y = FlxG.height - 25 - loadingText.height;
        add(loadingText);

        curCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

        cameras = bg.cameras = [curCamera];

        load();

        for(e in members)
            if (e is FlxSprite)
                cast(e, FlxSprite).cameras = [curCamera];

    }

    public function load() {
        doingTrans = false;
        done = false;
        time = 0;
        
        FlxG.cameras.add(curCamera, false);
        FlxG.cameras.cameraAdded.add(onCameraAdded);
        FlxG.cameras.cameraReset.add(onCameraReset);
        FlxG.cameras.cameraResetPost.add(onCameraResetPost);

        persistentUpdate = true;
        persistentDraw = true;

        Thread.runWithEventLoop(function() {
            FlxTransitionableState.skipNextTransIn = true;
            nextState.create();
            done = true;
        });
    }

    private function postStateSwitch() {
        FlxG.cameras.remove(curCamera, false);
        FlxG.signals.postStateSwitch.remove(postStateSwitch);
    }

    
    public override function update(elapsed:Float) {
        super.update(elapsed);
        time += elapsed;

        bg.x -= w * elapsed / 4;
        bg.x %= w;
        bg.y -= h * elapsed / 4;
        bg.y %= h;

        loadingText.text = "Loading" + [for(i in 0...(1+(Std.int(time * 1.5) % 3))) "."].join("");

        if (done && !doingTrans) {
            doingTrans = true;
            FlxG.signals.postStateSwitch.add(postStateSwitch);
            curCamera.fade(0xFF000000, 0.25, false, function() {
                FlxG.game.resetStuffOnSwitch = false;
                FlxG.cameras.cameraAdded.remove(onCameraAdded);
                FlxG.cameras.cameraReset.remove(onCameraReset);
                FlxG.cameras.cameraResetPost.remove(onCameraResetPost);
                FlxG.switchState(nextState);
            });
        }
    }
}