package flash.display;


import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;


class DisplayObject extends EventDispatcher {
	
	
	public var alpha:Float;
	public var blendMode:BlendMode;
	public var cacheAsBitmap:Bool;
	public var filters (get, set):Array<BitmapFilter>;
	public var height (get, set):Float;
	public var loaderInfo:LoaderInfo;
	public var mask:DisplayObject;
	public var mouseX:Float;
	public var mouseY:Float;
	public var name:String;
	public var parent (default, null):DisplayObjectContainer;
	public var rotation:Float;
	public var scale9Grid:Rectangle;
	public var scaleX:Float;
	public var scaleY:Float;
	public var scrollRect:Rectangle;
	public var stage (default, null):Stage;
	public var transform:Transform;
	public var visible:Bool;
	public var width (get, set):Float;
	public var x:Float;
	public var y:Float;
	
	private var __filters:Array<BitmapFilter>;
	private var __interactive:Bool;
	private var __renderable:Bool;
	private var __rotationCache:Float;
	private var __rotationCosine:Float;
	private var __rotationSine:Float;
	private var __worldAlpha:Float;
	private var __worldTransform:Matrix;
	
	
	public function new () {
		
		super ();
		
		alpha = 1;
		rotation = 0;
		scaleX = 1;
		scaleY = 1;
		visible = true;
		x = 0;
		y = 0;
		
		__worldAlpha = 1;
		__worldTransform = new Matrix ();
		
	}
	
	
	public function getBounds (targetCoordinateSpace:DisplayObject):Rectangle {
		
		/*if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();
		if (_boundsInvalid) validateBounds ();
		
		var m = __getFullMatrix ();
		
		// perhaps inverse should be stored and updated lazily?
		if (targetCoordinateSpace != null) {
			
			// will be null when target space is stage and this is not on stage
			m.concat(targetCoordinateSpace.__getFullMatrix ().invert ());
			
		}
		
		var rect = __boundsRect.transform (m);	// transform does cloning
		return rect;*/
		return null;
		
	}
	
	
	public function getRect (targetCoordinateSpace:DisplayObject):Rectangle {
		
		// should not account for stroke widths, but is that possible?
		return getBounds (targetCoordinateSpace);
		
	}
	
	
	public function globalToLocal (pos:Point):Point {
		
		return __worldTransform.clone ().invert ().transformPoint (pos);
		
	}
	
	
	public function hitTestObject (obj:DisplayObject):Bool {
		
		/*if (obj != null && obj.parent != null && parent != null) {
			
			var currentBounds = getBounds (this);
			var targetBounds = obj.getBounds (this);
			
			return currentBounds.intersects (targetBounds);
			
		}*/
		
		return false;
		
	}
	
	
	public function hitTestPoint (x:Float, y:Float, shapeFlag:Bool = false):Bool {
		
		/*var boundingBox = (shapeFlag == null ? true : !shapeFlag);
		
		if (!boundingBox) {
			
			return __getObjectUnderPoint (new Point (x, y)) != null;
			
		} else {
			
			var gfx = __getGraphics ();
			
			if (gfx != null) {
				
				var extX = gfx.__extent.x;
				var extY = gfx.__extent.y;
				var local = globalToLocal (new Point (x, y));
				
				if (local.x - extX < 0 || local.y - extY < 0 || (local.x - extX) * scaleX > width || (local.y - extY) * scaleY > height) {
					
					return false;
					
				} else {
					
					return true;
					
				}
				
			}
			
			return false;
			
		}*/
		
		return false;
		
	}
	
	
	public function localToGlobal (point:Point):Point {
		
		return __worldTransform.transformPoint (point);
		//if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();
		//return __getFullMatrix ().transformPoint (point);
		
	}
	
	
	private function __broadcast (event:Event):Void {
		
		if (__eventMap != null && hasEventListener (event.type)) {
			
			if (event.target == null) {
				
				event.target = this;
				
			}
			
			event.currentTarget = this;
			dispatchEvent (event);
			
		}
		
	}
	
	
	private function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		
		
	}
	
	
	private function __getLocalBounds (rect:Rectangle):Void {
		
		
		
	}
	
	
	private function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<InteractiveObject>):Bool {
		
		return false;
		
	}
	
	
	private function __renderCanvas (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	private function __setStageReference (stage:Stage):Void {
		
		if (this.stage != stage) {
			
			this.stage = stage;
			
			if (stage != null) {
				
				var evt = new Event (Event.ADDED_TO_STAGE, false, false);
				dispatchEvent (evt);
				
			}
			
		}
		
	}
	
	
	private function __update ():Void {
		
		__renderable = (visible && alpha > 0 && scaleX != 0 && scaleY != 0);
		if (!__renderable) return;
		
		if (rotation != __rotationCache) {
			
			__rotationCache = rotation;
			__rotationSine = Math.sin (rotation);
			__rotationCosine = Math.cos (rotation);
			
		}
		
		var parentTransform = parent.__worldTransform;
		var worldTransform = __worldTransform;
		
		var px = 0;
		var py = 0;
		
		var a00 = __rotationCosine * scaleX,
		a01 = -__rotationSine * scaleY,
		a10 = __rotationSine * scaleX,
		a11 = __rotationCosine * scaleY,
		a02 = x - a00 * px - py * a01,
		a12 = y - a11 * py - px * a10,
		b00 = parentTransform.a, b01 = parentTransform.b,
		b10 = parentTransform.c, b11 = parentTransform.d;

		worldTransform.a = b00 * a00 + b01 * a10;
		worldTransform.b = b00 * a01 + b01 * a11;
		worldTransform.tx = b00 * a02 + b01 * a12 + parentTransform.tx;

		worldTransform.c = b10 * a00 + b11 * a10;
		worldTransform.d = b10 * a01 + b11 * a11;
		worldTransform.ty = b10 * a02 + b11 * a12 + parentTransform.ty;
		
		__worldAlpha = alpha * parent.__worldAlpha;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_filters ():Array<BitmapFilter> {
		
		if (__filters == null) {
			
			return new Array ();
			
		} else {
			
			return __filters.copy ();
			
		}
		
	}
	
	
	private function set_filters (value:Array<BitmapFilter>):Array<BitmapFilter> {
		
		// set
		
		return value;
		
	}
	
	
	private function get_height ():Float {
		
		return 0;
		
	}
	
	
	private function set_height (value:Float):Float {
		
		return 0;
		
	}
	
	
	private function get_width ():Float {
		
		return 0;
		
	}
	
	
	private function set_width (value:Float):Float {
		
		return 0;
		
	}
	
	
}