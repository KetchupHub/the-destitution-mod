package backend;

import util.CoolUtil;
import flixel.util.FlxSave;

/**
 * Handles all RPG save data.
 */
class RpgPrefs
{
	/**
	 * NEVER ACCESS THIS DIRECTLY, use RpgPrefs.
	 */
	public static var rpgSave:FlxSave;

    public static var progression:Int = 0;
    
    public static var items:Array<RpgItemTypes> = [NONE, NONE, NONE, NONE, NONE, NONE];

    public static var curLocation:String = 'start';

    public static var level:Int = 1;
    public static var hp:Int = 20;
    public static var atk:Int = 4;
    public static var def:Int = 3;

    public static var armor:RpgArmorTypes = NONE;
    public static var weapon:RpgWeaponTypes = NONE;

    public static var whichSaveIsThis:Int = 1;
    
    public static function initSave(num:Int)
    {
        rpgSave = new FlxSave();
        rpgSave.bind('destimodRpgSave' + num, CoolUtil.getSavePath());
    }

    public static function prepFreshSave(num:Int)
    {
        progression = 0;
        items = [NONE, NONE, NONE, NONE, NONE, NONE];
        curLocation = 'start';
        level = 1;
        hp = 20;
        atk = 4;
        def = 3;
        armor = NONE;
        weapon = NONE;
        whichSaveIsThis = num;
    }

    public static function eraseCurSave()
    {
        rpgSave.erase();
    }

    public static function flushCurSave()
    {
        rpgSave.data.progression = progression;
        rpgSave.data.items = items;
        rpgSave.data.curLocation = curLocation;
        rpgSave.data.level = level;
        rpgSave.data.hp = hp;
        rpgSave.data.atk = atk;
        rpgSave.data.def = def;
        rpgSave.data.armor = armor;
        rpgSave.data.weapon = weapon;
        rpgSave.data.whichSaveIsThis = whichSaveIsThis;
        rpgSave.flush();
    }
}

enum RpgArmorTypes
{
    NONE;
}

enum RpgWeaponTypes
{
    NONE;
}

enum RpgItemTypes
{
    NONE;
}