package flash.display;


import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.Browser;


@:allow(flash.display) class Graphics {
	
	
	private var context:CanvasRenderingContext2D;
	private var element:Element;
	
	
	public function new () {
		
		element = Browser.document.createElement ("canvas");
		context = cast (element, CanvasElement).getContext ("2d");
		
	}
	
	
	public function beginFill (rgb:Int, alpha:Int = 0xFF):Void {
		
		if (alpha == 0xFF) {
			
			context.fillStyle = "#" + StringTools.hex (rgb, 6);
			
		} else {
			
			var r = (rgb & 0xFF0000) >>> 16;
			var g = (rgb & 0x00FF00) >>> 8;
			var b = (rgb & 0x0000FF);
			
			context.fillStyle = "rgba(" + r + ", " + g + ", " + b + ", " + alpha + ")";
			
		}
		
	}
	
	
	
	public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
		
		context.fillRect (x, y, width, height);
		
	}
	
	
}