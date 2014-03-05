package;


import flash.display.Loader;
import flash.net.URLLoader;
import js.html.Image;


class ApplicationMain {
	
	
	public static var images (default, null) = new Map<String, Image> ();
	
	private static var assetsLoaded = 0;
	private static var total = 0;
	
	//public static var loaders:Map <String, Loader>;
	//public static var urlLoaders:Map <String, URLLoader>;
	
	
	static function main () {
		
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
		//var urlLoader:URLLoader = new URLLoader();
		//urlLoader.dataFormat = BINARY;
		//urlLoaders.set("::resourceName::", urlLoader);
		//total ++;
		::elseif (type == "text")::
		//var urlLoader:URLLoader = new URLLoader();
		//urlLoader.dataFormat = BINARY;
		//urlLoaders.set("::resourceName::", urlLoader);
		//total ++;
		::end::
		::end::::end::
		
	}
	
	
	private static function image_onLoad (_):Void {
		
		assetsLoaded++;
		
		if (assetsLoaded == total) {
			
			new DocumentClass ();
			
		}
		
	}
	
	
}