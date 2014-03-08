package flash.display;


class InteractiveObject extends DisplayObject {
	
	
	public var doubleClickEnabled:Bool;
	public var focusRect:Dynamic;
	public var mouseEnabled:Bool;
	public var tabEnabled:Bool;
	public var tabIndex:Int;
	
	
	public function new () {
		
		super ();
		
		mouseEnabled = true;
		
	}
	
	
}