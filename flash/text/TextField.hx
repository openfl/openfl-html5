package flash.text;


import flash.display.InteractiveObject;


class TextField extends InteractiveObject {
	
	
	public var antiAliasType:AntiAliasType;
	public var autoSize:TextFieldAutoSize;
	public var defaultTextFormat:TextFormat;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var selectable:Bool;
	public var sharpness:Float;
	public var text:String;
	public var textColor:Int;
	
	
	public function new () {
		
		super ();
		
		defaultTextFormat = new TextFormat ();
		
	}
	
	
}