package flash.display;


import flash.display.Stage;
import flash.errors.TypeError;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;


@:access(flash.events.Event)
@:access(flash.display.Stage)
class DisplayObject extends EventDispatcher implements IBitmapDrawable {
	
	
	private static var __instanceCount = 0;
	private static var __worldDirty = true;
	
	@:isVar public var alpha (get, set):Float;
	public var blendMode:BlendMode;
	public var cacheAsBitmap:Bool;
	public var filters (get, set):Array<BitmapFilter>;
	public var height (get, set):Float;
	public var loaderInfo:LoaderInfo;
	public var mask (get, set):DisplayObject;
	public var mouseX (get, null):Float;
	public var mouseY (get, null):Float;
	@:isVar public var name (get, set):String;
	public var parent (default, null):DisplayObjectContainer;
	@:isVar public var rotation (get, set):Float;
	public var scale9Grid:Rectangle;
	@:isVar public var scaleX (get, set):Float;
	@:isVar public var scaleY (get, set):Float;
	@:isVar public var scrollRect (get, set):Rectangle;
	public var stage (default, null):Stage;
	public var transform (get, set):Transform;
	@:isVar public var visible (get, set):Bool;
	public var width (get, set):Float;
	@:isVar public var x (get, set):Float;
	@:isVar public var y (get, set):Float;
	
	public var __worldTransform:Matrix;
	
	private var __filters:Array<BitmapFilter>;
	private var __interactive:Bool;
	private var __isMask:Bool;
	private var __mask:DisplayObject;
	private var __renderable:Bool;
	private var __rotationCache:Float;
	private var __rotationCosine:Float;
	private var __rotationSine:Float;
	private var __transform:Transform;
	private var __worldAlpha:Float;
	private var __worldAlphaChanged:Bool;
	private var __worldClip:Rectangle;
	private var __worldClipChanged:Bool;
	private var __worldTransformChanged:Bool;
	private var __worldVisible:Bool;
	private var __worldVisibleChanged:Bool;
	private var __worldZ:Int;
	
	
	private function new () {
		
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
		
		#if dom
		__worldVisible = true;
		#end
		
		name = "instance" + (++__instanceCount);
		
	}
	
	
	public override function dispatchEvent (event:Event):Bool {
		
		var result = super.dispatchEvent (event);
		
		if (event.__isCancelled) {
			
			return true;
			
		}
		
		if (event.bubbles && parent != null && parent != this) {
			
			event.eventPhase = EventPhase.BUBBLING_PHASE;
			parent.dispatchEvent (event);
			
		}
		
		return result;
		
	}
	
	
	public function getBounds (targetCoordinateSpace:DisplayObject):Rectangle {
		
		var matrix = __getTransform ();
		
		if (targetCoordinateSpace != null) {
			
			matrix = matrix.clone ();
			matrix.concat (targetCoordinateSpace.__worldTransform.clone ().invert ());
			
		}
		
		var bounds = new Rectangle ();
		__getBounds (bounds, matrix);
		
		return bounds;
		
	}
	
	
	public function getRect (targetCoordinateSpace:DisplayObject):Rectangle {
		
		// should not account for stroke widths, but is that possible?
		return getBounds (targetCoordinateSpace);
		
	}
	
	
	public function globalToLocal (pos:Point):Point {
		
		return __getTransform ().clone ().invert ().transformPoint (pos);
		
	}
	
	
	public function hitTestObject (obj:DisplayObject):Bool {
		
		return false;
		
	}
	
	
	public function hitTestPoint (x:Float, y:Float, shapeFlag:Bool = false):Bool {
		
		return false;
		
	}
	
	
	public function localToGlobal (point:Point):Point {
		
		return __getTransform ().transformPoint (point);
		
	}
	
	
	private function __broadcast (event:Event, notifyChilden:Bool):Bool {
		
		if (__eventMap != null && hasEventListener (event.type)) {
			
			var result = super.dispatchEvent (event);
			
			if (event.__isCancelled) {
				
				return true;
				
			}
			
			return result;
			
		}
		
		return false;
		
	}
	
	
	private function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		
		
	}
	
	
	private function __getInteractive (stack:Array<DisplayObject>):Void {
		
		
		
	}
	
	
	private function __getLocalBounds (rect:Rectangle):Void {
		
		
		
	}
	
	
	private function __getTransform ():Matrix {
		
		if (__worldDirty) {
			
			Lib.current.stage.__update ();
			
		}
		
		return __worldTransform;
		
	}
	
	
	private function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		return false;
		
	}
	
	
	public function __renderCanvas (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	public function __renderDOM (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	public function __renderMask (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	private function __setStageReference (stage:Stage):Void {
		
		if (this.stage != stage) {
			
			if (this.stage != null) {
				
				dispatchEvent (new Event (Event.REMOVED_FROM_STAGE, false, false));
				
			}
			
			this.stage = stage;
			
			if (stage != null) {
				
				dispatchEvent (new Event (Event.ADDED_TO_STAGE, false, false));
				
			}
			
		}
		
	}
	
	
	public function __update ():Void {
		
		__renderable = (visible && scaleX != 0 && scaleY != 0 && !__isMask);
		if (!__renderable && !__isMask) return;
		
		if (rotation != __rotationCache) {
			
			__rotationCache = rotation;
			var radians = rotation * (Math.PI / 180);
			__rotationSine = Math.sin (radians);
			__rotationCosine = Math.cos (radians);
			
		}
		
		if (parent != null) {
			
			var parentTransform = parent.__worldTransform;
			
			var a00 = __rotationCosine * scaleX,
			a01 = __rotationSine * scaleX,
			a10 = -__rotationSine * scaleY,
			a11 = __rotationCosine * scaleY,
			b00 = parentTransform.a, b01 = parentTransform.b,
			b10 = parentTransform.c, b11 = parentTransform.d;
			
			#if !dom
			
			__worldTransform.a = a00 * b00 + a01 * b10;
			__worldTransform.b = a00 * b01 + a01 * b11;
			__worldTransform.c = a10 * b00 + a11 * b10;
			__worldTransform.d = a10 * b01 + a11 * b11;
			__worldTransform.tx = x * b00 + y * b10 + parentTransform.tx;
			__worldTransform.ty = x * b01 + y * b11 + parentTransform.ty;
			
			__worldAlpha = alpha * parent.__worldAlpha;
			
			#else
			
			var cache = __worldTransform.clone ();
			__worldTransform.a = a00 * b00 + a01 * b10;
			__worldTransform.b = a00 * b01 + a01 * b11;
			__worldTransform.c = a10 * b00 + a11 * b10;
			__worldTransform.d = a10 * b01 + a11 * b11;
			__worldTransform.tx = x * b00 + y * b10 + parentTransform.tx;
			__worldTransform.ty = x * b01 + y * b11 + parentTransform.ty;
			__worldTransformChanged = !__worldTransform.equals (cache);
			
			var worldVisible = (parent.__worldVisible && visible);
			__worldVisibleChanged = (__worldVisible != worldVisible);
			__worldVisible = worldVisible;
			
			var worldAlpha = alpha * parent.__worldAlpha;
			__worldAlphaChanged = (__worldAlpha != worldAlpha);
			__worldAlpha = worldAlpha;
			
			var worldClip = null;
			if (parent.__worldClip != null) worldClip = parent.__worldClip.clone ();
			
			if (scrollRect != null) {
				
				var bounds = scrollRect.clone ();
				bounds = bounds.transform (__worldTransform);
				
				if (worldClip != null) {
					
					bounds.__contract (worldClip.x, worldClip.y, worldClip.width, worldClip.height);
					
				}
				
				worldClip = bounds;
				
			}
			
			__worldClipChanged = ((worldClip == null && __worldClip != null) || (worldClip != null && !worldClip.equals (__worldClip)));
			__worldClip = worldClip;
			
			#end
			
		} else {
			
			#if !dom
			
			__worldTransform.a = __rotationCosine * scaleX;
			__worldTransform.c = -__rotationSine * scaleY;
			__worldTransform.tx = x;
			__worldTransform.b = __rotationSine * scaleX;
			__worldTransform.d = __rotationCosine * scaleY;
			__worldTransform.ty = y;
			
			__worldAlpha = alpha;
			
			#else
			
			var cache = __worldTransform.clone ();
			__worldTransform.a = __rotationCosine * scaleX;
			__worldTransform.c = -__rotationSine * scaleY;
			__worldTransform.tx = x;
			__worldTransform.b = __rotationSine * scaleX;
			__worldTransform.d = __rotationCosine * scaleY;
			__worldTransform.ty = y;
			__worldTransformChanged = !__worldTransform.equals (cache);
			
			__worldVisibleChanged = (__worldVisible != visible);
			__worldVisible = visible;
			
			__worldAlphaChanged = (__worldAlpha != alpha);
			__worldAlpha = alpha;
			
			var worldClip = null;
			
			if (scrollRect != null) {
				
				worldClip = scrollRect.clone ().transform (__worldTransform);
				
			}
			
			__worldClipChanged = ((worldClip == null && __worldClip != null) || (worldClip != null && !worldClip.equals (__worldClip)));
			__worldClip = worldClip;
			
			#end
			
		}
		
	}
	
	
	public function __updateChildren ():Void {
		
		
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_alpha ():Float {
		
		return alpha;
		
	}
	
	
	private function set_alpha (value:Float):Float {
		
		__worldDirty = true;
		return alpha = value;
		
	}
	
	
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
		
		__worldDirty = true;
		return 0;
		
	}
	
	
	private function get_mask ():DisplayObject {
		
		return __mask;
		
	}
	
	
	private function set_mask (value:DisplayObject):DisplayObject {
		
		__worldDirty = true;
		if (__mask != null) __mask.__isMask = false;
		if (value != null) value.__isMask = true;
		return __mask = value;
		
	}
	
	
	private function get_mouseX ():Float {
		
		return globalToLocal (new Point (stage.__mouseX, 0)).x;
		
	}
	
	
	private function get_mouseY ():Float {
		
		return globalToLocal (new Point (0, stage.__mouseY)).y;
		
	}
	
	
	private function get_name ():String {
		
		return name;
		
	}
	
	
	private function set_name (value:String):String {
		
		return name = value;
		
	}
	
	
	private function get_rotation ():Float {
		
		return rotation;
		
	}
	
	
	private function set_rotation (value:Float):Float {
		
		__worldDirty = true;
		return rotation = value;
		
	}
	
	
	private function get_scaleX ():Float {
		
		return scaleX;
		
	}
	
	
	private function set_scaleX (value:Float):Float {
		
		__worldDirty = true;
		return scaleX = value;
		
	}
	
	
	private function get_scaleY ():Float {
		
		return scaleY;
		
	}
	
	
	private function set_scaleY (value:Float):Float {
		
		__worldDirty = true;
		return scaleY = value;
		
	}
	
	
	private function get_scrollRect ():Rectangle {
		
		return scrollRect;
		
	}
	
	
	private function set_scrollRect (value:Rectangle):Rectangle {
		
		#if dom
		__worldDirty = true;
		#end
		return scrollRect = value;
		
	}
	
	
	private function get_transform ():Transform {
		
		if (__transform == null) {
			
			__transform = new Transform (this);
			
		}
		
		return __transform;
		
	}
	
	
	private function set_transform (value:Transform):Transform {
		
		if (value == null) {
			
			throw new TypeError ("Parameter transform must be non-null.");
			
		}
		
		if (__transform == null) {
			
			__transform = new Transform (this);
			
		}
		
		__worldDirty = true;
		__transform.matrix = value.matrix.clone ();
		__transform.colorTransform = new ColorTransform (value.colorTransform.redMultiplier, value.colorTransform.greenMultiplier, value.colorTransform.blueMultiplier, value.colorTransform.alphaMultiplier, value.colorTransform.redOffset, value.colorTransform.greenOffset, value.colorTransform.blueOffset, value.colorTransform.alphaOffset);
		
		return __transform;
		
	}
	
	
	private function get_visible ():Bool {
		
		return visible;
		
	}
	
	
	private function set_visible (value:Bool):Bool {
		
		__worldDirty = true;
		return visible = value;
		
	}
	
	
	private function get_width ():Float {
		
		return 0;
		
	}
	
	
	private function set_width (value:Float):Float {
		
		__worldDirty = true;
		return 0;
		
	}
	
	
	private function get_x ():Float {
		
		return x;
		
	}
	
	
	private function set_x (value:Float):Float {
		
		__worldDirty = true;
		return x = value;
		
	}
	
	
	private function get_y ():Float {
		
		return y;
		
	}
	
	
	private function set_y (value:Float):Float {
		
		__worldDirty = true;
		return y = value;
		
	}
	
	
}