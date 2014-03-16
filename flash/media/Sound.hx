package flash.media;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import haxe.io.Path;


@:autoBuild(openfl.Assets.embedSound())
class Sound extends EventDispatcher {
	
	
	public var bytesLoaded (default, null):Int;
	public var bytesTotal (default, null):Int;
	public var id3 (default, null):ID3Info;
	public var isBuffering (default, null):Bool;
	public var length (default, null):Float;
	public var url (default, null):String;
	
	private var __buffer:Bool;
	private var __howl:Howl;
	
	
	public function new (stream:URLRequest = null, context:SoundLoaderContext = null) {
		
		super (this);
		
		bytesLoaded = 0;
		bytesTotal = 0;
		id3 = null;
		isBuffering = false;
		length = 0;
		url = null;
		
		if (stream != null) {
			
			load (stream, context);
			
		}
		
	}
	
	
	public function close ():Void {
		
		if (__howl != null) {
			
			__howl.unload ();
			
		}
		
	}
	
	
	public function load (stream:URLRequest, context:SoundLoaderContext = null):Void {
		
		if (__howl != null) {
			
			if (stream.url == url) {
				
				return;
				
			} else {
				
				__howl.unload ();
				
			}
			
		}
		
		url = stream.url;
		var file = Path.withoutExtension (stream.url);
		
		__howl = new Howl ({
			onload: howl_onLoad,
			onloaderror: howl_onLoadError,
			urls: [ file + ".ogg", file + ".mp3", file + ".wav" ],
			buffer: __buffer,
			loop: __buffer // For now, we'll assume music tracks are looping :/
		});
		
	}
	
	
	public function play (startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel {
		
		if (sndTransform == null) {
			
			sndTransform = new SoundTransform (1, 0);
			
		}
		
		// For now, assume looping on music tracks
		
		if (__buffer) loops++;
		
		return new SoundChannel (__howl, startTime, loops, sndTransform);
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function howl_onLoad (_):Void {
		
		dispatchEvent (new Event (Event.COMPLETE));
		
	}
	
	
	private function howl_onLoadError (_):Void {
		
		#if debug
		trace ("Error loading sound '" + url + "'");
		#end
		
		dispatchEvent (new IOErrorEvent (IOErrorEvent.IO_ERROR));
		
	}
	
	
}


@:native("Howler") extern class Howler {
	
	
	public static function mute ():Howler;
	public static function unmute ():Howler;
	public static function volume (vol:Float):Howler;
	
}


@:native("Howl") extern class Howl {
	
	
	public var autoplay:Bool;
	public var buffer:Bool;
	public var format:String;
    //public var loop:Bool;
    //public var sprite:Dynamic;
    //public var volume:Float;
    //public var urls:Array<String>;
    public var onend:Dynamic;
	public var onload:Dynamic;
	public var onloaderror:Dynamic;
	public var onpause:Dynamic;
	public var onplay:Dynamic;
	
	public function new (options:Dynamic);
	
	public function load ():Howl;
	@:overload(function (url:String):Howl{}) public function urls (urls:Array<String>):Howl;
	public function play (?sprite:String, ?callback:Dynamic):Howl;
	public function pause (?id:String, ?timerID:String):Howl;
	public function stop (?id:String, ?timerID:String):Howl;
	public function mute (?id:String):Howl;
	public function unmute (?id:String):Howl;
	public function volume (vol:Float, ?id:String):Howl;
	public function loop (loop:Bool):Howl;
	public function sprite (sprite:Dynamic):Howl;
	public function pos (pos:Float, ?id:String):Howl;
	public function pos3d (x:Float, y:Float, z:Float, ?id:String):Howl;
	public function fade (from:Float, to:Float, len:Float, ?callback:Dynamic, ?id:String):Howl;
	//public function fadeIn (to:Float, len:Float, ?callback:Dynamic):Howl;
	//public function fadeOut (to:Float, len:Float, ?callback:Dynamic, ?id:String):Howl;
	public function on (event:String, ?callback:Dynamic):Howl;
	public function off (event:String, ?callback:Dynamic):Howl;
	public function unload ():Void;
	
	
}


/*package flash.media;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.Lib;
import js.html.MediaElement;
import js.Browser;


@:autoBuild(openfl.Assets.embedSound())
class Sound extends EventDispatcher {
	
	
	static inline var EXTENSION_MP3 = "mp3";
	static inline var EXTENSION_OGG = "ogg";
	static inline var EXTENSION_WAV = "wav";
	static inline var EXTENSION_AAC = "aac";
	static inline var MEDIA_TYPE_MP3 = "audio/mpeg";
	static inline var MEDIA_TYPE_OGG = "audio/ogg; codecs=\"vorbis\"";
	static inline var MEDIA_TYPE_WAV = "audio/wav; codecs=\"1\"";
	static inline var MEDIA_TYPE_AAC = "audio/mp4; codecs=\"mp4a.40.2\"";
	
	public var bytesLoaded (default, null):Int;
	public var bytesTotal (default, null):Int;
	public var id3 (default, null):ID3Info;
	public var isBuffering (default, null):Bool;
	public var length (default, null):Float;
	public var url (default, null):String;
	
	private var __soundCache:URLLoader;
	private var __soundChannels:Map<Int, SoundChannel>;
	private var __soundIdx:Int;
	private var __streamUrl:String;

	
	public function new (stream:URLRequest = null, context:SoundLoaderContext = null):Void {
		
		super (this);
		
		bytesLoaded = 0;
		bytesTotal = 0;
		id3 = null;
		isBuffering = false;
		length = 0;
		url = null;
		
		__soundChannels = new Map<Int, SoundChannel> ();
		__soundIdx = 0;
		
		if (stream != null) {
			
			load (stream, context);
		}
		
	}
	
	
	public function close ():Void {
		
		
		
	}
	
	
	public function load (stream:URLRequest, context:SoundLoaderContext = null):Void {
		
		__load (stream, context);
		
	}
	
	
	public function play (startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel {
		
		if (__streamUrl == null) return null;
		
		// -- GC the sound when the following closure is executed
		var self = this;
		var curIdx = __soundIdx;
		var removeRef = function () {
			
			self.__soundChannels.remove (curIdx);
			
		}
		// --
		
		var channel = SoundChannel.__create (__streamUrl, startTime, loops, sndTransform, removeRef);
		__soundChannels.set (curIdx, channel);
		__soundIdx++;
		var audio = channel.__audio;
		
		return channel;
		
	}
	
	
	private function __addEventListeners ():Void {
		
		__soundCache.addEventListener (Event.COMPLETE, __onSoundLoaded);
		__soundCache.addEventListener (IOErrorEvent.IO_ERROR, __onSoundLoadError);
		
	}
	
	
	public static function __canPlayMime (mime:String):Bool {
		
		var audio:MediaElement = cast Browser.document.createElement ("audio");
		
		var playable = function (ok:String) {
			
			if (ok != "" && ok != "no") return true; else return false;
		}
		
		//return playable(audio.canPlayType(mime));
		return playable (audio.canPlayType (mime, null));
		
	}
	
	
	public static function __canPlayType (extension:String):Bool {
		
		var mime = __mimeForExtension (extension);
		if (mime == null) return false;
		return __canPlayMime (mime);
		
	}
	
	
	public function __load (stream:URLRequest, context:SoundLoaderContext = null, mime:String = ""):Void {
		
		#if debug
		if (mime == null) {
			
			var url = stream.url.split ("?");
			var extension = url[0].substr (url[0].lastIndexOf (".") + 1);
			mime = __mimeForExtension (extension);
			
		}
		
		if (mime == null || !__canPlayMime (mime))
			trace ("Warning: '" + stream.url + "' with type '" + mime + "' may not play on this browser.");
		#end
		
		__streamUrl = stream.url;
		
		// initiate a network request, so the resource is cached by the browser
		try {
			
			__soundCache = new URLLoader ();
			__addEventListeners ();
			__soundCache.load (stream);
			
		} catch (e:Dynamic) {
			
			#if debug
			trace ("Warning: Could not preload '" + stream.url + "'");
			#end
			
		}
		
	}
	
	
	private static inline function __mimeForExtension (extension:String):String {
		
		var mime:String = null;
		
		switch (extension) {
			
			case EXTENSION_MP3: mime = MEDIA_TYPE_MP3;
			case EXTENSION_OGG: mime = MEDIA_TYPE_OGG;
			case EXTENSION_WAV: mime = MEDIA_TYPE_WAV;
			case EXTENSION_AAC: mime = MEDIA_TYPE_AAC;
			default: mime = null;
			
		}
		
		return mime;
		
	}
	
	
	private function __removeEventListeners ():Void {
		
		__soundCache.removeEventListener (Event.COMPLETE, __onSoundLoaded, false);
		__soundCache.removeEventListener (IOErrorEvent.IO_ERROR, __onSoundLoadError, false);
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function __onSoundLoadError (evt:IOErrorEvent):Void {
		
		__removeEventListeners ();
		
		#if debug
		trace ("Error loading sound '" + __streamUrl + "'");
		#end
		
		var evt = new IOErrorEvent (IOErrorEvent.IO_ERROR);
		dispatchEvent (evt);
		
	}
	
	
	private function __onSoundLoaded (evt:Event):Void {
		
		__removeEventListeners ();
		var evt = new Event (Event.COMPLETE);
		dispatchEvent (evt);
		
	}
	
	
}*/