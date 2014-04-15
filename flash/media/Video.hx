package flash.media;


import flash.display.DisplayObject;
import flash.net.NetStream;
import js.html.MediaElement;
import js.Browser;


class Video extends DisplayObject {
	
	
	public var deblocking:Int;
	public var smoothing:Bool;
	
	private var __netStream:NetStream;
	
	
	public function new (width:Int = 320, height:Int = 240):Void {
		
		super ();
		
	}
	
	
	public function attachNetStream (ns:NetStream):Void {
		
		__netStream = ns;
		
	}
	
	
	public function clear():Void {
		
		
		
	}
	
	
}