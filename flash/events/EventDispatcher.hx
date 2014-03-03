package flash.events;


class EventDispatcher {
	
	
	private var __eventMap:Map<String, Array<Event->Void>>;
	
	
	public function new () {
		
		
		
	}
	
	
	public function addEventListener (type:String, listener:Event->Void):Void {
		
		if (__eventMap == null) {
			
			__eventMap = new Map ();
			
		}
		
		if (!__eventMap.exists (type)) {
			
			var list = new Array<Event->Void> ();
			list.push (listener);
			__eventMap.set (type, list);
			
		} else {
			
			var list = __eventMap.get (type);
			list.push (listener);
			
		}
		
	}
	
	
	public function dispatchEvent (event:Event):Void {
		
		if (__eventMap != null) {
			
			var list = __eventMap.get (event.type);
			
			if (list != null) {
				
				for (listener in list) {
					
					listener (event);
					
				}
				
			}
			
		}
		
	}
	
	
	public function hasEventListener (type:String):Bool {
		
		return (__eventMap != null && __eventMap.exists (type));
		
	}
	
	
	
}