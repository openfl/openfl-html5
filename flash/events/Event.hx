package flash.events;


class Event {
	
	
	public static var ENTER_FRAME = "enterFrame";
	
	public var type (default, null):String;
	
	
	public function new (type:String) {
		
		this.type = type;
		
	}
	
	
	
}