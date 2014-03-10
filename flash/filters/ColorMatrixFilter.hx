package flash.filters;


class ColorMatrixFilter extends BitmapFilter {
	
	
	public var matrix:Array<Float>;
	
	
	public function new (matrix:Array<Float> = null) {
		
		super ();
		
		this.matrix = matrix;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new ColorMatrixFilter ();
		
	}
	
	
}