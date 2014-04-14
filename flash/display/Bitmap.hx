package flash.display;


import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;
import js.Browser;


@:access(flash.display.BitmapData)
class Bitmap extends DisplayObjectContainer {
	
	
	public var bitmapData:BitmapData;
	public var pixelSnapping:PixelSnapping;
	public var smoothing:Bool;
	
	private var __canvas:CanvasElement;
	private var __canvasContext:CanvasRenderingContext2D;
	private var __image:ImageElement;
	
	
	public function new (bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) {
		
		super ();
		
		this.bitmapData = bitmapData;
		this.pixelSnapping = pixelSnapping;
		this.smoothing = smoothing;
		
		if (pixelSnapping == null) {
			
			this.pixelSnapping = PixelSnapping.AUTO;
			
		}
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		var bounds = new Rectangle (0, 0, bitmapData.width, bitmapData.height);
		bounds = bounds.transform (__worldTransform);
		
		rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		if (!visible || bitmapData == null) return false;
		
		var point = globalToLocal (new Point (x, y));
		
		if (point.x > 0 && point.y > 0 && point.x <= bitmapData.width && point.y <= bitmapData.height) {
			
			if (stack != null) {
				
				stack.push (this);
				
			}
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		var context = renderSession.context;
		
		if (bitmapData != null && bitmapData.__valid) {
			
			if (__mask != null) {
				
				renderSession.maskManager.pushMask (__mask);
				
			}
			
			bitmapData.__syncImageData ();
			
			context.globalAlpha = __worldAlpha;
			var transform = __worldTransform;
			
			if (renderSession.roundPixels) {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, Std.int (transform.tx), Std.int (transform.ty));
				
			} else {
				
				context.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
				
			}
			
			if (!smoothing) {
				
				untyped (context).mozImageSmoothingEnabled = false;
				untyped (context).webkitImageSmoothingEnabled = false;
				context.imageSmoothingEnabled = false;
				
			}
			
			if (bitmapData.__sourceImage != null) {
				
				context.drawImage (bitmapData.__sourceImage, 0, 0);
				
			} else {
				
				context.drawImage (bitmapData.__sourceCanvas, 0, 0);
				
			}
			
			if (!smoothing) {
				
				untyped (context).mozImageSmoothingEnabled = true;
				untyped (context).webkitImageSmoothingEnabled = true;
				context.imageSmoothingEnabled = true;
				
			}
			
			if (__mask != null) {
				
				renderSession.maskManager.popMask ();
				
			}
			
		}
		
	}
	
	
	public override function __renderDOM (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		if (bitmapData != null && bitmapData.__valid) {
			
			if (bitmapData.__sourceImage != null) {
				
				__renderDOMImage (renderSession);
				
			} else {
				
				__renderDOMCanvas (renderSession);
				
			}
			
		} else {
			
			if (__image != null) {
				
				renderSession.element.removeChild (__image);
				__image = null;
				
			}
			
			if (__canvas != null) {
				
				renderSession.element.removeChild (__canvas);
				__canvas = null;
				
			}
			
		}
		
	}
	
	
	private function __renderDOMCanvas (renderSession:RenderSession):Void {
		
		if (__image != null) {
			
			renderSession.element.removeChild (__image);
			__cacheWorldTransform = null;
			__image = null;
			
		}
		
		if (__canvas == null) {
			
			__canvas = cast Browser.document.createElement ("canvas");	
			__canvasContext = __canvas.getContext ("2d");
			
			if (!smoothing) {
				
				untyped (__canvasContext).mozImageSmoothingEnabled = false;
				untyped (__canvasContext).webkitImageSmoothingEnabled = false;
				__canvasContext.imageSmoothingEnabled = false;
				
			}
			
			__canvas.style.position = "absolute";
			renderSession.element.appendChild (__canvas);
			
		}
		
		bitmapData.__syncImageData ();
		
		__canvas.width = bitmapData.width;
		__canvas.height = bitmapData.height;
		
		if (!__worldTransform.equals (__cacheWorldTransform)) {
			
			__canvas.style.setProperty (renderSession.transformProperty, __worldTransform.to3DString (renderSession.z++), null);
			__cacheWorldTransform = __worldTransform.clone ();
			
		}
		
		__canvasContext.globalAlpha = __worldAlpha;
		__canvasContext.drawImage (bitmapData.__sourceCanvas, 0, 0);
		
	}
	
	
	private function __renderDOMImage (renderSession:RenderSession):Void {
		
		if (__image == null) {
			
			__image = cast Browser.document.createElement ("img");
			__image.src = bitmapData.__sourceImage.src;
			__image.style.setProperty ("position", "absolute", null);
			__image.style.setProperty (renderSession.transformOriginProperty, "0 0 0", null);
			renderSession.element.appendChild (__image);
			
		}
		
		if (__worldAlpha != __cacheWorldAlpha) {
			
			__image.style.setProperty ("opacity", Std.string (__worldAlpha), null);
			__cacheWorldAlpha = __worldAlpha;
			
		}
		
		if (!__worldTransform.equals (__cacheWorldTransform)) {
			
			__image.style.setProperty (renderSession.transformProperty, __worldTransform.to3DString (renderSession.z++), null);
			__cacheWorldTransform = __worldTransform.clone ();
			
		}
		
	}
	
	
	public override function __renderMask (renderSession:RenderSession):Void {
		
		renderSession.context.rect (0, 0, width, height);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_height ():Float {
		
		if (bitmapData != null) {
			
			return bitmapData.height * scaleY;
			
		}
		
		return 0;
		
	}
	
	
	private override function set_height (value:Float):Float {
		
		if (bitmapData != null) {
			
			if (value != bitmapData.height) {
				
				scaleY = value / bitmapData.height;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
	private override function get_width ():Float {
		
		if (bitmapData != null) {
			
			return bitmapData.width * scaleX;
			
		}
		
		return 0;
		
	}
	
	
	private override function set_width (value:Float):Float {
		
		if (bitmapData != null) {
			
			if (value != bitmapData.width) {
				
				scaleX = value / bitmapData.width;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
}