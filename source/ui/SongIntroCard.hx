package ui;

import visuals.PixelPerfectSprite;
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
    public var _charObj:PixelPerfectSprite;
    public var _cardObj:PixelPerfectSprite;
    public var _cardObjBelly:PixelPerfectSprite;
    public var _textObj:FlxText;
    public var _credObj:FlxText;
    public var _timer:Float;
    public var _ending:Bool = false;

    public static final _sizeMultipFromSixForty:Float = 1.25;

    public override function new(x:Float, y:Float, cardName:String, songDisplayName:String, composer:String, color:FlxColor)
    {
        super(x, y);

        _timer = ((Conductor.crochet / 250) * 2) + (0.1 / PlayState.instance.playbackRate);

        _charObj = new PixelPerfectSprite().loadGraphic(Paths.image('ui/songCards/' + cardName, null, true));
        if (Paths.image('ui/songCards/' + cardName, null, true) == null)
        {
            _charObj.loadGraphic(Paths.image('ui/songCards/placeholder'));
        }
        _charObj.setGraphicSize(640 * _sizeMultipFromSixForty);
        _charObj.updateHitbox();
        _charObj.antialiasing = ClientPrefs.globalAntialiasing;
        add(_charObj);

        _cardObj = new PixelPerfectSprite().loadGraphic(Paths.image('ui/introCard'));
        _cardObj.scale.set(_sizeMultipFromSixForty, _sizeMultipFromSixForty);
        _cardObj.updateHitbox();
        _cardObj.color = color;
        add(_cardObj);

        _cardObjBelly = new PixelPerfectSprite().loadGraphic(Paths.image('ui/introCardBelly'));
        _cardObjBelly.scale.set(_sizeMultipFromSixForty, _sizeMultipFromSixForty);
        _cardObjBelly.updateHitbox();
        add(_cardObjBelly);

        _textObj = new FlxText((211 / 2) * _sizeMultipFromSixForty, (438 / 2) * _sizeMultipFromSixForty, (860 / 2) * _sizeMultipFromSixForty, songDisplayName, Std.int(36 * _sizeMultipFromSixForty));
        _textObj.setFormat(Paths.font("BAUHS93.ttf"), Std.int(40 * _sizeMultipFromSixForty), color, FlxTextAlign.CENTER, NONE);
        _textObj.antialiasing = ClientPrefs.globalAntialiasing;
        _textObj.bold = true;
        add(_textObj);

        _credObj = new FlxText((211 / 2) * _sizeMultipFromSixForty, ((438 + 86) / 2) * _sizeMultipFromSixForty, (860 / 2) * _sizeMultipFromSixForty, "Composed by " + composer, Std.int(12 * _sizeMultipFromSixForty));
        _credObj.setFormat(Paths.font("BAUHS93.ttf"), Std.int(((24 + 8) / 2) * _sizeMultipFromSixForty), FlxColor.BLACK, FlxTextAlign.CENTER, NONE);
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

        FlxTween.tween(_credObj, {alpha: 0, y: _credObj.y + 128}, Conductor.crochet / 500, {ease: FlxEase.backOut, onComplete: function the(tw:FlxTween)
        {
            _credObj.destroy();
        }});

        FlxTween.tween(_textObj, {alpha: 0, y: _textObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.backOut, onComplete: function the(tw:FlxTween)
        {
            _textObj.destroy();
        }});

        FlxTween.tween(_charObj, {alpha: 0, y: _charObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.backOut, onComplete: function the(tw:FlxTween)
        {
            _charObj.destroy();
        }});

        FlxTween.tween(_cardObjBelly, {alpha: 0, y: _cardObjBelly.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.backOut, onComplete: function the(tw:FlxTween)
        {
            _cardObjBelly.destroy();
        }});

        FlxTween.tween(_cardObj, {alpha: 0, y: _cardObj.y + 128}, Conductor.crochet / 1000, {ease: FlxEase.backOut, onComplete: function the(tw:FlxTween)
        {
            _cardObj.destroy();
            this.destroy();
        }});
    }
}