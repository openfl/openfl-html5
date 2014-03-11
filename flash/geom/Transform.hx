package flash.geom;


import flash.display.DisplayObject;


class Transform {
	
	
	public var colorTransform:ColorTransform;
	public var concatenatedColorTransform:ColorTransform;
	public var concatenatedMatrix:Matrix;
	public var matrix:Matrix;
	public var pixelBounds:Rectangle;
	
	
	public function new (displayObject:DisplayObject) {
		
		colorTransform = new ColorTransform ();
		concatenatedColorTransform = new ColorTransform ();
		concatenatedMatrix = new Matrix ();
		matrix = new Matrix ();
		pixelBounds = new Rectangle ();
		
	}
	
	
}