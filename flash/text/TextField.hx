package flash.text;


import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;
import haxe.xml.Fast;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.DivElement;
import js.Browser;


@:access(flash.display.Graphics)
@:access(flash.text.TextFormat)
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
	@:isVar public var wordWrap (get, set):Bool;
	
	private var __canvas:CanvasElement;
	private var __context:CanvasRenderingContext2D;
	private var __dirty:Bool;
	private var __div:DivElement;
	//private var __graphics:Graphics;
	private var __height:Float;
	private var __isHTML:Bool;
	private var __ranges:Array<TextFormatRange>;
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
		//__graphics = new Graphics ();
		
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
	
	
	public function setTextFormat (format:TextFormat, beginIndex:Int = 0, endIndex:Int = 0):Void {
		
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
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		var bounds = new Rectangle (0, 0, __width, __height);
		bounds.transform (__worldTransform);
		
		rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
		
	}
	
	
	private function __getFont (format:TextFormat):String {
		
		var font = format.italic ? "italic " : "normal ";
		font += "normal ";
		font += format.bold ? "bold " : "normal ";
		font += format.size + "px";
		font += "/" + (format.size + format.leading + 4) + "px ";
		
		font += switch (format.font) {
			
			case "_sans": "sans-serif";
			case "_serif": "serif";
			case "_typewriter": "monospace";
			default: format.font;
			
		}
		
		return font;
		
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
	
	
	private function __measureText ():Array<Float> {
		
		if (__ranges == null) {
			
			__context.font = __getFont (__textFormat);
			return [ __context.measureText (__text).width ];
			
		} else {
			
			var measurements = [];
			
			for (range in __ranges) {
				
				__context.font = __getFont (range.format);
				measurements.push (__context.measureText (text.substring (range.start, range.end)).width);
				
			}
			
			return measurements;
			
		}
		
	}
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		if (__dirty) {
			
			if (((__text == null || __text == "") && !background && !border) || ((width <= 0 || height <= 0) && autoSize != TextFieldAutoSize.LEFT)) {
				
				__canvas = null;
				__context = null;
				//__graphics.clear ();
				
			} else {
				
				//var font = new Font ();
				//trace (font.hasGlyph ("a"));
				//__graphics.beginFill (0xFF0000);
				//font.__setScale (20);
				//font.__render (__graphics, "a".charCodeAt (0), 0, 0, false);
				//__graphics.endFill ();
				
				//__graphics.beginFill (0xFF0000);
				//__graphics.drawRect (0, 0, 100, 100);
				
				if (__canvas == null) {
					
					__canvas = cast Browser.document.createElement ("canvas");
					__context = __canvas.getContext ("2d");
					//untyped (__context).mozImageSmoothingEnabled = false;
					//untyped (__context).webkitImageSmoothingEnabled = false;
					//__context.imageSmoothingEnabled = false;
					
				}
				
				if (__text != null && __text != "") {
					
					var measurements = __measureText ();
					var textWidth = 0.0;
					
					for (measurement in measurements) {
						
						textWidth += measurement;
						
					}
					
					if (autoSize == TextFieldAutoSize.LEFT) {
						
						__width = textWidth + 4;
						
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
					
					if (__ranges == null) {
						
						__renderText (text, __textFormat, 0);
						
					} else {
						
						var currentIndex = 0;
						var range;
						var offsetX = 0.0;
						
						for (i in 0...__ranges.length) {
							
							range = __ranges[i];
							
							__renderText (text.substring (range.start, range.end), range.format, offsetX);
							offsetX += measurements[i];
							
						}
						
					}
					
				} else {
					
					if (autoSize == TextFieldAutoSize.LEFT) {
						
						__width = 4;
						
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
					
				}
				
			}
			
			//__graphics.__render ();
			
			__dirty = false;
			
		}
		
		if (__canvas != null) {
		//if (__graphics.__canvas != null) {
			
			var context = renderSession.context;
			
			context.globalAlpha = __worldAlpha;
			var transform = __worldTransform;
			
			if (renderSession.roundPixels) {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, Std.int (transform.tx), Std.int (transform.ty));
				
			} else {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
				
			}
			
			//context.drawImage (__graphics.__canvas, __graphics.__bounds.x, __graphics.__bounds.y);
			context.drawImage (__canvas, 0, 0);
			
		}
		
	}
	
	
	public override function __renderDOM (renderSession:RenderSession):Void {
		
		//if (!__renderable) return;
		
		if (stage != null && visible) {
		
			if (__dirty) {
				
				if (__text != "") {
					
					if (__div == null) {
						
						__div = cast Browser.document.createElement ("div");
						
						var style = __div.style;
						style.position = "absolute";
						style.setProperty ("top", "0", null);
						style.setProperty ("left", "0", null);
						style.setProperty (renderSession.transformOriginProperty, "0 0 0", null);
						style.setProperty ("cursor", "inherit", null);
						
						renderSession.element.appendChild (__div);
						
					}
					
					// TODO: Handle ranges using span
					// TODO: Vertical align
					
					__div.innerHTML = __text;
					
					var style = __div.style;
					style.setProperty ("font", __getFont (__textFormat), null);
					style.setProperty ("color", "#" + StringTools.hex (__textFormat.color, 6), null);
					
					if (autoSize != TextFieldAutoSize.NONE) {
						
						style.setProperty ("width", "auto", null);
						
					} else {
						
						style.setProperty ("width", __width + "px", null);
						
					}
					
					style.setProperty ("height", __height + "px", null);
					
					switch (__textFormat.align) {
						
						case TextFormatAlign.CENTER:
							
							style.setProperty ("text-align", "center", null);
						
						case TextFormatAlign.RIGHT:
							
							style.setProperty ("text-align", "right", null);
						
						default:
							
							style.setProperty ("text-align", "left", null);
						
					}
					
					style.setProperty ("opacity", Std.string (__worldAlpha), null);
					style.setProperty (renderSession.transformProperty, __worldTransform.to3DString (renderSession.z++), null);
					
					__dirty = false;
					
				} else {
					
					if (__div != null) {
						
						renderSession.element.removeChild (__div);
						__div = null;
						
					}
					
				}
				
			}
			
		} else {
			
			if (__div != null) {
				
				renderSession.element.removeChild (__div);
				__div = null;
				
			}
			
		}
		
	}
	
	
	private function __renderText (text:String, format:TextFormat, offsetX:Float):Void {
		
		__context.font = __getFont (format);
		__context.textBaseline = "top";
		__context.fillStyle = "#" + StringTools.hex (format.color, 6);
		
		switch (format.align) {
			
			case TextFormatAlign.CENTER:
				
				__context.textAlign = "center";
				__context.fillText (text, __width / 2, 2, __width - 4);
			
			case TextFormatAlign.RIGHT:
				
				__context.textAlign = "end";
				__context.fillText (text, __width - 2, 2, __width - 4);
			
			default:
				
				__context.textAlign = "start";
				__context.fillText (text, 2 + offsetX, 2, __width - 4);
			
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
		__textFormat.__merge (value);
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
		__ranges = null;
		__isHTML = true;
		
		value = new EReg ("<br>", "g").replace (value, "\n");
		value = new EReg ("<br/>", "g").replace (value, "\n");
		
		// crude solution
		
		var segments = value.split ("<font");
		
		if (segments.length == 1) {
			
			value = new EReg ("<.*?>", "g").replace (value, "");
			return __text = value;
			
		} else {
			
			value = "";
			__ranges = [];
			
			// crude search for font
			
			for (segment in segments) {
				
				if (segment == "") continue;
				
				var closeFontIndex = segment.indexOf ("</font>");
				
				if (closeFontIndex > -1) {
					
					var start = segment.indexOf (">") + 1;
					var end = closeFontIndex;
					var format = __textFormat.clone ();
					
					var faceIndex = segment.indexOf ("face=");
					var colorIndex = segment.indexOf ("color=");
					var sizeIndex = segment.indexOf ("size=");
					
					if (faceIndex > -1 && faceIndex < start) {
						
						format.font = segment.substr (faceIndex + 6, segment.indexOf ("\"", faceIndex));
						
					}
					
					if (colorIndex > -1 && colorIndex < start) {
						
						format.color = Std.parseInt ("0x" + segment.substr (colorIndex + 8, 6));
						
					}
					
					if (sizeIndex > -1 && sizeIndex < start) {
						
						format.size = Std.parseInt (segment.substr (sizeIndex + 6, segment.indexOf ("\"", sizeIndex)));
						
					}
					
					var sub = segment.substring (start, end);
					sub = new EReg ("<.*?>", "g").replace (sub, "");
					
					__ranges.push (new TextFormatRange (format, value.length, value.length + sub.length));
					value += sub;
					
					if (closeFontIndex + 7 < segment.length) {
						
						sub = segment.substr (closeFontIndex + 7);
						__ranges.push (new TextFormatRange (__textFormat, value.length, value.length + sub.length));
						value += sub;
						
					}
					
				} else {
					
					__ranges.push (new TextFormatRange (__textFormat, value.length, value.length + segment.length));
					value += segment;
					
				}
				
			}
			
		}
		
		
		// crude
		
		/*var segments = value.split ("<");
		var format = __textFormat;
		var rangeFormat = null;
		
		for (segment in segments) {
			
			if (segment != "") {
				
				var caretIndex = segment.indexOf (">");
				
				if (caretIndex > -1) {
					
					if (StringTools.startsWith (segment, "font ")) {
						
						// parse font
						rangeFormat = format.clone ();
						rangeFormat.color = 0xFF0000;
						
					}
					
				}
				
				if (segment.indexOf (">") > )
				
			}
			
		}*/
		
		
		
		/*value = new EReg ("</p>", "g").replace (value, "\n");
		value = new EReg ("<br>", "g").replace (value, "\n");
		value = new EReg ("<.*?>", "g").replace (value, "");
		
		var first = Math.floor (value.length / 2);
		var format = __textFormat.clone ();
		format.color = 0xFF00FF;
		
		__ranges = [ new TextFormatRange (__textFormat, 0, first), new TextFormatRange (format, first, value.length) ];
		*/
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
		__ranges = null;
		__isHTML = false;
		return __text = value;
		
	}
	
	
	public function get_textColor ():Int { 
		
		return __textFormat.color;
		
	}
	
	
	public function set_textColor (value:Int):Int {
		
		if (value != __textFormat.color) __dirty = true;
		
		if (__ranges != null) {
			
			for (range in __ranges) {
				
				range.format.color = null;
				
			}
			
		}
		
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
	
	
	public function get_wordWrap ():Bool {
		
		return wordWrap;
		
	}
	
	
	public function set_wordWrap (value:Bool):Bool {
		
		//if (value != wordWrap) __dirty = true;
		return wordWrap = value;
		
	}
	
	
}


class TextFormatRange {
	
	
	public var end:Int;
	public var format:TextFormat;
	public var start:Int;
	
	
	public function new (format:TextFormat, start:Int, end:Int) {
		
		this.format = format;
		this.start = start;
		this.end = end;
		
	}
	
	
}