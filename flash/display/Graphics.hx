package flash.display;


import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;


class Graphics {
	
	
	private var __bounds:Rectangle;
	private var __canvas:CanvasElement;
	private var __commands:Array<CanvasRenderingContext2D->Float->Float->Void>;
	private var __context:CanvasRenderingContext2D;
	private var __dirty:Bool;
	
	
	public function new () {
		
		__commands = new Array ();
		
	}
	
	
	public function beginFill (rgb:Int, alpha:Int = 0xFF):Void {
		
		if (alpha == 0xFF) {
			
			__commands.push (function (c:CanvasRenderingContext2D, _, _) {
				
				c.fillStyle = "#" + StringTools.hex (rgb, 6);
				
			});
			
		} else {
			
			var r = (rgb & 0xFF0000) >>> 16;
			var g = (rgb & 0x00FF00) >>> 8;
			var b = (rgb & 0x0000FF);
			
			__commands.push (function (c:CanvasRenderingContext2D, _, _) {
				
				c.fillStyle = "rgba(" + r + ", " + g + ", " + b + ", " + alpha + ")";
				
			});
			
		}
		
	}
	
	
	public function clear ():Void {
		
		__commands = new Array ();
		__bounds = null;
		__dirty = true;
		
	}
	
	
	public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
		
		if (width == 0 || height == 0) return;
		
		__inflateBounds (x, y);
		__inflateBounds (x + width, y + height);
		
		__commands.push (function (c:CanvasRenderingContext2D, ox:Float, oy:Float) {
			
			c.fillRect (x - ox, y - oy, width, height);
			
		});
		
		__dirty = true;
		
	}
	
	
	private function __inflateBounds (x:Float, y:Float):Void {
		
		if (__bounds == null) {
			
			__bounds = new Rectangle (x, y, 0, 0);
			return;
			
		}
		
		if (x < __bounds.x) {
			
			__bounds.width += __bounds.x - x;
			__bounds.x = x;
			
		}
		
		if (y < __bounds.y) {
			
			__bounds.height += __bounds.y - y;
			__bounds.y = y;
			
		}
		
		if (x > __bounds.x + __bounds.width) {
			
			__bounds.width = x - __bounds.x;
			
		}
		
		if (y > __bounds.y + __bounds.height) {
			
			__bounds.height = y - __bounds.y;
			
		}
		
	}
	
	
	private function __render ():Void {
		
		if (__dirty) {
			
			if (__commands.length == 0) {
				
				__canvas = null;
				__context = null;
				
			} else {
				
				if (__canvas == null) {
					
					__canvas = cast Browser.document.createElement ("canvas");
					__context = __canvas.getContext ("2d");
					
				}
				
				__canvas.width = Math.round (__bounds.width);
				__canvas.height = Math.round (__bounds.height);
				
				var ox = __bounds.x;
				var oy = __bounds.y;
				
				for (command in __commands) {
					
					command (__context, ox, oy);
					
				}
				
			}
			
			__dirty = false;
			
		}
		
	}
	
	
}