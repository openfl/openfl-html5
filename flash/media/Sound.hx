package flash.media;


import flash.media.SoundLoaderContext;
import flash.net.URLRequest;


class Sound {
	
	
	public function new (stream:URLRequest = null, context:SoundLoaderContext = null):Void {
		
		
		
	}
	
	
	public function play (startTime:Float = 0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel {
		
		return new SoundChannel ();
		
	}
	
	
}