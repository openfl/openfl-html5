package flash.display;


import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import js.Browser;


@:access(flash.display.Graphics)
class Shape extends DisplayObject {
	
	
	public var graphics (get, null):Graphics;
	
	private var __graphics:Graphics;
	
	
	public function new () {
		
		super ();
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		if (__graphics != null) {
			
			__graphics.__getBounds (rect, __worldTransform);
			
		}
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		if (visible && __graphics != null && __graphics.__hitTest (x, y, shapeFlag, __worldTransform)) {
			
			if (!interactiveOnly) {
				
				stack.push (this);
				
			}
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		if (__graphics != null) {
			
			__graphics.__render ();
			
			if (__graphics.__canvas != null) {
				
				var context = renderSession.context;
				
				context.globalAlpha = __worldAlpha;
				var transform = __worldTransform;
				
				if (renderSession.roundPixels) {
					
					context.setTransform (transform.a, transform.b, transform.c, transform.d, Std.int (transform.tx), Std.int (transform.ty));
					
				} else {
					
					context.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
					
				}
				
				context.drawImage (__graphics.__canvas, __graphics.__bounds.x, __graphics.__bounds.y);
				
			}
			
		}
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_graphics ():Graphics {
		
		if (__graphics == null) {
			
			__graphics = new Graphics ();
			
		}
		
		return __graphics;
		
	}
	
	
}