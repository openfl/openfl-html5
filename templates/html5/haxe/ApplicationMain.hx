package;


import openfl.Assets;


#if (!macro && !display)


import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import js.html.HtmlElement;
import js.html.Image;
import flash.Lib;

@:access(flash.Lib) class ApplicationMain {
	
	
	public static var images (default, null) = new Map<String, Image> ();
	public static var urlLoaders = new Map <String, URLLoader> ();
	
	private static var assetsLoaded = 0;
	private static var preloader:::PRELOADER_NAME::;
	private static var total = 0;
	
	//public static var loaders:Map <String, Loader>;
	//public static var urlLoaders:Map <String, URLLoader>;
	
	
	static function main () {
		
		#if munit
		var element = null;
		#else
		var element:HtmlElement = cast js.Browser.document.getElementById ("openfl-embed");
		#end
		
		flash.Lib.create (::WIN_WIDTH::, ::WIN_HEIGHT::, element, ::WIN_BACKGROUND::);
		
		preloader = ::if (PRELOADER_NAME != "")::new ::PRELOADER_NAME::::else::NMEPreloader::end:: ();
		Lib.current.addChild (preloader);
		preloader.onInit ();
		
		var id;
		::foreach assets::::if (embed)::
		::if (type == "image")::
		var image = new Image ();
		id = "::resourceName::";
		images.set (id, image);
		image.onload = image_onLoad;
		image.src = id;
		//var loader:Loader = new Loader();
		//loaders.set("::resourceName::", loader);
		total ++;
		::elseif (type == "binary")::
		var urlLoader = new URLLoader ();
		urlLoader.dataFormat = BINARY;
		urlLoaders.set("::resourceName::", urlLoader);
		total ++;
		::elseif (type == "text")::
		var urlLoader = new URLLoader ();
		urlLoader.dataFormat = BINARY;
		urlLoaders.set("::resourceName::", urlLoader);
		total ++;
		::end::
		::end::::end::
		
		if (total == 0) {
			
			start ();
			
		} else {
			
			for (path in urlLoaders.keys ()) {
				
				var urlLoader = urlLoaders.get (path);
				urlLoader.addEventListener ("complete", loader_onComplete);
				urlLoader.load (new URLRequest (path));
				
			}
			
		}
		
	}
	
	
	private static function start ():Void {
		
		preloader.addEventListener (Event.COMPLETE, preloader_onComplete);
		preloader.onLoaded ();
		
	}
	
	
	private static function image_onLoad (_):Void {
		
		assetsLoaded++;
		
		preloader.onUpdate (assetsLoaded, total);
		
		if (assetsLoaded == total) {
			
			start ();
			
		}
		
	}
	
	
	private static function loader_onComplete (event:Event):Void {
		
		assetsLoaded++;
		
		preloader.onUpdate (assetsLoaded, total);
		
		if (assetsLoaded == total) {
			
			start ();
			
		}
		
	}
	
	
	private static function preloader_onComplete (event:Event):Void {
		
		preloader.removeEventListener (Event.COMPLETE, preloader_onComplete);
		Lib.current.removeChild (preloader);
		preloader = null;
		
		var hasMain = false;
		
		for (methodName in Type.getClassFields (::APP_MAIN::)) {
			
			if (methodName == "main") {
				
				hasMain = true;
				break;
				
			}
			
		}
			
		if (hasMain) {
			
			Reflect.callMethod (::APP_MAIN::, Reflect.field (::APP_MAIN::, "main"), []);
			
		} else {
			
			var instance:DocumentClass = Type.createInstance(DocumentClass, []);
			
			if (Std.is (instance, flash.display.DisplayObject)) {
				
				flash.Lib.current.addChild (cast instance);
				
			}
			
		}
		
	}
	
	
}


@:build(DocumentClass.build())
@:keep class DocumentClass extends ::APP_MAIN:: {}


#elseif macro


import haxe.macro.Context;
import haxe.macro.Expr;


class DocumentClass {
	
	
	macro public static function build ():Array<Field> {
		
		var classType = Context.getLocalClass ().get ();
		var searchTypes = classType;
		
		while (searchTypes.superClass != null) {
			
			if (searchTypes.pack.length == 2 && searchTypes.pack[1] == "display" && searchTypes.name == "DisplayObject") {
				
				var fields = Context.getBuildFields ();
				var method = macro { this.stage = flash.Lib.current.stage; super (); }
				
				fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: [], expr: method, params: [], ret: macro :Void }), pos: Context.currentPos () });
				return fields;
				
			}
			
			searchTypes = searchTypes.superClass.t.get ();
			
		}
		
		return null;
		
	}
	
	
}


#else


import ::APP_MAIN::;

class ApplicationMain {
	
	
	public static function main () {
		
		
		
	}
	
	
}


#end