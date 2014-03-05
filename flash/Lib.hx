package flash;


import flash.display.MovieClip;
import haxe.Timer;


class Lib {
	
	
	public static var current (default, null):MovieClip;
	
	private static var __startTime:Float = Timer.stamp ();
	
	
	public static function getTimer ():Int {
		
		return Std.int ((Timer.stamp () - __startTime) * 1000);
		
	}
	
	
}