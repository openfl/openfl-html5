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
	
	private var __canvasContext:CanvasRenderingContext2D;
	private var __canvasElement:CanvasElement;
	private var __imageElement:ImageElement;
	
	
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
				
				if (__imageElement == null) {
					
					__imageElement = cast Browser.document.createElement ("img");
					__imageElement.src = bitmapData.__sourceImage.src;
					__imageElement.style.position = "absolute";
					__imageElement.style.setProperty (renderSession.transformOriginProperty, "0 0 0", null);
					renderSession.element.appendChild (__imageElement);
					
				}
				
				if (__worldAlpha != __cacheWorldAlpha) {
					
					__imageElement.style.setProperty ("opacity", Std.string (__worldAlpha), null);
					__cacheWorldAlpha = __worldAlpha;
					
				}
				
				if (!__worldTransform.equals (__cacheWorldTransform)) {
					
					__imageElement.style.setProperty (renderSession.transformProperty, __worldTransform.to3DString (renderSession.z++), null);
					__cacheWorldTransform = __worldTransform.clone ();
					
				}
				
			} else {
				
				if (__imageElement != null) {
					
					renderSession.element.removeChild (__imageElement);
					__imageElement = null;
					
				}
				
				if (__canvasElement == null) {
					
					__canvasElement = cast Browser.document.createElement ("canvas");	
					__canvasContext = __canvasElement.getContext ("2d");
					
					if (!smoothing) {
						
						untyped (__canvasContext).mozImageSmoothingEnabled = false;
						untyped (__canvasContext).webkitImageSmoothingEnabled = false;
						__canvasContext.imageSmoothingEnabled = false;
						
					}
					
					__canvasElement.style.position = "absolute";
					renderSession.element.appendChild (__canvasElement);
					
				}
				
				bitmapData.__syncImageData ();
				
				__canvasElement.width = bitmapData.width;
				__canvasElement.height = bitmapData.height;
				
				__canvasContext.globalAlpha = __worldAlpha;
				var transform = __worldTransform;
				
				if (renderSession.roundPixels) {
					
					__canvasContext.setTransform (transform.a, transform.b, transform.c, transform.d, Std.int (transform.tx), Std.int (transform.ty));
					
				} else {
					
					__canvasContext.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
					
				}
				
				if (bitmapData.__sourceImage != null) {
					
					__canvasContext.drawImage (bitmapData.__sourceImage, 0, 0);
					
				} else {
					
					__canvasContext.drawImage (bitmapData.__sourceCanvas, 0, 0);
					
				}
				
			}
			
		} else {
			
			if (__imageElement != null) {
				
				renderSession.element.removeChild (__imageElement);
				__imageElement = null;
				
			}
			
			if (__canvasElement != null) {
				
				renderSession.element.removeChild (__canvasElement);
				__canvasElement = null;
				
			}
			
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