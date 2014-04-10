package flash.media;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;


class SoundChannel extends EventDispatcher {
	
	
	public var leftPeak (default, null):Float;
	public var position (get, set):Float;
	public var rightPeak (default, null):Float;
	public var soundTransform (get, set):SoundTransform;
	
	private var __howl:Howl;
	private var __loop:Bool;
	private var __soundID:String;
	private var __soundTransform:SoundTransform;
	private var __startTime:Float;
	private var __stopped:Bool;
	
	
	private function new (howl:Howl, startTime:Float, loops:Int, soundTransform:SoundTransform):Void {
		
		super (this);
		
		__loop = (loops > 0);
		__soundTransform = soundTransform;
		__startTime = startTime;
		
		if (__loop) howl.loop (true);
		
		__howl = howl;
		__howl.on ("end", howl_onEnd);
		__howl.play (null, howl_onPlay);
		
	}
	
	
	public function stop ():Void {
		
		if (__soundID != null) {
			
			__dispose ();
			
		}
		
		__stopped = true;
		
	}
	
	
	private function __dispose ():Void {
		
		if (__soundID != null && __howl != null) {
			
			__howl.off ("end", howl_onEnd);
			__howl.stop (__soundID);
			__howl = null;
			
		}
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_position ():Float {
		
		if (__soundID != null) {
			
			return __howl.pos (-1, __soundID);
			
		}
		
		return 0;
		
	}
	
	
	private function set_position (value:Float):Float {
		
		if (__soundID != null) {
			
			__howl.pos (value, __soundID);
			return __howl.pos (-1, __soundID);
			
		}
		
		return 0;
		
	}
	
	
	private function get_soundTransform ():SoundTransform {
		
		return new SoundTransform (__soundTransform.volume, __soundTransform.pan);
		
	}
	
	
	private function set_soundTransform (value:SoundTransform):SoundTransform {
		
		__soundTransform.volume = value.volume;
		__soundTransform.pan = value.pan;
		
		if (__soundID != null) {
			
			__howl.volume (__soundTransform.volume, __soundID);
			
		}
		
		return value;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function howl_onEnd (_):Void {
		
		if (!__loop) {
			
			__dispose ();
			dispatchEvent (new Event (Event.SOUND_COMPLETE));
			
		}
		
	}
	
	
	private function howl_onPlay (soundID:String):Void {
		
		__soundID = soundID;
		
		if (__stopped) {
			
			__dispose ();
			
		} else {
			
			__howl.volume (__soundTransform.volume, __soundID);
			__howl.pos (__startTime, __soundID);
			if (__loop) __howl.loop (true);
			
		}
		
	}
	
	
}