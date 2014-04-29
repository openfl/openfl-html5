package flash.ui;


import flash.Lib;


@:access(flash.display.Stage)
class Mouse {
	
	
	public static function hide ():Void {
		
		Lib.current.stage.__setCursorHidden (true);
		
	}
	
	
	public static function show ():Void {
		
		Lib.current.stage.__setCursorHidden (false);
		
	}
	
	
}