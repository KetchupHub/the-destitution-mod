package backend;

enum Playables
{
    DEFAULT;
    BF;
    DSIDES_BF;
    PEAR;
    SPORTS;
    MARK;
    ILI;
    ARGULOW;
}

typedef PlayableJson =
{
  var gameoverChar:String;
  var gameoverTheme:String;
  var gameoverTempo:Float;
  var pause:String;
  var suffix:String;
  var freeplay:String;
}