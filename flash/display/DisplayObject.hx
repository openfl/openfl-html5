package flash.display;


import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;


class DisplayObject extends EventDispatcher {
	
	
	public var alpha:Float;
	public var height (get_height, set_height):Float;
	public var filters (get_filters, set_filters):Array<BitmapFilter>;
	public var parent (default, null):DisplayObjectContainer;
	public var rotation:Float;
	public var scaleX:Float;
	public var scaleY:Float;
	public var stage (default, null):Stage;
	public var visible:Bool;
	public var width (get_width, set_width):Float;
	public var x:Float;
	public var y:Float;
	
	private var __filters:Array<BitmapFilter>;
	private var __interactive:Bool;
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
	
	
	private function __renderCanvas (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	private function __setStageReference (stage:Stage):Void {
		
		this.stage = stage;
		
		//if (__interactive) stage.__dirty = true;
		
	}
	
	
	private function __updateTransform ():Void {
		
		if (hasEventListener (Event.ENTER_FRAME)) {
			
			dispatchEvent (new Event (Event.ENTER_FRAME));
			
		}
		
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