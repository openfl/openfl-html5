package flash.display;


import flash.display.Stage;
import flash.geom.Matrix;


interface IBitmapDrawable {
	
	var __worldTransform:Matrix;
	
	function __renderCanvas (renderSession:RenderSession):Void;
	function __renderMask (renderSession:RenderSession):Void;
	function __updateChildren ():Void;
	
}