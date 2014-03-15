package flash.text;


import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;


@:access(flash.display.Graphics)
class TextField extends InteractiveObject {
	
	
	private static var __defaultTextFormat:TextFormat;
	
	public var antiAliasType:AntiAliasType;
	@:isVar public var autoSize (default, set):TextFieldAutoSize;
	@:isVar public var background (default, set):Bool;
	@:isVar public var backgroundColor (default, set):Int;
	@:isVar public var border (default, set):Bool;
	@:isVar public var borderColor (default, set):Int;
	public var bottomScrollV (get, null):Int;
	public var caretIndex:Int;
	public var caretPos (get, null):Int;
	public var defaultTextFormat (get, set):TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var htmlText (get, set):String;
	public var length (default, null):Int;
	public var maxChars:Int;
	public var maxScrollH (get, null):Int;
	public var maxScrollV (get, null):Int;
	public var multiline:Bool;
	public var numLines (get, null):Int;
	public var restrict:String;
	public var scrollH:Int;
	public var scrollV:Int;
	public var selectable:Bool;
	public var selectionBeginIndex:Int;
	public var selectionEndIndex:Int;
	public var sharpness:Float;
	public var text (get, set):String;
	public var textColor (get, set):Int;
	public var textHeight (get, null):Float;
	public var textWidth (get, null):Float;
	@:isVar public var type (default, set):TextFieldType;
	@:isVar public var wordWrap (default, set):Bool;
	
	private var __canvas:CanvasElement;
	private var __context:CanvasRenderingContext2D;
	private var __dirty:Bool;
	private var __height:Float;
	private var __isHTML:Bool;
	private var __text:String;
	private var __textFormat:TextFormat;
	private var __width:Float;
	
	
	public function new () {
		
		super ();
		
		__width = 100;
		__height = 100;
		__text = "";
		
		type = TextFieldType.DYNAMIC;
		autoSize = TextFieldAutoSize.NONE;
		selectable = true;
		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;
		gridFitType = GridFitType.PIXEL;
		sharpness = 0;
		
		if (__defaultTextFormat == null) {
			
			__defaultTextFormat = new TextFormat ("Times New Roman", 12, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
			__defaultTextFormat.blockIndent = 0;
			__defaultTextFormat.bullet = false;
			__defaultTextFormat.letterSpacing = 0;
			__defaultTextFormat.kerning = false;
			
		}
		
		__textFormat = __defaultTextFormat.clone ();
		
	}
	
	
	public function appendText (text:String):Void {
		
		this.text += text;
		
	}
	
	
	public function getCharBoundaries (a:Int):Rectangle {
		
		// TODO
		return null;
		
	}
	
	
	public function getCharIndexAtPoint (x:Float, y:Float):Int {
		
		return 0;
		
	}
	
	
	public function getLineIndexAtPoint (x:Float, y:Float):Int {
		
		return 0;
		
	}
	
	
	public function getTextFormat (beginIndex:Int = 0, endIndex:Int = 0):TextFormat {
		
		return __textFormat.clone ();
		
	}
	
	
	public function setSelection (beginIndex:Int, endIndex:Int) {
		
		// TODO:
		
	}
	
	
	public function setTextFormat (format:TextFormat, beginIndex:Int = 0, endIndex:Int = 0) {
		
		if (format.font != null) __textFormat.font = format.font;
		if (format.size != null) __textFormat.size = format.size;
		if (format.color != null) __textFormat.color = format.color;
		if (format.bold != null) __textFormat.bold = format.bold;
		if (format.italic != null) __textFormat.italic = format.italic;
		if (format.underline != null) __textFormat.underline = format.underline;
		if (format.url != null) __textFormat.url = format.url;
		if (format.target != null) __textFormat.target = format.target;
		if (format.align != null) __textFormat.align = format.align;
		if (format.leftMargin != null) __textFormat.leftMargin = format.leftMargin;
		if (format.rightMargin != null) __textFormat.rightMargin = format.rightMargin;
		if (format.indent != null) __textFormat.indent = format.indent;
		if (format.leading != null) __textFormat.leading = format.leading;
		if (format.blockIndent != null) __textFormat.blockIndent = format.blockIndent;
		if (format.bullet != null) __textFormat.bullet = format.bullet;
		if (format.kerning != null) __textFormat.kerning = format.kerning;
		if (format.letterSpacing != null) __textFormat.letterSpacing = format.letterSpacing;
		if (format.tabStops != null) __textFormat.tabStops = format.tabStops;
		
		__dirty = true;
		
		return __textFormat.clone ();
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		var bounds = new Rectangle (0, 0, width, height);
		bounds.transform (__worldTransform);
		
		rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		if (!visible || (interactiveOnly && !mouseEnabled)) return false;
		
		var point = globalToLocal (new Point (x, y));
		
		if (point.x > 0 && point.y > 0 && point.x <= __width && point.y <= __height) {
			
			if (stack != null) {
				
				stack.push (this);
				
			}
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		if (__dirty) {
			
			if (((__text == null || __text == "") && !background && !border) || ((width <= 0 || height <= 0) && autoSize != TextFieldAutoSize.LEFT)) {
				
				__canvas = null;
				__context = null;
				
			} else {
				
				if (__canvas == null) {
					
					__canvas = cast Browser.document.createElement ("canvas");
					__context = __canvas.getContext ("2d");
					untyped (__context).mozImageSmoothingEnabled = false;
					untyped (__context).webkitImageSmoothingEnabled = false;
					__context.imageSmoothingEnabled = false;
					
				}
				
				var font = "";
				
				if (__text != null && __text != "") {
					
					font += __textFormat.italic ? "italic " : "normal ";
					font += "normal ";
					font += __textFormat.bold ? "bold " : "normal ";
					font += __textFormat.size + "px";
					font += "/" + (__textFormat.size + __textFormat.leading + 4) + "px ";
					
					font += switch (__textFormat.font) {
						
						case "_sans": "sans-serif";
						case "_serif": "serif";
						case "_typewriter": "monospace";
						default: __textFormat.font;
						
					}
					
					__context.font = font;
					
				}
				
				if (autoSize == TextFieldAutoSize.LEFT) {
					
					if (__text != null && text != "") {
						
						__width = __context.measureText (__text).width + 4;
						
					} else {
						
						__width = 4;
						
					}
					
				}
				
				__canvas.width = Math.ceil (__width);
				__canvas.height = Math.ceil (__height);
				
				if (border || background) {
					
					if (border) {
						
						__context.lineWidth = 1;
						__context.strokeStyle = "#" + StringTools.hex (borderColor, 6);
						
					}
					
					if (background) {
						
						__context.fillStyle = "#" + StringTools.hex (backgroundColor, 6);
						
					}
					
					__context.rect (0, 0, __width, __height);
					
				}
				
				if (__text != null && __text != "") {
					
					__context.font = font;
					__context.textBaseline = "top";
					__context.fillStyle = "#" + StringTools.hex (__textFormat.color, 6);
					
					switch (__textFormat.align) {
						
						case TextFormatAlign.CENTER:
							
							__context.textAlign = "center";
							__context.fillText (__text, __width / 2, 2, __width - 4);
						
						case TextFormatAlign.RIGHT:
							
							__context.textAlign = "end";
							__context.fillText (__text, __width - 2, 2, __width - 4);
						
						default:
							
							__context.textAlign = "start";
							__context.fillText (__text, 2, 2, __width - 4);
						
					}
					
				}				
				
			}
			
			__dirty = false;
			
		}
		
		if (__canvas != null) {
			
			var context = renderSession.context;
			
			context.globalAlpha = __worldAlpha;
			var transform = __worldTransform;
			
			if (renderSession.roundPixels) {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, untyped (transform.tx || 0), untyped (transform.ty || 0));
				
			} else {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
				
			}
			
			context.drawImage (__canvas, 0, 0);
			
		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function set_autoSize (value:TextFieldAutoSize):TextFieldAutoSize {
		
		if (value != autoSize) __dirty = true;
		return autoSize = value;
		
	}
	
	
	private function set_background (value:Bool):Bool {
		
		if (value != background) __dirty = true;
		return background = value;
		
	}
	
	
	private function set_backgroundColor (value:Int):Int {
		
		if (value != backgroundColor) __dirty = true;
		return backgroundColor = value;
		
	}
	
	
	private function set_border (value:Bool):Bool {
		
		if (value != border) __dirty = true;
		return border = value;
		
	}
	
	
	private function set_borderColor (value:Int):Int {
		
		if (value != borderColor) __dirty = true;
		return borderColor = value;
		
	}
	
	
	private function get_bottomScrollV ():Int {
		
		return 0;
		
	}
	
	
	private function get_caretPos ():Int {
		
		return 0;
		
	}
	
	
	private function get_defaultTextFormat ():TextFormat {
		
		return __textFormat.clone ();
		
	}
	
	
	private function set_defaultTextFormat (value:TextFormat):TextFormat {
		
		__textFormat = __defaultTextFormat.clone ();
		setTextFormat (value);
		return value;
		
	}
	
	
	private override function get_height ():Float {
		
		return __height * scaleY;
		
	}
	
	
	private override function set_height (value:Float):Float {
		
		if (scaleY != 1 || value != __height) __dirty = true;
		scaleY = 1;
		return __height = value;
		
	}
	
	
	private function get_htmlText ():String {
		
		return __text;
		
		//return mHTMLText;
		
	}
	
	
	private function set_htmlText (value:String):String {
		
		if (!__isHTML || __text != value) __dirty = true;
		__isHTML = true;
		
		// TODO: Handle HTML text
		
		value = new EReg ("</p>", "g").replace (value, "\n");
		value = new EReg ("<br>", "g").replace (value, "\n");
		value = new EReg ("<.*?>", "g").replace (value, "");
		
		return __text = value;
		
	}
	
	
	private function get_maxScrollH ():Int { return 0; }
	private function get_maxScrollV ():Int { return 0; }
	private function get_numLines ():Int { return 0; }
	
	
	public function get_text ():String {
		
		if (__isHTML) {
			
			
			
		}
		
		return __text;
		
	}
	
	
	public function set_text (value:String):String {
		
		if (__isHTML || __text != value) __dirty = true;
		__isHTML = false;
		return __text = value;
		
	}
	
	
	public function get_textColor ():Int { 
		
		return __textFormat.color;
		
	}
	
	
	public function set_textColor (value:Int):Int {
		
		if (value != __textFormat.color) __dirty = true;
		return __textFormat.color = value;
		
	}
	
	
	public function get_textWidth ():Float { return __width - 4; }
	public function get_textHeight ():Float { return __height - 4; }
	
	
	public function set_type (value:TextFieldType):TextFieldType {
		
		//if (value != type) __dirty = true;
		return type = value;
		
	}
	
	
	override public function get_width ():Float {
		
		return __width * scaleX;
		
	}
	
	
	override public function set_width (value:Float):Float {
		
		if (scaleX != 1 || __width != value) __dirty = true;
		scaleX = 1;
		return __width = value;
		
	}
	
	
	public function set_wordWrap (value:Bool):Bool {
		
		//if (value != wordWrap) __dirty = true;
		return wordWrap = value;
		
	}
	
	
}