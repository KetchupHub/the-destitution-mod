package shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

/**
 * shushing face
 */
class DitherShader extends FlxRuntimeShader
{
  /**
   * for shader test state, since im too dumb to know how to convert a type name to string
   */
  public var name:String = 'DitherShader';

  public var size(default, set):Float;

  public function new(theSize:Float = 1)
  {
    super(Assets.getText(Paths.frag('dither')));
    this.size = theSize;
  }

  function set_size(value:Float):Float
  {
    this.setFloat('Scale', value);
    this.size = value;

    return this.size;
  }

  public function update(elapsed:Float) {}
}