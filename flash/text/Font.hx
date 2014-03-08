package flash.text;


class Font {
	
	
	public var fontName:String;
	public var fontStyle:FontStyle;
	public var fontType:FontType;
	
	
	public function new () {
		
		
		
	}
	
	
	public static function registerFont (font:Class<Dynamic>) {
		
		/*var instance = cast (Type.createInstance (font, []), Font);
		
		if (instance != null) {
			
			if (Reflect.hasField (font, "resourceName")) {
				
				instance.fontName = __ofResource (Reflect.field (font, "resourceName"));
				
			}
			
			__registeredFonts.push (instance);
			
		}*/
		
	}
	
	
}