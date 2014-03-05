package flash.display;


import js.html.CanvasElement;
import js.html.Image;


class BitmapData {
	
	
	public var height (default, null):Int;
	public var width (default, null):Int;
	
	private var __sourceCanvas:CanvasElement;
	private var __sourceImage:Image;
	
	
	public function new (width:Int, height:Int, transparent:Bool = true) {
		
		//__sourceImage = new Image ();
		//__sourceImage.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAlCAYAAABcZvm2AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAWNJREFUeNrsV8sNwjAMbUqBBWACxB2pQ8AKcGALTsAJuDEFB1gBhuDAuWICmICPQh01pXWdJqEFcaglRGRbfonjPLuMc+5QwhjLGEJfZusjxZOL9akZKye9G98vPMfvsAx4qBfKwfzBL9s6uUHpI6U/u7+BKGkNb/H6umtk7MczF0HyfKS4zo/k/4AgTV8DOizrqX8oECgC+MGa8lGJp9sJDiAB8nyqYoglvJOPbP97IqoATGxWVZeXJlMQwYHA3piF8wJIblOVNBBxe3TPMLoHIKtxrbS7AAbBrA4Y5NaPAXf8LjN6wKZ0RaZOnlAFZnuXInVR4FTE6eYp0olPhhshtXsAwY3PquoAJNkIY33U7HTs7hYBwV24ItUKqDwgKF3VzAZ6k8HF+B1BMF8xRJbeJoqMXHZAAQ1kwoluURCdzepEugGEImBrIADB7I4lyfbJLlw92FKE6b5hVd+ktv4vAQYASMWxvlAAvcsAAAAASUVORK5CYII=";
		
		//width = 26;
		//height = 37;
		
	}
	
	
	public static function fromImage (image:Image):BitmapData {
		
		var bitmapData = new BitmapData (0, 0);
		bitmapData.__sourceImage = image;
		bitmapData.width = image.width;
		bitmapData.height = image.height;
		
		return bitmapData;
		
	}
	
	
}