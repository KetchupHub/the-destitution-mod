package ui;

import states.PlayState;
import flixel.FlxSprite;
import backend.ClientPrefs;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import backend.Conductor;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class SongIntroCard extends FlxSpriteGroup
{
    public var _charObj:FlxSprite;
    public var _cardObj:FlxSprite;
    public var _cardObjBelly:FlxSprite;
    public var _textObj:FlxText;
    public var _credObj:FlxText;
    public var _timer:Float;
    public var _ending:Bool = false;

    public override function new(x:Float, y:Float, cardName:String, songDisplayName:String, composer:String, color:FlxColor)
    {
        super(x, y);

        _timer = ((Conductor.crochet / 250) * 2) + (0.25 / PlayState.instance.playbackRate);

        _charObj = new FlxSprite().loadGraphic(Paths.image('ui/songCards/' + cardName, null, true));
        if (Paths.image('ui/songCards/' + cardName, null, true) == null)
        {
            _charObj = new FlxSprite().loadGraphic(Paths.image('ui/songCards/placeholder'));
        }
        _charObj.setGraphicSize(1280);
        _charObj.updateHitbox();
        _charObj.antialiasing = ClientPrefs.globalAntialiasing;
        add(_charObj);

        _cardObj = new FlxSprite().loadGraphic(Paths.image('ui/introCard'));
        _cardObj.scale.set(2, 2);
        _cardObj.updateHitbox();
        _cardObj.color = color;
        add(_cardObj);

        _cardObjBelly = new FlxSprite().loadGraphic(Paths.image('ui/introCardBelly'));
        _cardObjBelly.scale.set(2, 2);
        _cardObjBelly.updateHitbox();
        add(_cardObjBelly);

        _textObj = new FlxText(211, 438, 860, songDisplayName, 72);
        _textObj.setFormat(Paths.font("BAUHS93.ttf"), 72 + 8, color, FlxTextAlign.CENTER, NONE);
        _textObj.antialiasing = ClientPrefs.globalAntialiasing;
        _textObj.bold = true;
        add(_textObj);

        _credObj = new FlxText(211, 438 + 86, 860, "Composed by " + composer, 24);
        _credObj.setFormat(Paths.font("BAUHS93.ttf"), 24 + 8, FlxColor.BLACK, FlxTextAlign.CENTER, NONE);
        _credObj.antialiasing = ClientPrefs.globalAntialiasing;
        add(_credObj);
    }

    public override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!_ending)
        {
            _timer -= 1 * elapsed;

            if (_timer <= 0)
            {
                startEnding();
            }
        }
    }

    public function startEnding():Void
    {
        _ending = true;

        FlxTween.tween(_credObj, {alpha: 0, y: _credObj.y + 128}, Conductor.crochet / 500, {ease: FlxEase.circOut, onComplete: function the(tw:FlxTween)
        {
            _credObj.destroy();
        }});

        FlxTween.tween(_textObj, {alpha: 0, y: _textObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.circOut, onComplete: function the(tw:FlxTween)
        {
            _textObj.destroy();
        }});

        FlxTween.tween(_charObj, {alpha: 0, y: _charObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.circOut, onComplete: function the(tw:FlxTween)
        {
            _charObj.destroy();
        }});

        FlxTween.tween(_cardObjBelly, {alpha: 0, y: _cardObjBelly.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.circOut, onComplete: function the(tw:FlxTween)
        {
            _cardObjBelly.destroy();
        }});

        FlxTween.tween(_cardObj, {alpha: 0, y: _cardObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.circOut, onComplete: function the(tw:FlxTween)
        {
            _cardObj.destroy();
            this.destroy();
        }});
    }
}