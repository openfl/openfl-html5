package flash.display;


import flash.display.Stage;
import flash.errors.RangeError;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;


class DisplayObjectContainer extends InteractiveObject {
	
	
	public var mouseChildren:Bool;
	public var numChildren (get, null):Int;
	public var tabChildren:Bool;
	
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
	
	
	public function contains (child:DisplayObject):Bool {
		
		return __children.indexOf (child) > -1;
		
	}
	
	
	public function getChildAt (index:Int):DisplayObject {
		
		if (index >= 0 && index < __children.length) {
			
			return __children[index];
			
		}
		
		return null;
		
	}
	
	
	public function getChildByName (name:String):DisplayObject {
		
		for (child in __children) {
			
			if (child.name == name) return child;
			
		}
		
		return null;
		
	}
	
	
	public function getChildIndex (child:DisplayObject):Int {
		
		for (i in 0...__children.length) {
			
			if (__children[i] == child) return i;
			
		}
		
		return -1;
		
	}
	
	
	public function getObjectsUnderPoint (point:Point):Array<DisplayObject> {
		
		var result = new Array<DisplayObject> ();
		//__getObjectsUnderPoint (point, result);
		return result;
		
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
	
	
	public function removeChildAt (index:Int):DisplayObject {
		
		if (index >= 0 && index < __children.length) {
			
			return removeChild (__children[index]);
			
		}
		
		return null;
		
	}
	
	
	public function removeChildren (beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		
		if (endIndex == 0x7FFFFFFF) { 
			
			endIndex = __children.length - 1;
			
			if (endIndex < 0) {
				
				return;
				
			}
			
		}
		
		if (beginIndex > __children.length - 1) {
			
			return;
			
		} else if (endIndex < beginIndex || beginIndex < 0 || endIndex > __children.length) {
			
			throw new RangeError ("The supplied index is out of bounds.");
			
		}
		
		var numRemovals = endIndex - beginIndex;
		while (numRemovals >= 0) {
			
			removeChildAt (beginIndex);
			numRemovals--;
			
		}
		
	}
	
	
	public function setChildIndex (child:DisplayObject, index:Int) {
		
		if (index >= 0 && index <= __children.length && child.parent == this) {
			
			__children.remove (child);
			__children.insert (index, child);
			
		}
		
	}
	
	
	public function swapChildren (child1:DisplayObject, child2:DisplayObject):Void {
		
		if (child1.parent == this && child2.parent == this) {
			
			var index1 = __children.indexOf (child1);
			var index2 = __children.indexOf (child2);
			
			__children[index1] = child2;
			__children[index2] = child1;
			
		}
		
	}
	
	
	public function swapChildrenAt (child1:Int, child2:Int):Void {
		
		var swap:DisplayObject = __children[child1];
		__children[child1] = __children[child2];
		__children[child2] = swap;
		swap = null;
		
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
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
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
	
	
	private function get_numChildren ():Int {
		
		return __children.length;
		
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