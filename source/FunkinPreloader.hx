package;

import util.CLIUtil;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Lib;
import flixel.system.FlxBasePreloader;
import util.MathUtil;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

using StringTools;

// Annotation embeds the asset in the executable for faster loading.
// Polymod can't override this, so we can't use this technique elsewhere.

@:bitmap("art/preloaderArt.png")
class LogoImage extends BitmapData {}

/**
 * This preloader displays a logo while the game downloads assets.
 */
class FunkinPreloader extends FlxBasePreloader
{
  /**
   * The logo image width at the base resolution.
   * Scaled up/down appropriately as needed.
   */
  static final BASE_WIDTH:Float = 640;

  /**
   * Margin at the sides and bottom, around the loading bar.
   */
  static final BAR_PADDING:Float = 20;

  static final BAR_HEIGHT:Int = 12;

  /**
   * Logo takes this long (in seconds) to fade in.
   */
  static final LOGO_FADE_TIME:Float = 1;

  // Ratio between window size and BASE_WIDTH
  var ratio:Float = 0;

  var currentState:FunkinPreloaderState = FunkinPreloaderState.NotStarted;

  private var downloadingAssetsPercent:Float = -1;
  private var downloadingAssetsComplete:Bool = false;

  private var preloadingPlayAssetsPercent:Float = -1;
  private var preloadingPlayAssetsStartTime:Float = -1;
  private var preloadingPlayAssetsComplete:Bool = false;

  private var cachingGraphicsPercent:Float = -1;
  private var cachingGraphicsStartTime:Float = -1;
  private var cachingGraphicsComplete:Bool = false;

  private var cachingAudioPercent:Float = -1;
  private var cachingAudioStartTime:Float = -1;
  private var cachingAudioComplete:Bool = false;

  private var cachingDataPercent:Float = -1;
  private var cachingDataStartTime:Float = -1;
  private var cachingDataComplete:Bool = false;

  private var parsingSpritesheetsPercent:Float = -1;
  private var parsingSpritesheetsStartTime:Float = -1;
  private var parsingSpritesheetsComplete:Bool = false;

  private var parsingStagesPercent:Float = -1;
  private var parsingStagesStartTime:Float = -1;
  private var parsingStagesComplete:Bool = false;

  private var parsingCharactersPercent:Float = -1;
  private var parsingCharactersStartTime:Float = -1;
  private var parsingCharactersComplete:Bool = false;

  private var parsingSongsPercent:Float = -1;
  private var parsingSongsStartTime:Float = -1;
  private var parsingSongsComplete:Bool = false;

  private var initializingScriptsPercent:Float = -1;

  private var cachingCoreAssetsPercent:Float = -1;

  /**
   * The timestamp when the other steps completed and the `Finishing up` step started.
   */
  private var completeTime:Float = -1;

  // Graphics
  var logo:Bitmap;
  var progressBarPieces:Array<Sprite>;
  var progressBar:Bitmap;
  var progressLeftText:TextField;
  var progressRightText:TextField;

  var dspText:TextField;
  var fnfText:TextField;
  var enhancedText:TextField;
  var stereoText:TextField;

  var box:Sprite;
  var progressLines:Sprite;

  public function new()
  {
    super(0.1);

    CLIUtil.resetWorkingDir();
  }

  override function create():Void
  {
    // Nothing happens in the base preloader.
    super.create();

    // Background color.
    Lib.current.stage.color = 0xFF000000;

    // Width and height of the preloader.
    this._width = Lib.current.stage.stageWidth;
    this._height = Lib.current.stage.stageHeight;

    // Scale assets to the screen size.
    ratio = this._width / BASE_WIDTH / 2.0;

    // Create the logo.
    logo = createBitmap(LogoImage, function(bmp:Bitmap) {
      bmp.scaleX = bmp.scaleY = ratio;
      bmp.x = (this._width - bmp.width) / 2;
      bmp.y = (this._height - bmp.height) / 2;
    });

    var amountOfPieces:Int = 16;
    progressBarPieces = [];
    var maxBarWidth = this._width - BAR_PADDING * 2;
    var pieceWidth = maxBarWidth / amountOfPieces;
    var pieceGap:Int = 8;

    progressLines = new Sprite();
    progressLines.graphics.lineStyle(2, 0xFFE4D7BC);
    progressLines.graphics.drawRect(-2, 480, this._width + 4, 30);
    //addChild(progressLines);

    var progressBarPiece = new Sprite();
    progressBarPiece.graphics.beginFill(0xFFE4D7BC);
    progressBarPiece.graphics.drawRoundRect(0, 0, pieceWidth - pieceGap, BAR_HEIGHT, 4, 4);
    progressBarPiece.graphics.endFill();

    for (i in 0...amountOfPieces)
    {
      var piece = new Sprite();
      piece.graphics.beginFill(0xFFE4D7BC);
      piece.graphics.drawRoundRect(0, 0, pieceWidth - pieceGap, BAR_HEIGHT, 4, 4);
      piece.graphics.endFill();

      piece.x = i * (piece.width + pieceGap);
      piece.y = this._height - BAR_PADDING - BAR_HEIGHT - 200;
      //addChild(piece);
      progressBarPieces.push(piece);
    }

    progressLeftText = new TextField();
    dspText = new TextField();
    fnfText = new TextField();
    enhancedText = new TextField();
    stereoText = new TextField();

    var progressLeftTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 32, 0xFFE4D7BC, true);
    progressLeftTextFormat.align = TextFormatAlign.LEFT;
    progressLeftText.defaultTextFormat = progressLeftTextFormat;

    progressLeftText.selectable = false;
    progressLeftText.width = this._width - BAR_PADDING * 2;
    progressLeftText.text = 'Downloading assets...';
    progressLeftText.x = BAR_PADDING;
    progressLeftText.y = this._height - BAR_PADDING - BAR_HEIGHT - 290;
    //addChild(progressLeftText);

    progressRightText = new TextField();

    var progressRightTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 16, 0xFFE4D7BC, true);
    progressRightTextFormat.align = TextFormatAlign.RIGHT;
    progressRightText.defaultTextFormat = progressRightTextFormat;

    progressRightText.selectable = false;
    progressRightText.width = this._width - BAR_PADDING * 2;
    progressRightText.text = '0%';
    progressRightText.x = BAR_PADDING;
    progressRightText.y = this._height - BAR_PADDING - BAR_HEIGHT - 16 - 4;
    //addChild(progressRightText);

    box = new Sprite();
    box.graphics.beginFill(0xFFE4D7BC, 1);
    box.graphics.drawRoundRect(0, 0, 64, 20, 5, 5);
    box.graphics.drawRoundRect(70, 0, 58, 20, 5, 5);
    box.graphics.endFill();
    box.graphics.beginFill(0xFFE4D7BC, 0.1);
    box.graphics.drawRoundRect(0, 0, 128, 20, 5, 5);
    box.graphics.endFill();
    box.x = 880;
    box.y = 440;
    //addChild(box);

    dspText.selectable = false;
    dspText.textColor = 0xFF4D1818;
    dspText.width = this._width;
    dspText.height = 20;
    dspText.text = 'DSP';
    dspText.x = 10;
    dspText.y = -5;
    //box.addChild(dspText);

    fnfText.selectable = false;
    fnfText.textColor = 0xFF4D1818;
    fnfText.width = this._width;
    fnfText.height = 20;
    fnfText.x = 75;
    fnfText.y = -5;
    fnfText.text = 'MMC';
    //box.addChild(fnfText);

    enhancedText.selectable = false;
    enhancedText.textColor = 0xFFE4D7BC;
    enhancedText.width = this._width;
    enhancedText.height = 100;
    enhancedText.text = 'WORSENED';
    enhancedText.x = -100;
    enhancedText.y = 0;
    //box.addChild(enhancedText);

    stereoText.selectable = false;
    stereoText.textColor = 0xFFE4D7BC;
    stereoText.width = this._width;
    stereoText.height = 100;
    stereoText.text = 'ARTIFICIAL MONO';
    stereoText.x = 0;
    stereoText.y = -40;
    //box.addChild(stereoText);

    addChild(logo);
  }

  var lastElapsed:Float = 0.0;

  override function update(percent:Float):Void
  {
    var elapsed:Float = (Date.now().getTime() - this._startTime) / 1000.0;

    downloadingAssetsPercent = percent;
    var loadPercent:Float = updateState(percent, elapsed);
    updateGraphics(loadPercent, elapsed);

    lastElapsed = elapsed;
  }

  function updateState(percent:Float, elapsed:Float):Float
  {
    switch (currentState)
    {
      case FunkinPreloaderState.NotStarted:
        if (downloadingAssetsPercent > 0.0)
        {
          currentState = FunkinPreloaderState.DownloadingAssets;
        }

        return percent;
      case FunkinPreloaderState.DownloadingAssets:
        if (downloadingAssetsPercent >= 1.0 || (elapsed > 0.1 && downloadingAssetsComplete))
        {
          currentState = FunkinPreloaderState.PreloadingPlayAssets;
        }

        return percent;
      case FunkinPreloaderState.PreloadingPlayAssets:
        if (preloadingPlayAssetsPercent < 0.0)
        {
          preloadingPlayAssetsStartTime = elapsed;
          preloadingPlayAssetsPercent = 0.0;

          preloadingPlayAssetsPercent = 1.0;
          preloadingPlayAssetsComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedPreloadingPlayAssets:Float = elapsed - preloadingPlayAssetsStartTime;

          if (preloadingPlayAssetsComplete && elapsedPreloadingPlayAssets >= 0.1)
          {
            currentState = FunkinPreloaderState.InitializingScripts;
            return 0.0;
          }
          else
          {
            // We need to return SIMULATED progress here.
            if (preloadingPlayAssetsPercent < (elapsedPreloadingPlayAssets / 0.1))
            {
              return preloadingPlayAssetsPercent;
            }
            else
            {
              return elapsedPreloadingPlayAssets / 0.1;
            }
          }
        }
        else
        {
          if (preloadingPlayAssetsComplete) currentState = FunkinPreloaderState.InitializingScripts;
        }

        return preloadingPlayAssetsPercent;
      case FunkinPreloaderState.InitializingScripts:
        if (initializingScriptsPercent < 0.0)
        {
          initializingScriptsPercent = 0.0;

          initializingScriptsPercent = 1.0;
          currentState = FunkinPreloaderState.CachingGraphics;
          return 0.0;
        }

        return initializingScriptsPercent;
      case CachingGraphics:
        if (cachingGraphicsPercent < 0)
        {
          cachingGraphicsPercent = 0.0;
          cachingGraphicsStartTime = elapsed;

          cachingGraphicsPercent = 1.0;
          cachingGraphicsComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedCachingGraphics:Float = elapsed - cachingGraphicsStartTime;
          if (cachingGraphicsComplete && elapsedCachingGraphics >= 0.1)
          {
            currentState = FunkinPreloaderState.CachingAudio;
            return 0.0;
          }
          else
          {
            if (cachingGraphicsPercent < (elapsedCachingGraphics / 0.1))
            {
              return cachingGraphicsPercent;
            }
            else
            {
              return elapsedCachingGraphics / 0.1;
            }
          }
        }
        else
        {
          if (cachingGraphicsComplete)
          {
            currentState = FunkinPreloaderState.CachingAudio;
            return 0.0;
          }
          else
          {
            return cachingGraphicsPercent;
          }
        }

      case CachingAudio:
        if (cachingAudioPercent < 0)
        {
          cachingAudioPercent = 0.0;
          cachingAudioStartTime = elapsed;

          var assetsToCache:Array<String> = [];

          cachingAudioPercent = 1.0;
          cachingAudioComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedCachingAudio:Float = elapsed - cachingAudioStartTime;
          if (cachingAudioComplete && elapsedCachingAudio >= 0.1)
          {
            currentState = FunkinPreloaderState.CachingData;
            return 0.0;
          }
          else
          {
            if (cachingAudioPercent < (elapsedCachingAudio / 0.1))
            {
              return cachingAudioPercent;
            }
            else
            {
              return elapsedCachingAudio / 0.1;
            }
          }
        }
        else
        {
          if (cachingAudioComplete)
          {
            currentState = FunkinPreloaderState.CachingData;
            return 0.0;
          }
          else
          {
            return cachingAudioPercent;
          }
        }

      case CachingData:
        if (cachingDataPercent < 0)
        {
          cachingDataPercent = 0.0;
          cachingDataStartTime = elapsed;

          var assetsToCache:Array<String> = [];
          var sparrowFramesToCache:Array<String> = [];

          cachingDataPercent = 1.0;
          cachingDataComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedCachingData:Float = elapsed - cachingDataStartTime;

          if (cachingDataComplete && elapsedCachingData >= 0.1)
          {
            currentState = FunkinPreloaderState.ParsingSpritesheets;
            return 0.0;
          }
          else
          {
            // We need to return SIMULATED progress here.
            if (cachingDataPercent < (elapsedCachingData / 0.1))
            {
              return cachingDataPercent;
            }
            else
            {
              return elapsedCachingData / 0.1;
            }
          }
        }
        else
        {
          if (cachingDataComplete)
          {
            currentState = FunkinPreloaderState.ParsingSpritesheets;
            return 0.0;
          }
        }

        return cachingDataPercent;

      case ParsingSpritesheets:
        if (parsingSpritesheetsPercent < 0)
        {
          parsingSpritesheetsPercent = 0.0;
          parsingSpritesheetsStartTime = elapsed;

          parsingSpritesheetsPercent = 1.0;
          parsingSpritesheetsComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedParsingSpritesheets:Float = elapsed - parsingSpritesheetsStartTime;

          if (parsingSpritesheetsComplete && elapsedParsingSpritesheets >= 0.1)
          {
            currentState = FunkinPreloaderState.ParsingStages;
            return 0.0;
          }
          else
          {
            if (parsingSpritesheetsPercent < (elapsedParsingSpritesheets / 0.1))
            {
              return parsingSpritesheetsPercent;
            }
            else
            {
              return elapsedParsingSpritesheets / 0.1;
            }
          }
        }
        else
        {
          if (parsingSpritesheetsComplete)
          {
            currentState = FunkinPreloaderState.ParsingStages;
            return 0.0;
          }
        }

        return parsingSpritesheetsPercent;
      case ParsingStages:
        if (parsingStagesPercent < 0)
        {
          parsingStagesPercent = 0.0;
          parsingStagesStartTime = elapsed;

          parsingStagesPercent = 1.0;
          parsingStagesComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedParsingStages:Float = elapsed - parsingStagesStartTime;
          if (parsingStagesComplete && elapsedParsingStages >= 0.1)
          {
            currentState = FunkinPreloaderState.ParsingCharacters;
            return 0.0;
          }
          else
          {
            // We need to return SIMULATED progress here.
            if (parsingStagesPercent < (elapsedParsingStages / 0.1))
            {
              return parsingStagesPercent;
            }
            else
            {
              return elapsedParsingStages / 0.1;
            }
          }
        }
        else
        {
          if (parsingStagesComplete)
          {
            currentState = FunkinPreloaderState.ParsingCharacters;
            return 0.0;
          }
        }

        return parsingStagesPercent;

      case ParsingCharacters:
        if (parsingCharactersPercent < 0)
        {
          parsingCharactersPercent = 0.0;
          parsingCharactersStartTime = elapsed;

          parsingCharactersPercent = 1.0;
          parsingCharactersComplete = true;
          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedParsingCharacters:Float = elapsed - parsingCharactersStartTime;

          if (parsingCharactersComplete && elapsedParsingCharacters >= 0.1)
          {
            currentState = FunkinPreloaderState.ParsingSongs;
            return 0.0;
          }
          else
          {
            if (parsingCharactersPercent < (elapsedParsingCharacters / 0.1))
            {
              return parsingCharactersPercent;
            }
            else
              return elapsedParsingCharacters / 0.1;
          }
        }
        else
        {
          if (parsingStagesComplete)
          {
            currentState = FunkinPreloaderState.ParsingSongs;

            return 0.0;
          }
        }

        return parsingCharactersPercent;
      case ParsingSongs:
        if (parsingSongsPercent < 0)
        {
          parsingSongsPercent = 0.0;
          parsingSongsStartTime = elapsed;

          parsingSongsPercent = 1.0;
          parsingSongsComplete = true;

          return 0.0;
        }
        else if (0.1 > 0)
        {
          var elapsedParsingSongs:Float = elapsed - parsingSongsStartTime;
          if (parsingSongsComplete && elapsedParsingSongs >= 0.1)
          {
            currentState = FunkinPreloaderState.Complete;
            return 0.0;
          }
          else
          {
            if (parsingSongsPercent < (elapsedParsingSongs / 0.1))
            {
              return parsingSongsPercent;
            }
            else
            {
              return elapsedParsingSongs / 0.1;
            }
          }
        }
        else
        {
          if (parsingSongsComplete)
          {
            currentState = FunkinPreloaderState.Complete;
            return 0.0;
          }
          else
          {
            return parsingSongsPercent;
          }
        }
      case FunkinPreloaderState.Complete:
        if (completeTime < 0)
        {
          completeTime = elapsed;
        }

        return 1.0;
      default:
        // Do nothing.
    }

    return 0.0;
  }

  static final TOTAL_STEPS:Int = 11;
  static final ELLIPSIS_TIME:Float = 0.5;

  function updateGraphics(percent:Float, elapsed:Float):Void
  {
    // Render logo (including transitions)
    if (completeTime > 0.0)
    {
      var elapsedFinished:Float = renderLogoFadeOut(elapsed);
      if (elapsedFinished > LOGO_FADE_TIME)
      {
        immediatelyStartGame();
      }
    }
    else
    {
      renderLogoFadeIn(elapsed);

      // Render progress bar
      var maxWidth = this._width - BAR_PADDING * 2;
      var barWidth = maxWidth * percent;
      var piecesToRender:Int = Std.int(percent * progressBarPieces.length);

      for (i => piece in progressBarPieces)
      {
        piece.alpha = i <= piecesToRender ? 0.9 : 0.1;
      }
    }

    var ellipsisCount:Int = Std.int(elapsed / ELLIPSIS_TIME) % 3 + 1;
    var ellipsis:String = '';
    for (i in 0...ellipsisCount)
      ellipsis += '.';

    var percentage:Int = Math.floor(percent * 100);
    switch (currentState)
    {
      default:
        updateProgressLeftText('Loading \n0/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.DownloadingAssets:
        updateProgressLeftText('Downloading assets \n1/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.PreloadingPlayAssets:
        updateProgressLeftText('Preloading assets \n2/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.InitializingScripts:
        updateProgressLeftText('Initializing scripts \n3/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.CachingGraphics:
        updateProgressLeftText('Caching graphics \n4/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.CachingAudio:
        updateProgressLeftText('Caching audio \n5/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.CachingData:
        updateProgressLeftText('Caching data \n6/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.ParsingSpritesheets:
        updateProgressLeftText('Parsing spritesheets \n7/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.ParsingStages:
        updateProgressLeftText('Parsing stages \n8/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.ParsingCharacters:
        updateProgressLeftText('Parsing characters \n9/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.ParsingSongs:
        updateProgressLeftText('Parsing songs \n10/$TOTAL_STEPS $ellipsis');
      case FunkinPreloaderState.Complete:
        updateProgressLeftText('Finishing up \n$TOTAL_STEPS/$TOTAL_STEPS $ellipsis');
    }

    // Render percent text
    progressRightText.text = '$percentage%';

    super.update(percent);
  }

  function updateProgressLeftText(text:Null<String>):Void
  {
    if (progressLeftText != null)
    {
      if (text == null)
      {
        progressLeftText.alpha = 0.0;
      }
      else if (progressLeftText.text != text)
      {
        // We have to keep updating the text format, because the font can take a frame or two to load.
        var progressLeftTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 32, 0xFFE4D7BC, true);
        progressLeftTextFormat.align = TextFormatAlign.LEFT;
        progressLeftText.defaultTextFormat = progressLeftTextFormat;
        progressLeftText.text = text;

        dspText.defaultTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 20, 0xFF4D1818, false);
        dspText.text = 'DSP';
        dspText.textColor = 0xFF4D1818;

        fnfText.defaultTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 20, 0xFF4D1818, false);
        fnfText.text = 'MMC';
        fnfText.textColor = 0xFF4D1818;

        enhancedText.defaultTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 16, 0xFFE4D7BC, false);
        enhancedText.text = 'WORSENED';
        enhancedText.textColor = 0xFFE4D7BC;

        stereoText.defaultTextFormat = new TextFormat(Paths.font('BAUHS93.ttf'), 36, 0xFFE4D7BC, false);
        stereoText.text = 'ARTIFICIAL MONO';
      }
    }
  }

  function immediatelyStartGame():Void
  {
    _loaded = true;
  }

  /**
   * Fade out the logo.
   * @param	elapsed Elapsed time since the preloader started.
   * @return	Elapsed time since the logo started fading out.
   */
  function renderLogoFadeOut(elapsed:Float):Float
  {
    // Fade-out takes LOGO_FADE_TIME seconds.
    var elapsedFinished = elapsed - completeTime;

    logo.alpha = 1.0 - MathUtil.easeInOutCirc(elapsedFinished / LOGO_FADE_TIME);
    logo.scaleX = (1.0 - MathUtil.easeInOutCirc(elapsedFinished / LOGO_FADE_TIME)) * ratio;
    logo.scaleY = (1.0 - MathUtil.easeInOutCirc(elapsedFinished / LOGO_FADE_TIME)) * ratio;
    logo.x = (this._width - logo.width) / 2;
    logo.y = (this._height - logo.height) / 2;

    progressLeftText.alpha = logo.alpha;
    progressRightText.alpha = logo.alpha;
    box.alpha = logo.alpha;
    dspText.alpha = logo.alpha;
    fnfText.alpha = logo.alpha;
    enhancedText.alpha = logo.alpha;
    stereoText.alpha = logo.alpha;
    progressLines.alpha = logo.alpha;

    for (piece in progressBarPieces)
    {
      piece.alpha = logo.alpha;
    }

    return elapsedFinished;
  }

  function renderLogoFadeIn(elapsed:Float):Void
  {
    // Fade-in takes LOGO_FADE_TIME seconds.
    logo.alpha = MathUtil.easeInOutCirc(elapsed / LOGO_FADE_TIME);
    logo.scaleX = MathUtil.easeInOutCirc(elapsed / LOGO_FADE_TIME) * ratio;
    logo.scaleY = MathUtil.easeInOutCirc(elapsed / LOGO_FADE_TIME) * ratio;
    logo.x = (this._width - logo.width) / 2;
    logo.y = (this._height - logo.height) / 2;

    progressLeftText.alpha = logo.alpha;
    progressRightText.alpha = logo.alpha;
    box.alpha = logo.alpha;
    dspText.alpha = logo.alpha;
    fnfText.alpha = logo.alpha;
    enhancedText.alpha = logo.alpha;
    stereoText.alpha = logo.alpha;
    progressLines.alpha = logo.alpha;

    for (piece in progressBarPieces)
    {
      piece.alpha = logo.alpha;
    }
  }

  override function destroy():Void
  {
    removeChild(logo);
    logo = null;
    super.destroy();
  }

  override function onLoaded():Void
  {
    super.onLoaded();
    _loaded = false;
    downloadingAssetsComplete = true;
  }
}

enum FunkinPreloaderState
{
  /**
   * The state before downloading has begun.
   * Moves to either `DownloadingAssets` or `CachingGraphics` based on platform.
   */
  NotStarted;

  /**
   * Downloading assets.
   * On HTML5, Lime will do this for us, before calling `onLoaded`.
   * On Desktop, this step will be completed immediately, and we'll go straight to `CachingGraphics`.
   */
  DownloadingAssets;

  /**
   * Preloading play assets.
   * Loads the `manifest.json` for the `gameplay` library.
   * If we make the base preloader do this, it will download all the assets as well,
   * so we have to do it ourselves.
   */
  PreloadingPlayAssets;

  /**
   * Loading FireTongue, loading Polymod, parsing and instantiating module scripts.
   */
  InitializingScripts;

  /**
   * Loading all graphics from the `core` library to the cache.
   */
  CachingGraphics;

  /**
   * Loading all audio from the `core` library to the cache.
   */
  CachingAudio;

  /**
   * Loading all data files from the `core` library to the cache.
   */
  CachingData;

  /**
   * Parsing all XML files from the `core` library into FlxFramesCollections and caching them.
   */
  ParsingSpritesheets;

  /**
   * Parsing stage data and scripts.
   */
  ParsingStages;

  /**
   * Parsing character data and scripts.
   */
  ParsingCharacters;

  /**
   * Parsing song data and scripts.
   */
  ParsingSongs;

  /**
   * Finishing up.
   */
  Complete;
}