package flash.net;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import js.html.VideoElement;
import js.Browser;


class NetStream extends EventDispatcher {
	
	
	private static inline var BUFFER_UPDATED:String = "flash.net.NetStream.updated";
	private static inline var CODE_PLAY_STREAMNOTFOUND:String = "NetStream.Play.StreamNotFound";
	private static inline var CODE_BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
	private static inline var CODE_BUFFER_FULL:String = "NetStream.Buffer.Full";
	private static inline var CODE_BUFFER_FLUSH:String = "NetStream.Buffer.Flush";
	private static inline var CODE_BUFFER_START:String = "NetStream.Play.Start";
	private static inline var CODE_BUFFER_STOP:String = "NetStream.Play.Stop";
	private static inline var CODE_PLAY_TRANSITIONCOMPLETE:String = "NetStream.Play.TransitionComplete";
	private static inline var CODE_PLAY_SWITCH:String = "NetStream.Play.Switch";
	private static inline var CODE_PLAY_COMPLETE:String = "NetStream.Play.Complete";
	private static inline var CODE_PLAY_UNSUPPORTEDFORMAT:String = "NetStream.Play.UnsupportedFormat";
	private static inline var CODE_PLAY_ERROR:String = "NetStream.Play.error";
	private static inline var CODE_PLAY_WAITING:String = "NetStream.Play.waiting";
	private static inline var CODE_PLAY_SEEKING:String = "NetStream.Play.seeking";
	private static inline var CODE_PLAY_PAUSE:String = "NetStream.Play.pause";
	private static inline var CODE_PLAY_PLAYING:String = "NetStream.Play.playing";
	private static inline var CODE_PLAY_TIMEUPDATE:String = "NetStream.Play.timeupdate";
	private static inline var CODE_PLAY_LOADSTART:String = "NetStream.Play.loadstart";
	private static inline var CODE_PLAY_STALLED:String = "NetStream.Play.stalled";
	private static inline var CODE_PLAY_DURATIONCHANGED:String = "NetStream.Play.durationchanged";
	private static inline var CODE_PLAY_CANPLAYTHROUGH:String = "NetStream.Play.canplaythrough";
	private static inline var CODE_PLAY_CANPLAY:String = "NetStream.Play.canplay";
	
	public var audioCodec:Int;
	public var bufferLength:Float;
	public var bufferTime:Float;
	public var bytesLoaded:Int;
	public var bytesTotal:Int;
	public var checkPolicyFile:Bool;
	public var client:Dynamic;
	public var currentFPS:Float;
	public var decodedFrames:Int;
	public var liveDelay:Float;
	public var objectEncoding:Int;
	public var soundTransform:SoundTransform;
	public var time:Float;
	public var videoCodec:Int;
	
	private var __connection:NetConnection;
	private var __video (default, null):VideoElement;
	
	
	public function new (connection:NetConnection):Void {
		
		super ();
		
		__connection = connection;
		
		__video = cast Browser.document.createElement ("video");
		
		__video.addEventListener ("error", video_onError, false);
		__video.addEventListener ("waiting", video_onWaiting, false);
		__video.addEventListener ("ended", video_onEnd, false);
		__video.addEventListener ("pause", video_onPause, false);
		__video.addEventListener ("seeking", video_onSeeking, false);
		__video.addEventListener ("playing", video_onPlaying, false);
		__video.addEventListener ("timeupdate", video_onTimeUpdate, false);
		__video.addEventListener ("loadstart", video_onLoadStart, false);
		__video.addEventListener ("stalled", video_onStalled, false);
		__video.addEventListener ("durationchanged", video_onDurationChanged, false);
		__video.addEventListener ("canplay", video_onCanPlay, false);
		__video.addEventListener ("canplaythrough", video_onCanPlayThrough, false);
		
	}
	
	
	public function pause ():Void {
		
		__video.pause ();
		
	}
	
	
	public function play (url:String, ?_, ?_, ?_, ?_, ?_):Void {
		
		__video.src = url;
		__video.play ();
		
	}
	
	
	public function resume ():Void {
		
		__video.play ();
		
	}
	
	
	public function seek (offset:Float):Void {
		
		var time = __video.currentTime + offset;
		
		if (time < 0) {
			
			time = 0;
			
		} else if (time > __video.duration) {
			
			time = __video.duration;
			
		}
		
		__video.currentTime = time;
		
	}
	
	
	public function togglePause ():Void {
		
		if (__video.paused) {
			
			__video.play ();
			
		} else {
			
			__video.pause ();
			
		}
		
	}
	
	
	private function __playStatus (code:String):Void {
		
		if (client != null) {
			
			try {
				
				var handler = client.onPlayStatus;
				handler ({ 
					
					code: code,
					duration: __video.duration,
					position: __video.currentTime,
					start: __video.startTime
					
				});
				
			} catch (e:Dynamic) {}
			
		}
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function video_onCanPlay (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_CANPLAY);
		
	}
	
	
	private function video_onCanPlayThrough (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_CANPLAYTHROUGH);
		
	}
	
	
	private function video_onDurationChanged (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_DURATIONCHANGED);
		
	}
	
	
	private function video_onEnd (event:Dynamic):Void {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_STOP } ));
		__playStatus (CODE_PLAY_COMPLETE);
		
	}
	
	
	private function video_onError (event:Dynamic):Void {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_STOP } ));
		__playStatus (CODE_PLAY_ERROR);
		
	}
	
	
	private function video_onLoadStart (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_LOADSTART);
		
	}
	
	
	private function video_onPause (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_PAUSE);
		
	}
	
	
	private function video_onPlaying (event:Dynamic):Void {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_START } ));
		__playStatus (CODE_PLAY_PLAYING);
		
	}
	
	
	private function video_onSeeking (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_SEEKING);
		
	}
	
	
	private function video_onStalled (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_STALLED);
		
	}
	
	
	private function video_onTimeUpdate (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_TIMEUPDATE);
		
	}
	
	
	private function video_onWaiting (event:Dynamic):Void {
		
		__playStatus (CODE_PLAY_WAITING);
		
	}
	
	
}