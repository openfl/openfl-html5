package flash.display;


import flash.display.Stage;


class DisplayObjectContainer extends InteractiveObject {
	
	
	private var __children:Array<DisplayObject>;
	
	
	public function new () {
		
		super ();
		
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
		
		this.stage = stage;
		
		//if (__interactive) stage.__dirty = true;
		
		for (child in __children) {
			
			child.__setStageReference (stage);
			
		}
		
	}
	
	
	private override function __update ():Void {
		
		super.__update ();
		
		if (!__renderable) return;
		
		for (child in __children) {
			
			child.__update ();
			
		}
		
	}
	
	
}