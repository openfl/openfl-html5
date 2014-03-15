package flash.display;


import flash.events.Event;
import flash.events.EventPhase;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.ui.KeyLocation;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.HtmlElement;
import js.Browser;


@:access(flash.events.Event)
class Stage extends Sprite {
	
	
	public var align:StageAlign;
	public var color (get, set):Int;
	public var displayState:StageDisplayState;
	public var focus:InteractiveObject;
	public var frameRate:Float;
	public var scaleMode:StageScaleMode;
	public var stageHeight (default, null):Int;
	public var stageWidth (default, null):Int;
	
	private var __canvas:CanvasElement;
	private var __clearBeforeRender:Bool;
	private var __color:Int;
	private var __colorString:String;
	private var __context:CanvasRenderingContext2D;
	private var __cursor:String;
	private var __element:HtmlElement;
	private var __eventQueue:Array<js.html.Event>;
	private var __fullscreen:Bool;
	private var __mouseX:Float = 0;
	private var __mouseY:Float = 0;
	private var __originalWidth:Int;
	private var __originalHeight:Int;
	private var __renderSession:RenderSession;
	private var __stack:Array<DisplayObject>;
	#if stats
	private var __stats:Dynamic;
	#end
	private var __transparent:Bool;
	
	
	
	public function new (width:Int, height:Int, element:HtmlElement = null, color:Int = 0xFFFFFF) {
		
		super ();
		
		__mouseX = 0;
		__mouseY = 0;
		
		__canvas = cast Browser.document.createElement ("canvas");
		
		__context = untyped __js__ ('this.__canvas.getContext ("2d", { alpha: false })');
		untyped (__context).mozImageSmoothingEnabled = false;
		untyped (__context).webkitImageSmoothingEnabled = false;
		__context.imageSmoothingEnabled = false;
		
		__canvas.style.transform = "translatez(0)";
		__canvas.style.position = "absolute";
		__canvas.style.top = "0px";
		__canvas.style.left = "0px";
		
		__originalWidth = width;
		__originalHeight = height;
		
		if (width == 0 && height == 0) {
			
			if (element != null) {
				
				width = element.clientWidth;
				height = element.clientHeight;
				
			} else {
				
				width = Browser.window.innerWidth;
				height = Browser.window.innerHeight;
				
			}
			
			__fullscreen = true;
			
		}
		
		stageWidth = width;
		stageHeight = height;
		__canvas.width = width;
		__canvas.height = height;
		
		this.__element = element;
		this.color = color;
		
		__resize ();
		Browser.window.addEventListener ("resize", window_onResize);
		
		if (element != null) {
			
			element.appendChild (__canvas);
			
		}
		
		this.stage = this;
		this.parent = this;
		
		__clearBeforeRender = true;
		__eventQueue = [];
		__stack = [];
		
		__renderSession = new RenderSession ();
		__renderSession.context = __context;
		__renderSession.roundPixels = true;
		
		#if stats
		__stats = untyped __js__("new Stats ()");
		__stats.domElement.style.position = "absolute";
		__stats.domElement.style.top = "0px";
		Browser.document.body.appendChild (__stats.domElement);
		#end
		
		var windowEvents = [ "keydown", "keyup" ];
		var canvasEvents = [ "touchstart", "touchmove", "touchend", "mousedown", "mousemove", "mouseup", "click", "dblclick" ];
		
		for (event in windowEvents) {
			
			Browser.window.addEventListener (event, __queueEvent, false);
			
		}
		
		for (event in canvasEvents) {
			
			__canvas.addEventListener (event, __queueEvent, true);
			
		}
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	public override function globalToLocal (pos:Point):Point {
		
		return pos;
		
	}
	
	
	public override function localToGlobal (pos:Point):Point {
		
		return pos;
		
	}
	
	
	private function __fireEvent (event:Event, stack:Array<DisplayObject>):Void {
		
		var l = stack.length;
		
		if (l > 0) {
			
			// First, the "capture" phase ...
			event.eventPhase = EventPhase.CAPTURING_PHASE;
			stack.reverse ();
			event.target = stack[0];
			
			for (obj in stack) {
				
				event.currentTarget = obj;
				obj.dispatchEvent (event);
				
				if (event.__isCancelled) {
					
					return;
					
				}
				
			}
			
		}
		
		// Next, the "target"
		event.eventPhase = EventPhase.AT_TARGET;
		event.currentTarget = this;
		dispatchEvent (event);
		
		if (event.__isCancelled) {
			
			return;
			
		}
		
		// Last, the "bubbles" phase
		if (event.bubbles) {
			
			event.eventPhase = EventPhase.BUBBLING_PHASE;
			stack.reverse ();
			
			for (obj in stack) {
				
				event.currentTarget = obj;
				obj.dispatchEvent (event);
				
				if (event.__isCancelled) {
					
					return;
					
				}
				
			}
			
		}
		
	}
	
	
	private function __queueEvent (event:js.html.Event):Void {
		
		__eventQueue.push (event);
		
	}
	
	
	private function __render ():Void {
		
		#if stats
		__stats.begin ();
		#end
		
		__renderable = true;
		__update ();
		
		var event = new Event (Event.ENTER_FRAME);
		__broadcast (event);
		
		super.__update ();
		
		if (stageWidth != __canvas.width || stageHeight != __canvas.height) {
			
			__canvas.width = stageWidth;
			__canvas.height = stageHeight;
			
		}
		
		__context.setTransform (1, 0, 0, 1, 0, 0);
		__context.globalAlpha = 1;
		
		if (!__transparent && __clearBeforeRender) {
			
			__context.fillStyle = __colorString;
			__context.fillRect (0, 0, stageWidth, stageHeight);
			
		} else if (__transparent && __clearBeforeRender) {
			
			__context.clearRect (0, 0, stageWidth, stageHeight);
			
		}
		
		__renderCanvas (__renderSession);
		
		/*// run interaction!
		if(stage.interactive) {
			
			//need to add some events!
			if(!stage._interactiveEventsAdded) {
				
				stage._interactiveEventsAdded = true;
				stage.interactionManager.setTarget(this);
				
			}
			
		}

		// remove frame updates..
		if(PIXI.Texture.frameUpdates.length > 0) {
			
			PIXI.Texture.frameUpdates.length = 0;
			
		}*/
		
		#if stats
		__stats.end ();
		#end
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	private function __resize ():Void {
		
		if (__element != null) {
			
			if (__fullscreen) {
				
				stageWidth = __element.clientWidth;
				stageHeight = __element.clientHeight;
				__canvas.width = stageWidth;
				__canvas.height = stageHeight;
				
			} else {
				
				var scaleX = __element.clientWidth / __originalWidth;
				var scaleY = __element.clientHeight / __originalHeight;
				
				var currentRatio = scaleX / scaleY;
				var targetRatio = Math.min (scaleX, scaleY);
				
				__canvas.style.width = __originalWidth * targetRatio + "px";
				__canvas.style.height = __originalHeight * targetRatio + "px";
				__canvas.style.marginLeft = ((__element.clientWidth - (__originalWidth * targetRatio)) / 2) + "px";
				__canvas.style.marginTop = ((__element.clientHeight - (__originalHeight * targetRatio)) / 2) + "px";
				
			}
			
		}
		
	}
	
	
	private function __setCursor (cursor:String):Void {
		
		if (__cursor != cursor) {
			
			__canvas.style.cursor = __cursor = cursor;
			
		}
		
	}
	
	
	public override function __update ():Void {
		
		super.__update ();
		
		for (event in __eventQueue) {
			
			switch (event.type) {
				
				case "keydown", "keyup": window_onKey (cast event);
				case "touchstart", "touchend", "touchmove": canvas_onTouch (cast event);
				case "mousedown", "mouseup", "mousemove", "click", "dblclick": canvas_onMouse (cast event);
				default:
				
			}
			
		}
		
		untyped __eventQueue.length = 0;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_mouseX ():Float {
		
		return __mouseX;
		
	}
	
	
	private override function get_mouseY ():Float {
		
		return __mouseY;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function canvas_onTouch (event:js.html.TouchEvent):Void {
		
		event.preventDefault ();
		
		var rect = __canvas.getBoundingClientRect ();
		var touch = event.changedTouches[0];
		var point = new Point (touch.pageX - rect.left, touch.pageY - rect.top);
		
		__mouseX = point.x;
		__mouseY = point.y;
		
		__stack = [];
		
		var type = null;
		var mouseType = null;
		
		switch (event.type) {
			
			case "touchstart":
				
				type = TouchEvent.TOUCH_BEGIN;
				mouseType = MouseEvent.MOUSE_DOWN;
			
			case "touchmove":
				
				type = TouchEvent.TOUCH_MOVE;
				mouseType = MouseEvent.MOUSE_MOVE;
			
			case "touchend":
				
				type = TouchEvent.TOUCH_END;
				mouseType = MouseEvent.MOUSE_UP;
			
			default:
			
		}
		
		if (__hitTest (mouseX, mouseY, false, __stack, true)) {
			
			var target = __stack[__stack.length - 1];
			var localPoint = target.globalToLocal (point);
			
			var touchEvent = TouchEvent.__create (type, event, touch, localPoint, cast target);
			touchEvent.touchPointID = touch.identifier;
			//touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
			touchEvent.isPrimaryTouchPoint = true;
			
			__fireEvent (touchEvent, __stack);
			__fireEvent (MouseEvent.__create (mouseType, cast event, localPoint, cast target), __stack);
			
		} else {
			
			var touchEvent = TouchEvent.__create (type, event, touch, point, this);
			touchEvent.touchPointID = touch.identifier;
			//touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
			touchEvent.isPrimaryTouchPoint = true;
			
			__fireEvent (touchEvent, [ this ]);
			__fireEvent (MouseEvent.__create (mouseType, cast event, point, this), [ this ]);
			
		}
		
		/*case "touchstart":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = new TouchInfo ();
				__touchInfo[evt.changedTouches[0].identifier] = touchInfo;
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_BEGIN, touchInfo, false);
			
			case "touchmove":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = __touchInfo[evt.changedTouches[0].identifier];
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_MOVE, touchInfo, true);
			
			case "touchend":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = __touchInfo[evt.changedTouches[0].identifier];
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_END, touchInfo, true);
				__touchInfo[evt.changedTouches[0].identifier] = null;
				
				
				var rect:Dynamic = untyped Lib.mMe.__scr.getBoundingClientRect ();
		var point : Point = untyped new Point (touch.pageX - rect.left, touch.pageY - rect.top);
		var obj = __getObjectUnderPoint (point);
		
		// used in drag implementation
		_mouseX = point.x;
		_mouseY = point.y;
		
		var stack = new Array<InteractiveObject> ();
		if (obj != null) obj.__getInteractiveObjectStack (stack);
		
		if (stack.length > 0) {
			
			//var obj = stack[0];
			
			stack.reverse ();
			var local = obj.globalToLocal (point);
			var evt = TouchEvent.__create (type, event, touch, local, cast obj);
			
			evt.touchPointID = touch.identifier;
			evt.isPrimaryTouchPoint = isPrimaryTouchPoint;
			
			__checkInOuts (evt, stack, touchInfo);
			obj.__fireEvent (evt);
			
			var mouseType = switch (type) {
				
				case TouchEvent.TOUCH_BEGIN: MouseEvent.MOUSE_DOWN;
				case TouchEvent.TOUCH_END: MouseEvent.MOUSE_UP;
				default: 
					
					if (__dragObject != null) {
						
						__drag (point);
						
					}
					
					MouseEvent.MOUSE_MOVE;
				
			}
			
			obj.__fireEvent (MouseEvent.__create (mouseType, cast evt, local, cast obj));
			
		} else {
			
			var evt = TouchEvent.__create (type, event, touch, point, null);
			evt.touchPointID = touch.identifier;
			evt.isPrimaryTouchPoint = isPrimaryTouchPoint;
			__checkInOuts (evt, stack, touchInfo);
			
		}*/
		
	}
	
	
	private function canvas_onMouse (event:js.html.MouseEvent):Void {
		
		var rect = __canvas.getBoundingClientRect ();
		
		__mouseX = (event.clientX - rect.left) * (__canvas.width / rect.width);
		__mouseY = (event.clientY - rect.top) * (__canvas.height / rect.height);
		
		__stack = [];
		
		var type = switch (event.type) {
			
			case "mousedown": MouseEvent.MOUSE_DOWN;
			case "mouseup": MouseEvent.MOUSE_UP;
			case "mousemove": MouseEvent.MOUSE_MOVE;
			case "click": MouseEvent.CLICK;
			case "dblclick": MouseEvent.DOUBLE_CLICK;
			default: null;
			
		}
		
		if (__hitTest (mouseX, mouseY, false, __stack, true)) {
			
			var target = __stack[__stack.length - 1];
			__setCursor (untyped (target).buttonMode ? "pointer" : "default");
			__fireEvent (MouseEvent.__create (type, event, target.globalToLocal (new Point (mouseX, mouseY)), cast target), __stack);
			
		} else {
			
			__setCursor (buttonMode ? "pointer" : "default");
			__fireEvent (MouseEvent.__create (type, event, new Point (mouseX, mouseY), this), [ this ]);
			
		}
		
		
		/*case "mousemove":
				
				__onMouse (cast evt, MouseEvent.MOUSE_MOVE);
			
			case "mousedown":
				
				__onMouse (cast evt, MouseEvent.MOUSE_DOWN);
			
			case "mouseup":
				
				__onMouse (cast evt, MouseEvent.MOUSE_UP);
				
				
				
				var rect:Dynamic = untyped Lib.mMe.__scr.getBoundingClientRect ();
		var point:Point = untyped new Point (event.clientX - rect.left, event.clientY - rect.top);
		
		if (__dragObject != null) {
			
			__drag (point);
			
		}
		
		var obj = __getObjectUnderPoint (point);
		
		// used in drag implementation
		_mouseX = point.x;
		_mouseY = point.y;
		
		var stack = new Array<InteractiveObject> ();
		if (obj != null) obj.__getInteractiveObjectStack (stack);
		
		if (stack.length > 0) {
			
			//var global = obj.localToGlobal(point);
			//var obj = stack[0];
			
			stack.reverse ();
			var local = obj.globalToLocal (point);
			var evt = MouseEvent.__create (type, event, local, cast obj);
			
			__checkInOuts (evt, stack);
			
			// MOUSE_DOWN brings focus to the clicked object, and takes it
			// away from any currently focused object
			if (type == MouseEvent.MOUSE_DOWN) {
				
				__onFocus (stack[stack.length - 1]);
				
			}
			
			obj.__fireEvent (evt);
			
		} else {
			
			var evt = MouseEvent.__create (type, event, point, null);
			__checkInOuts (evt, stack);
			
		}*/
		
	}
	
	
	private function window_onKey (event:js.html.KeyboardEvent):Void {
		
		var keyCode = (event.keyCode != null ? event.keyCode : event.which);
		keyCode = Keyboard.__convertMozillaCode (keyCode);
		
		dispatchEvent (new KeyboardEvent (event.type == "keydown" ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP, true, false, event.charCode, keyCode, event.keyLocation != null ? cast (event.keyLocation, KeyLocation) : KeyLocation.STANDARD, event.ctrlKey, event.altKey, event.shiftKey));
		
	}
	
	
	private function window_onResize (event:js.html.Event):Void {
		
		__resize ();
		
		var event = new Event (Event.RESIZE);
		__broadcast (event);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_color ():Int {
		
		return __color;
		
	}
	
	
	private function set_color (value:Int):Int {
		
		//this.backgroundColorSplit = PIXI.hex2rgb(this.backgroundColor);
		//var hex = this.backgroundColor.toString (16);
		//hex = '000000'.substr(0, 6 - hex.length) + hex;
		__colorString = "#" + StringTools.hex (value, 6);
		
		return __color = value;
		
	}
	
	
}


class RenderSession {
	
	
	public var context:CanvasRenderingContext2D;
	//public var mask:Bool;
	public var maskManager:MaskManager;
	//public var scaleMode:ScaleMode;
	public var roundPixels:Bool;
	//public var smoothProperty:Null<Bool> = null;
	
	
	public function new () {
		
		maskManager = new MaskManager (this);
		
	}
	
	
}


class MaskManager {
	
	
	private var renderSession:RenderSession;
	
	
	public function new (renderSession:RenderSession) {
		
		this.renderSession = renderSession;
		
	}
	
	
	public function pushMask (mask:IBitmapDrawable):Void {
		
		var context = renderSession.context;
		
		context.save ();
		
		//var cacheAlpha = mask.__worldAlpha;
		var transform = mask.__worldTransform;
		if (transform == null) transform = new Matrix ();
		
		context.setTransform (transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
		
		context.beginPath ();
		mask.__renderMask (renderSession);
		
		context.clip ();
		
		//mask.worldAlpha = cacheAlpha;
		
	}
	
	
	public function popMask ():Void {
		
		renderSession.context.restore ();
		
	}
	
	
}