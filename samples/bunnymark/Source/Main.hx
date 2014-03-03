package;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;


class Main extends Sprite {
	
	
	private var addingBunnies:Bool;
	private var bunnies:Array<Bunny>;
	private var bunniesRate:Int;
	private var maxX:Float;
	private var maxY:Float;
	private var minX:Float;
	private var minY:Float;
	private var numBunnies:Int;
	
	private static var instance:Main;
	
	
	public function new () {
		
		super ();
		
		instance = this;
		
		bunniesRate = 5;
		numBunnies = 4000;
		bunnies = new Array<Bunny> ();
		
		maxX = stage.stageWidth;
		minX = 0;
		maxY = stage.stageHeight;
		minY = 0;
		
		for (i in 0...numBunnies) {
			
			var bunny = new Bunny ();
			bunny.speedX = Math.random () * 10;
			bunny.speedY = (Math.random () * 10) - 5;
			//bunny.anchor.x = 0.5;
			//bunny.anchor.y = 1;
			bunnies.push (bunny);
			addChild (bunny);
			
		}
		
		//addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
		
	}
	
	
	public static function update ():Void {
		
		if (instance != null) {
			
			instance.this_onEnterFrame ();
			
		}
		
	}
	
	
	public function this_onEnterFrame (/*event:Event*/):Void {
		
		if (addingBunnies) {
			
			for (i in 0...bunniesRate) {
				
				var bunny = new Bunny ();
				bunny.speedX = Math.random () * 10;
				bunny.speedY = (Math.random () * 10) - 5;
				//bunny.anchor.x = 0.5;
				//bunny.anchor.y = 1;
				bunnies.push (bunny);
				//bunny.scale.y = 1;
				//container.addChild (bunny);
				addChild (bunny);
				numBunnies++;
				
			}
			
			//counter.innerHTML = numBunnies + " BUNNIES";
			
		}
		
		for (i in 0...bunnies.length) {
			
			var bunny = bunnies[i];
			
			bunny.x += bunny.speedX;
			bunny.y += bunny.speedY;
			bunny.speedY += 0.75;
			
			if (bunny.x > maxX) {
				
				bunny.speedX *= -1;
				bunny.x = maxX;
				
			} else if (bunny.x < minX) {
				
				bunny.speedX *= -1;
				bunny.x = minX;
				
			}
			
			if (bunny.y > maxY) {
				
				bunny.speedY *= -0.85;
				bunny.y = maxY;
				bunny.spin = (Math.random () - 0.5) * 0.2;
				
				if (Math.random () > 0.5) {
					
					bunny.speedY -= Math.random () * 6;
					
				}
				
			} else if (bunny.y < minY) {
				
				bunny.speedY = 0;
				bunny.y = minY;
				
			}
			
		}
		
	}
	
	
}


class Bunny extends Bitmap {
	
	
	private static var bunnyTexture:BitmapData;
	
	public var speedX:Float;
	public var speedY:Float;
	public var spin:Float;
	
	
	public function new () {
		
		if (bunnyTexture == null) {
			
			bunnyTexture = new BitmapData ();
			
		}
		
		super (bunnyTexture);
		
	}
	
	
}