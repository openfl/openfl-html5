package flash.display;


import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import js.Browser;


@:access(flash.display.Graphics)
class Sprite extends DisplayObjectContainer {
	
	
	public var buttonMode:Bool;
	public var graphics (get, null):Graphics;
	
	private var __graphics:Graphics;
	
	
	public function new () {
		
		super ();
		
		//__interactive = true;
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		super.__getBounds (rect, matrix);
		
		if (__graphics != null) {
			
			__graphics.__getBounds (rect, __worldTransform);
			
		}
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		if (!visible || (interactiveOnly && !mouseEnabled)) return false;
		
		var length = 0;
		
		if (stack != null) {
			
			length = stack.length;
			
		}
		
		if (super.__hitTest (x, y, shapeFlag, stack, interactiveOnly)) {
			
			return true;
			
		} else if (__graphics != null && __graphics.__hitTest (x, y, shapeFlag, __worldTransform)) {
			
			if (stack != null) {
				
				stack.insert (length, this);
				
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
					
					context.setTransform (transform.a, transform.c, transform.b, transform.d, untyped (transform.tx || 0), untyped (transform.ty || 0));
					
				} else {
					
					context.setTransform (transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
					
				}
				
				context.drawImage (__graphics.__canvas, __graphics.__bounds.x, __graphics.__bounds.y);
				
			}
			
		}
		
		super.__renderCanvas (renderSession);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_graphics ():Graphics {
		
		if (__graphics == null) {
			
			__graphics = new Graphics ();
			
		}
		
		return __graphics;
		
	}
	
	
}