import ::APP_MAIN_PACKAGE::::APP_MAIN_CLASS::;


import flash.display.DisplayObject;
import flash.display.Stage;
import js.Browser;


class DocumentClass extends ::APP_MAIN_CLASS:: {
	
	
	private static var __stage = new Stage (::WIN_WIDTH::, ::WIN_HEIGHT::);
	
	
	public function new () {
		
		//element = Browser.document.createElement ("div");
		
		children = new Array<DisplayObject> ();
		__stage.addChild (this);
		
		super ();
		
	}
	
	
}