package flash;


import flash.display.MovieClip;
import flash.display.Stage;
import haxe.Timer;
import js.html.Element;
import js.Browser;


@:access(flash.display.Stage) class Lib {
	
	
	public static var current (default, null):MovieClip;
	
	private static var __startTime:Float = Timer.stamp ();
	
	
	public static function create (width:Int, height:Int, element:Element):Void {
		
		untyped __js__ ("
			var lastTime = 0;
			var vendors = ['ms', 'moz', 'webkit', 'o'];
			for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
				window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
				window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame'] 
										   || window[vendors[x]+'CancelRequestAnimationFrame'];
			}
			
			if (!window.requestAnimationFrame)
				window.requestAnimationFrame = function(callback, element) {
					var currTime = new Date().getTime();
					var timeToCall = Math.max(0, 16 - (currTime - lastTime));
					var id = window.setTimeout(function() { callback(currTime + timeToCall); }, 
					  timeToCall);
					lastTime = currTime + timeToCall;
					return id;
				};
			
			if (!window.cancelAnimationFrame)
				window.cancelAnimationFrame = function(id) {
					clearTimeout(id);
				};
			
			window.requestAnimFrame = window.requestAnimationFrame;
		");
		
		var stage = new Stage (width, height);
		
		if (element != null) {
			
			element.appendChild (stage.__canvas);
			
		}
		
		if (current == null) {
			
			current = new MovieClip ();
			stage.addChild (current);
			
		}
		
	}
	
	
	public static function getTimer ():Int {
		
		return Std.int ((Timer.stamp () - __startTime) * 1000);
		
	}
	
	
}