package util;

import sys.thread.Thread;
import openfl.display.Bitmap;
import flixel.math.FlxRandom;
import util.macro.GitCommit;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class CoolUtil
{
  public static var appTitleString:String = "The Destitution Mod v3";

  public static var gitCommitBranch:String = GitCommit.getGitBranch();

  public static var gitCommitHash:String = GitCommit.getGitCommitHash();

  public static var lastStateScreenShot:Bitmap;

  public static var hasInitializedWindow:Bool = false;

  // using the same FlxRandom for everything can cause a lot of predictability so im not doing that anymore

  /**
   * Use for VISUALS, as in the ACTUAL ASSETS THEMSELVES, and ANIMATIONS! not POSITIONING! use the logic one for that
   */
  public static var randomVisuals:FlxRandom = new FlxRandom();

  /**
   * Use for AUDIO, and VOLUMES, and such
   */
  public static var randomAudio:FlxRandom = new FlxRandom();

  /**
   * Use for CODE STUFF, BACKEND STUFF, SECRETS, MOST RPG THINGS
   */
  public static var randomLogic:FlxRandom = new FlxRandom();

  public static function rerollRandomness()
  {
    randomVisuals.resetInitialSeed();
    randomAudio.resetInitialSeed();
    randomLogic.resetInitialSeed();
  }

  public static function newStateMemStuff(?doMem:Bool = true)
  {
    Thread.create(CoolUtil.rerollRandomness);

    if (doMem)
    {
      Thread.create(function memmyStuff()
      {
        MemoryUtil.collect(true);
        MemoryUtil.compact();
      });
    }
  }

  inline public static function quantize(f:Float, snap:Float)
  {
    var m:Float = Math.fround(f * snap);
    return (m / snap);
  }

  public static function getHolidayCharacter():String
  {
    var dayLol = Date.now();

    if (dayLol.getMonth() == 11 && (dayLol.getDate() == 24 || dayLol.getDate() == 25))
    {
      return 'christmas';
    }

    if ((dayLol.getMonth() == 0 && dayLol.getDate() == 31) || (dayLol.getMonth() == 0 && dayLol.getDate() == 1))
    {
      return 'newyear';
    }

    if ((dayLol.getMonth() == 2 && dayLol.getDate() == 17))
    {
      return 'patricks';
    }

    if ((dayLol.getMonth() == 1 && dayLol.getDate() == 14))
    {
      return 'valentines';
    }

    if ((dayLol.getMonth() == 6 && dayLol.getDate() == 4))
    {
      return 'july';
    }

    if ((dayLol.getMonth() == 9 && dayLol.getDate() == 31))
    {
      return 'halloween';
    }

    // literally every possible easter lmao
    if ((dayLol.getMonth() == 3 && (dayLol.getDate() == 20 || dayLol.getDate() == 13 || dayLol.getDate() == 6))
      || (dayLol.getMonth() == 2 && (dayLol.getDate() == 31 || dayLol.getDate() == 24)))
    {
      return 'easter';
    }

    // same for thanksgiving
    // fuck dynamic holidays
    if ((dayLol.getMonth() == 10
      && dayLol.getDay() == 4
      && (dayLol.getDate() == 22 || dayLol.getDate() == 23 || dayLol.getDate() == 24 || dayLol.getDate() == 25 || dayLol.getDate() == 26
        || dayLol.getDate() == 27 || dayLol.getDate() == 28)))
    {
      return 'thanks';
    }

    return null;
  }

  inline public static function boundTo(value:Float, min:Float, max:Float):Float
  {
    return Math.max(min, Math.min(max, value));
  }

  public static function coolTextFile(path:String):Array<String>
  {
    var daList:Array<String> = [];

    #if sys
    if (FileSystem.exists(path))
    {
      daList = File.getContent(path).trim().split('\n');
    }
    #else
    if (Assets.exists(path))
    {
      daList = Assets.getText(path).trim().split('\n');
    }
    #end

    for (i in 0...daList.length)
    {
      daList[i] = daList[i].trim();
    }

    return daList;
  }

  public static function listFromString(string:String):Array<String>
  {
    var daList:Array<String> = [];

    daList = string.trim().split('\n');

    for (i in 0...daList.length)
    {
      daList[i] = daList[i].trim();
    }

    return daList;
  }

  public static function dominantColor(sprite:FlxSprite):Int
  {
    var countByColor:Map<Int, Int> = [];

    for (col in 0...sprite.frameWidth)
    {
      for (row in 0...sprite.frameHeight)
      {
        var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);

        if (colorOfThisPixel != 0)
        {
          if (countByColor.exists(colorOfThisPixel))
          {
            countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
          }
          else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
          {
            countByColor[colorOfThisPixel] = 1;
          }
        }
      }
    }

    var maxCount = 0;
    var maxKey:Int = 0;

    countByColor[FlxColor.BLACK] = 0;

    for (key in countByColor.keys())
    {
      if (countByColor[key] >= maxCount)
      {
        maxCount = countByColor[key];
        maxKey = key;
      }
    }

    return maxKey;
  }

  public static function numberArray(max:Int, ?min = 0):Array<Int>
  {
    var dumbArray:Array<Int> = [];

    for (i in min...max)
    {
      dumbArray.push(i);
    }

    return dumbArray;
  }

  public static function precacheSound(sound:String, ?library:String = null):Void
  {
    Paths.sound(sound, library);
  }

  public static function precacheMusic(sound:String, ?library:String = null):Void
  {
    Paths.music(sound, library);
  }

  public static function browserLoad(site:String)
  {
    #if linux
    Sys.command('/usr/bin/xdg-open', [site]);
    #else
    FlxG.openURL(site);
    #end
  }

  public static function getSavePath(folder:String = 'Team-Productions-Presents'):String
  {
    @:privateAccess
    return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
      + '/'
      + FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
  }

  public static var markAscii:String = "                                                                                                                                     
                                                                                                                                     
                                                              ++++++####++++  ###                                                    
                                                      #+++++++++++++++++++++++++##                                                   
                                            ######+++++######### ####### ######++++++##                                              
                                          ####++++####################  ######   ###++++++                                           
                                        +#+++###############  ###### ######   #######  #+++++                                        
                                      +++++###############  ###### ######   ########   ###++++                                       
                                    ++++################# ############   ########   ########+++###                                   
                                   +++################# ############  ##########  ###########+++###                                  
                                 ++++######################################### ###########  ##++++#                                  
                                ++++#################################################### ######++++                                  
                              #++++#########################################++++################+++                                  
                              #+++############################### ######+++++++++++######   ###++++                                  
                              +++####################################+++++      ##+++###   ###++++  ####                             
                              +++####################################++            ++##    ##+++++   ####                            
                           ###+++##################################+++++   +++#    +++  ##+++++###    #####                          
                        ######++++###################++++#########+++++   +++++     ++ +++++++#####     ####                         
                       ########++++##############++++#   +#++++##+++     ++++++     ++ +++###########    #####                       
                     #####  ####++++###########+++          +++++++     ++++++      ++ +++############    ####                       
                    ####   #######++++++#    +++              +++++    ++++++      ++# +++#############     ###                      
                   ####   ###########++++###+++++  #+++++#    +++++#     ++       ++++  ++#############      ###                     
                  ###   ##############+++###+++#+  #++++++    +++++++            +++#   ++##############     ###                     
                 ###    ##############+++##++++    ++++++    #++##+++++        +++++    ++##############      ###                    
                ###    ###############+++##++++            ++++######++++++++++++#######++###############     ###                    
                ###   ################+++###+++++       +#+++ #######  #####    #### ###++###############      ##                    
                ##    #################++##  #+++++++++++#   ######## ##### +++++++++++++################       ##                   
               ###    #################++#########          ##############  ++++++++++++##### ############      ##                   
               ###   ############ #####++########     #### ##############   ####++####++##### ############      ##                   
               ##    ############ ######+########   ####################  #####+++###++###### ############      ###                  
               ##    ############ ######++####+++++++##################  ######++###+++############ #######     ##                   
               ##    ########### ########++#+++++++###################  #####+++###+++  ########### #######     ##                   
               ##    ########### #########+##++#++++#######################+++####+++############## #######     ##                   
               ##    #####################++######+++++#############+++++++##### ++################ #######     ##                   
               ###    #####################++#########+++++++++++++++##########+++################ ########    ##                    
               ###    ### ##################++++##############################+++++++######################   ###                    
                ##    #### ################## +++############################+++++++++####################    ###                    
                ###    ###  ################  ++++++   ####  ##############++#####+++####################     ##                     
                ###     ###  ###############+++++++++++      #########+++++#######++#####################    ###                     
                 ###    ##### ###########++++++#######+++++++ ###+++++++#########+++##################      ###                      
                  ####   #############++++++##############+++++++################+++#################      ###                       
                   ###    ###########+++++###############  ######################++################       ###                        
                    ####   ##########++++#######################################+++###############      #####                        
                      ###     #########+++######################################+++#############       ####                          
                       #####    ########+++#####################################+++##########        #####                           
                          #####     #####+++#  ############ ####################+++               ######                             
                            ########      ++++##################################+++           #########                              
                                  #####    ++++################################ +++           ######                                 
                                             ++++############################# #+++########                                          
                                               +++##############################+++########                                          
                                                #+++#############################+++#####                                            
                                                  #++############################+++##                                               
                                                   #+++###########################++#                                                
                                                    ##+++##########################                                                  
                                                      ##++++ #####################                                                   
                                                      ####++++###################                                                    
                                                           +#++   #####  ######                                                      
                                                                          ##                                                         
                                                                                                                                     
                                                                                                                                     
                                                                                                                                     
                                                                                                                                     
                                                                                                                                     ";
}