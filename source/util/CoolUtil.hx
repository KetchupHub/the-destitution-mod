package util;

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

	inline public static function quantize(f:Float, snap:Float)
	{
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
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
		for(col in 0...sprite.frameWidth)
		{
			for(row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0)
				{
					if(countByColor.exists(colorOfThisPixel))
					{
				    	countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  	}
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		
		var maxCount = 0;
		var maxKey:Int = 0;

		countByColor[FlxColor.BLACK] = 0;

		for(key in countByColor.keys())
		{
			if(countByColor[key] >= maxCount)
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

	public static function getSavePath(folder:String = 'Team-Productions-Presents'):String {
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