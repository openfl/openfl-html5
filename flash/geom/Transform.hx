package flash.geom;


import flash.display.DisplayObject;


class Transform {
	
	
	public var colorTransform:ColorTransform;
	public var concatenatedColorTransform:ColorTransform;
	public var concatenatedMatrix:Matrix;
	public var matrix (get, set):Matrix;
	public var pixelBounds:Rectangle;
	
	private var __displayObject:DisplayObject;
	
	
	public function new (displayObject:DisplayObject) {
		
		colorTransform = new ColorTransform ();
		concatenatedColorTransform = new ColorTransform ();
		concatenatedMatrix = new Matrix ();
		pixelBounds = new Rectangle ();
		
		__displayObject = displayObject;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_matrix ():Matrix {
		
		var matrix = new Matrix ();
		
		matrix.scale (__displayObject.scaleX, __displayObject.scaleY);
		matrix.rotate (__displayObject.rotation * (Math.PI / 180));
		matrix.translate (__displayObject.x, __displayObject.y);
		
		return matrix;
		
	}
	
	
	private function set_matrix (value:Matrix):Matrix {
		
		if (value == null) {
			
			value = new Matrix ();
			
		}
		
		if (__displayObject != null) {
			
			__displayObject.x = value.tx;
			__displayObject.y = value.ty;
			__displayObject.scaleX = Math.sqrt ((value.a * value.a) + (value.b * value.b));
			__displayObject.scaleY = Math.sqrt ((value.c * value.c) + (value.d * value.d));
			__displayObject.rotation = Math.atan2 (value.b, value.a) * (180 / Math.PI);
			
		}
		
		return value;
		
	}
	
	
}