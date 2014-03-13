package flash.text;


import flash.display.InteractiveObject;


class TextField extends InteractiveObject {
	
	
	public var antiAliasType:AntiAliasType;
	public var autoSize:TextFieldAutoSize;
	public var border:Bool;
	public var defaultTextFormat:TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var htmlText:String;
	public var multiline:Bool;
	public var numLines:Int;
	public var selectable:Bool;
	public var sharpness:Float;
	public var text:String;
	public var textColor:Int;
	public var textHeight:Float;
	public var textWidth:Float;
	public var wordWrap:Bool;
	
	
	public function new () {
		
		super ();
		
		defaultTextFormat = new TextFormat ();
		text = "";
		htmlText = "";
		
	}
	
	
	public function getTextFormat (beginIndex:Int = 0, endIndex:Int = 0):TextFormat {
		
		//return new TextFormat (mFace, mTextHeight, mTextColour);
		return new TextFormat ();
		
	}
	
	
	public function setTextFormat (inFmt:TextFormat, beginIndex:Int = 0, endIndex:Int = 0) {
		
		
		
	}
	
	
}