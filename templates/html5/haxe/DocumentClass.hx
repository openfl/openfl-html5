import ::APP_MAIN_PACKAGE::::APP_MAIN_CLASS::;


import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.Lib;
import js.Browser;


@:access(flash.Lib)
class DocumentClass extends ::APP_MAIN_CLASS:: {
	
	
	private static var __stage = new Stage (::WIN_WIDTH::, ::WIN_HEIGHT::);
	
	
	public function new () {
		
		//element = Browser.document.createElement ("div");
		
		children = new Array<DisplayObject> ();
		Lib.current = new MovieClip ();
		Lib.current.addChild (this);
		__stage.addChild (Lib.current);
		
		super ();
		
	}
	
	
}