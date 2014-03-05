package flash.display;


import flash.display.Stage;


class DisplayObjectContainer extends InteractiveObject {
	
	
	private var children:Array<DisplayObject>;
	
	
	public function new () {
		
		super ();
		
		children = new Array<DisplayObject> ();
		
	}
	
	
	public function addChild (child:DisplayObject):DisplayObject {
		
		if (child != null) {
			
			if (child.parent != null) {
				
				child.parent.removeChild (child);
				
			}
			
			children.push (child);
			child.parent = this;
			
			if (stage != null) {
				
				child.__setStageReference (stage);
				
			}
			
		}
		
		return child;
		
	}
	
	
	public function removeChild (child:DisplayObject):DisplayObject {
		
		if (child != null && child.parent == this) {
			
			if (stage != null) {
				
				child.__setStageReference (null);
				
			}
			
			child.parent = null;
			children.remove (child);
			
		}
		
		return child;
		
	}
	
	
	private override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		/*if (this._mask) {
			
			renderSession.maskManager.pushMask (this._mask, renderSession.context);
			
		}*/
		
		for (child in children) {
			
			child.__renderCanvas (renderSession);
			
		}

		/*if (this._mask) {
			
			renderSession.maskManager.popMask (renderSession.context);
			
		}*/
		
	}
	
	
	private override function __setStageReference (stage:Stage):Void {
		
		this.stage = stage;
		
		//if (__interactive) stage.__dirty = true;
		
		for (child in children) {
			
			child.__setStageReference (stage);
			
		}
		
	}
	
	
	private override function __update ():Void {
		
		super.__update ();
		
		if (!__renderable) return;
		
		for (child in children) {
			
			child.__update ();
			
		}
		
	}
	
	
}