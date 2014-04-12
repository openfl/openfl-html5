package flash.display;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;


@:access(flash.display.LoaderInfo)
class Loader extends Sprite {
	
	
	public var content (default, null):DisplayObject;
	public var contentLoaderInfo (default, null):LoaderInfo;
	
	private var mImage:BitmapData;
	private var mShape:Shape;
	
	
	public function new () {
		
		super ();
		
		contentLoaderInfo = LoaderInfo.create (this);
		
	}
	
	
	public function load (request:URLRequest, context:LoaderContext = null):Void {
		
		var extension = "";
		var parts = request.url.split (".");
		
		if (parts.length > 0) {
			
			extension = parts[parts.length - 1].toLowerCase ();
			
		}
		
		var transparent = true;
		
		untyped { contentLoaderInfo.url = request.url; }
		
		if (request.contentType == null && request.contentType != "") {
			
			untyped {
				
				contentLoaderInfo.contentType = switch (extension) {
					
					case "swf": "application/x-shockwave-flash";
					case "jpg", "jpeg": transparent = false; "image/jpeg";
					case "png": "image/png";
					case "gif": "image/gif";
					default: "application/x-www-form-urlencoded"; /*throw "Unrecognized file " + request.url;*/
					
				}
				
			}
			
		} else {
			
			untyped { contentLoaderInfo.contentType = request.contentType; }
			
		}
		
		BitmapData.fromFile (request.url, BitmapData_onLoad);
		
	}
	
	
	public function loadBytes (buffer:ByteArray):Void {
		
		BitmapData.fromBytes (buffer, BitmapData_onLoad);
		
	}
	
	
	public function unload ():Void {
		
		if (numChildren > 0) {
			
			while (numChildren > 0) {
				
				removeChildAt (0);
				
			}
			
			content = null;
			contentLoaderInfo.url = null;
			contentLoaderInfo.contentType = null;
			contentLoaderInfo.content = null;
			contentLoaderInfo.bytesLoaded = 0;
			contentLoaderInfo.bytesTotal = 0;
			contentLoaderInfo.width = 0;
			contentLoaderInfo.height = 0;
			
			var event = new Event (Event.UNLOAD);
			event.currentTarget = this;
			dispatchEvent (event);
			
		}
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function BitmapData_onLoad (bitmapData:BitmapData):Void {
		
		contentLoaderInfo.content = new Bitmap (bitmapData);
		addChild (contentLoaderInfo.content);
		
		var event = new Event (Event.COMPLETE);
		event.target = contentLoaderInfo;
		event.currentTarget = contentLoaderInfo;
		contentLoaderInfo.dispatchEvent (event);
		
	}
	
	
}