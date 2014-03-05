package flash.display;


import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;


class Graphics {
	
	
	private var __bounds:Rectangle;
	private var __canvas:CanvasElement;
	private var __commands:Array<DrawCommand>;
	private var __context:CanvasRenderingContext2D;
	private var __dirty:Bool;
	
	
	public function new () {
		
		__commands = new Array ();
		
	}
	
	
	public function beginFill (rgb:Int, alpha:Int = 0xFF):Void {
		
		__commands.push (BeginFill (rgb, alpha));
		
	}
	
	
	public function clear ():Void {
		
		__commands = new Array ();
		__bounds = null;
		__dirty = true;
		
	}
	
	
	public function drawCircle (x:Float, y:Float, radius:Float):Void {
		
		if (radius <= 0) return;
		
		__inflateBounds (x - radius, y - radius);
		__inflateBounds (x + radius, y + radius);
		
		__commands.push (DrawCircle (x, y, radius));
		
		__dirty = true;
		
	}
	
	
	public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
		
		if (width <= 0 || height <= 0) return;
		
		__inflateBounds (x, y);
		__inflateBounds (x + width, y + height);
		
		__commands.push (DrawRect (x, y, width, height));
		
		__dirty = true;
		
	}
	
	
	public function lineStyle (thickness:Null<Float> = null, color:Null<Int> = null, alpha:Null<Float> = null, pixelHinting:Null<Bool> = null, scaleMode:LineScaleMode = null, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Null<Float> = null):Void {
		
		__commands.push (LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit));
		
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
				
				var offsetX = __bounds.x;
				var offsetY = __bounds.y;
				
				for (command in __commands) {
					
					switch (command) {
						
						case BeginFill (rgb, alpha):
							
							if (alpha == 0xFF) {
								
								__context.fillStyle = "#" + StringTools.hex (rgb, 6);
								
							} else {
								
								var r = (rgb & 0xFF0000) >>> 16;
								var g = (rgb & 0x00FF00) >>> 8;
								var b = (rgb & 0x0000FF);
								
								__context.fillStyle = "rgba(" + r + ", " + g + ", " + b + ", " + alpha + ")";
								
							}
						
						case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
							
							__context.lineWidth = thickness;
							__context.lineJoin = joints;
							__context.lineCap = caps;
							__context.miterLimit = miterLimit;
							
							/*if (lj.grad != null) {
								
								ctx.strokeStyle = createCanvasGradient (ctx, lj.grad);
								
							} else {
								
								ctx.strokeStyle = createCanvasColor (lj.colour, lj.alpha);
								
							}*/
						
						case DrawCircle (x, y, radius):
							
							__context.beginPath();
							__context.arc (x - offsetX, y - offsetY, radius, 0, Math.PI * 2, true);
							//__context.fillStyle = "#FF0000";
							__context.fill();
							__context.closePath();
						
						case DrawRect (x, y, width, height):
							
							__context.fillRect (x - offsetX, y - offsetY, width, height);
						
					}
					
				}
				
			}
			
			__dirty = false;
			
		}
		
	}
	
	
}


enum DrawCommand {
	
	BeginFill (rgb:Int, alpha:Float);
	DrawCircle (x:Float, y:Float, radius:Float);
	DrawRect (x:Float, y:Float, width:Float, height:Float);
	LineStyle (thickness:Null<Float>, color:Null<Int>, alpha:Null<Float>, pixelHinting:Null<Bool>, scaleMode:LineScaleMode, caps:CapsStyle, joints:JointStyle, miterLimit:Null<Float>);
	
}