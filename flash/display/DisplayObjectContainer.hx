package flash.display;


import flash.display.Stage;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;


class DisplayObjectContainer extends InteractiveObject {
	
	
	public var mouseChildren:Bool;
	
	private var __children:Array<DisplayObject>;
	
	
	public function new () {
		
		super ();
		
		mouseChildren = true;
		
		__children = new Array<DisplayObject> ();
		
	}
	
	
	public function addChild (child:DisplayObject):DisplayObject {
		
		if (child != null) {
			
			if (child.parent != null) {
				
				child.parent.removeChild (child);
				
			}
			
			__children.push (child);
			child.parent = this;
			
			if (stage != null) {
				
				child.__setStageReference (stage);
				
			}
			
		}
		
		return child;
		
	}
	
	
	public function addChildAt (child:DisplayObject, index:Int):DisplayObject {
		
		if (index > __children.length || index < 0) {
			
			throw "Invalid index position " + index;
			
		}
		
		if (child.parent == this) {
			
			__children.remove (child);
			
		} else {
			
			if (child.parent != null) {
				
				child.parent.removeChild (child);
				
			}
			
			child.parent = this;
			
			if (stage != null) {
				
				child.__setStageReference (stage);
				
			}
			
		}
		
		__children.insert (index, child);
		
		return child;
		
	}
	
	
	public function getChildAt (index:Int):DisplayObject {
		
		if (index >= 0 && index < __children.length) {
			
			return __children[index];
			
		}
		
		return null;
		
	}
	
	
	public function removeChild (child:DisplayObject):DisplayObject {
		
		if (child != null && child.parent == this) {
			
			if (stage != null) {
				
				child.__setStageReference (null);
				
			}
			
			child.parent = null;
			__children.remove (child);
			
		}
		
		return child;
		
	}
	
	
	private override function __broadcast (event:Event):Void {
		
		for (child in __children) {
			
			child.__broadcast (event);
			
		}
		
		dispatchEvent (event);
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		if (__children.length == 0) return;
		
		// TODO the bounds have already been calculated this render session so return what we have
		
		if (matrix != null) {
			
			var matrixCache = __worldTransform;
			__worldTransform = matrix;
			__update ();
			__worldTransform = matrixCache;
			
		}
		
		for (child in __children) {
			
			if (!child.__renderable) continue;
			child.__getBounds (rect, matrix);
			
		}
		
	}
	
	
	private override function __getLocalBounds (rect:Rectangle):Void {
		
		var matrixCache = __worldTransform;
		__worldTransform = new Matrix ();
		
		for (child in __children) {
			
			child.__update ();
			
		}
		
		__getBounds (rect, null);
		__worldTransform = matrixCache;
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<InteractiveObject>):Bool {
		
		if (!visible || !mouseEnabled) return false;
		
		var i = __children.length - 1;
		
		if (stack == null || !mouseChildren) {
			
			while (i >= 0) {
				
				if (__children[i].__hitTest (x, y, shapeFlag, null)) {
					
					if (stack != null) {
						
						stack.push (this);
						
					}
					
					return true;
					
				}
				
				i--;
				
			}
			
		} else if (stack != null) {
			
			var length = stack.length;
			
			while (i >= 0) {
				
				if (__children[i].__hitTest (x, y, shapeFlag, stack)) {
					
					stack.insert (length, this);
					
					return true;
					
				}
				
				i--;
				
			}
			
		}
		
		return false;
		
	}
	
	
	private override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		/*if (this._mask) {
			
			renderSession.maskManager.pushMask (this._mask, renderSession.context);
			
		}*/
		
		for (child in __children) {
			
			child.__renderCanvas (renderSession);
			
		}

		/*if (this._mask) {
			
			renderSession.maskManager.popMask (renderSession.context);
			
		}*/
		
	}
	
	
	private override function __setStageReference (stage:Stage):Void {
		
		if (this.stage != stage) {
			
			this.stage = stage;
			
			if (stage != null) {
				
				var evt = new Event (Event.ADDED_TO_STAGE, false, false);
				dispatchEvent (evt);
				
			}
			
			for (child in __children) {
				
				child.__setStageReference (stage);
				
			}
			
		}
		
	}
	
	
	private override function __update ():Void {
		
		super.__update ();
		
		if (!__renderable) return;
		
		for (child in __children) {
			
			child.__update ();
			
		}
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_height ():Float {
		
		// TODO: More efficient way to do this?
		
		var bounds = new Rectangle ();
		__getLocalBounds (bounds);
		
		return bounds.height;
		
	}
	
	
	private override function set_height (value:Float):Float {
		
		// TODO: More efficient way to do this?
		
		var bounds = new Rectangle ();
		__getLocalBounds (bounds);
		
		if (value != bounds.height) {
			
			scaleY = value / bounds.height;
			
		}
		
		return value;
		
	}
	
	
	private override function get_width ():Float {
		
		// TODO: More efficient way to do this?
		
		var bounds = new Rectangle ();
		__getLocalBounds (bounds);
		
		return bounds.height;
		
	}
	
	
	private override function set_width (value:Float):Float {
		
		// TODO: More efficient way to do this?
		
		var bounds = new Rectangle ();
		__getLocalBounds (bounds);
		
		if (value != bounds.width) {
			
			scaleX = value / bounds.width;
			
		}
		
		return value;
		
	}
	
	
}