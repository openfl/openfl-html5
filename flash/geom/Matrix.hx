package flash.geom;


class Matrix {
	
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	
	
	public function new (a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
		
	}
	
	
}