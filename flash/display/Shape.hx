package flash.display;


import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.CSSStyleDeclaration;
import js.Browser;


@:access(flash.display.Graphics)
class Shape extends DisplayObject {
	
	
	public var graphics (get, null):Graphics;
	
	private var __canvas:CanvasElement;
	private var __canvasContext:CanvasRenderingContext2D;
	private var __graphics:Graphics;
	private var __style:CSSStyleDeclaration;
	
	
	public function new () {
		
		super ();
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		if (__graphics != null) {
			
			__graphics.__getBounds (rect, __getTransform ());
			
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
		
		if (!__renderable || __worldAlpha <= 0) return;
		
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
				
				if (scrollRect == null) {
					
					context.drawImage (__graphics.__canvas, __graphics.__bounds.x, __graphics.__bounds.y);
					
				} else {
					
					context.drawImage (__graphics.__canvas, scrollRect.x, scrollRect.y, scrollRect.width, scrollRect.height, __graphics.__bounds.x, __graphics.__bounds.y, scrollRect.width, scrollRect.height);
					
				}
				
			}
			
		}
		
	}
	
	
	public override function __renderDOM (renderSession:RenderSession):Void {
		
		//if (!__renderable) return;
		
		if (stage != null && __worldVisible && __graphics != null) {
		
			if (__graphics.__dirty || __worldClipChanged || __worldAlphaChanged) {
				
				__graphics.__render ();
				
				if (__graphics.__canvas != null) {
					
					if (__canvas == null) {
						
						__canvas = cast Browser.document.createElement ("canvas");	
						__canvasContext = __canvas.getContext ("2d");
						
						__style = __canvas.style;
						__style.setProperty ("position", "absolute", null);
						__style.setProperty ("top", "0", null);
						__style.setProperty ("left", "0", null);
						__style.setProperty (renderSession.transformOriginProperty, "0 0 0", null);
						
						renderSession.element.appendChild (__canvas);
						__worldTransformChanged = true;
						
					}
					
					__canvas.width = __graphics.__canvas.width;
					__canvas.height = __graphics.__canvas.height;
					
					__canvasContext.globalAlpha = __worldAlpha;
					
					if (__worldClip == null) {
						
						__canvasContext.drawImage (__graphics.__canvas, 0, 0);
						
					} else {
						
						var clip = __worldClip.transform (__worldTransform.clone ().invert ());
						__canvasContext.drawImage (__graphics.__canvas, clip.x, clip.y, clip.width, clip.height, __graphics.__bounds.x, __graphics.__bounds.y, clip.width, clip.height);
						
					}
					
				} else {
					
					if (__canvas != null) {
						
						renderSession.element.removeChild (__canvas);
						__canvas = null;
						
					}
					
				}
				
			}
			
			if (__canvas != null) {
				
				if (__worldTransformChanged) {
					
					var transform = new Matrix ();
					transform.translate (__graphics.__bounds.x, __graphics.__bounds.y);
					transform = transform.mult (__worldTransform);
					
					__style.setProperty (renderSession.transformProperty, transform.to3DString (renderSession.roundPixels), null);
					
				}
				
				if (__worldZ != ++renderSession.z) {
					
					__worldZ = renderSession.z;
					__style.setProperty ("z-index", Std.string (__worldZ), null);
					
				}
				
				__canvasContext.globalAlpha = __worldAlpha;
				
			}
				
		} else {
			
			if (__canvas != null) {
				
				renderSession.element.removeChild (__canvas);
				__canvas = null;
				__style = null;
				
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