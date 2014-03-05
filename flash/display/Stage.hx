package flash.display;


import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;


class Stage extends Sprite {
	
	
	public var backgroundColor (get, set):Int;
	public var stageHeight (default, null):Int;
	public var stageWidth (default, null):Int;
	
	private var __backgroundColor:Int;
	private var __backgroundColorString:String;
	private var __canvas:CanvasElement;
	private var __clearBeforeRender:Bool;
	private var __context:CanvasRenderingContext2D;
	//private var __dirty:Bool;
	private var __renderSession:RenderSession;
	private var __stats:Dynamic;
	private var __transparent:Bool;
	
	
	
	public function new (width:Int, height:Int) {
		
		super ();
		
		backgroundColor = 0xFFFFFF;
		
		__canvas = cast Browser.document.createElement ("canvas");
		
		__context = untyped __js__ ('this.__canvas.getContext ("2d", { alpha: false })');
		untyped (__context).mozImageSmoothingEnabled = false;
		untyped (__context).webkitImageSmoothingEnabled = false;
		__context.imageSmoothingEnabled = false;
		
		__canvas.style.transform = "translatez(0)";
		__canvas.style.position = "absolute";
		
		Browser.document.body.appendChild (__canvas);
		
		stageWidth = width;
		stageHeight = height;
		__canvas.width = width;
		__canvas.height = height;
		
		this.stage = this;
		this.parent = this;
		
		__clearBeforeRender = true;
		
		__renderSession = new RenderSession ();
		__renderSession.context = __context;
		__renderSession.roundPixels = true;
		
		__stats = untyped __js__("new Stats ()");
		__stats.domElement.style.position = "absolute";
		__stats.domElement.style.top = "0px";
		Browser.document.body.appendChild (__stats.domElement);
		
		Browser.window.addEventListener ("keydown", window_onKey, false);
		Browser.window.addEventListener ("keyup", window_onKey, false);
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	private function __render ():Void {
		
		__stats.begin ();
		
		__renderable = true;
		__update ();
		
		__context.setTransform (1, 0, 0, 1, 0, 0);
		__context.globalAlpha = 1;
		
		if (!__transparent && __clearBeforeRender) {
			
			__context.fillStyle = __backgroundColorString;
			__context.fillRect (0, 0, stageWidth, stageHeight);
			
		} else if (__transparent && __clearBeforeRender) {
			
			__context.clearRect (0, 0, stageWidth, stageHeight);
			
		}
		
		__renderCanvas (__renderSession);
		
		/*// run interaction!
		if(stage.interactive) {
			
			//need to add some events!
			if(!stage._interactiveEventsAdded) {
				
				stage._interactiveEventsAdded = true;
				stage.interactionManager.setTarget(this);
				
			}
			
		}

		// remove frame updates..
		if(PIXI.Texture.frameUpdates.length > 0) {
			
			PIXI.Texture.frameUpdates.length = 0;
			
		}*/
		
		__stats.end ();
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function window_onKey (event:js.html.KeyboardEvent):Void {
		
		var keyCode = (event.keyCode != null ? event.keyCode : event.which);
		keyCode = Keyboard.__convertMozillaCode (keyCode);
		
		dispatchEvent (new KeyboardEvent (event.type == "keydown" ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP, true, false, event.charCode, keyCode, event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey));
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_backgroundColor ():Int {
		
		return __backgroundColor;
		
	}
	
	
	private function set_backgroundColor (value:Int):Int {
		
		//this.backgroundColorSplit = PIXI.hex2rgb(this.backgroundColor);
		//var hex = this.backgroundColor.toString (16);
		//hex = '000000'.substr(0, 6 - hex.length) + hex;
		__backgroundColorString = "#" + StringTools.hex (value, 6);
		
		return __backgroundColor = value;
		
	}
	
	
}


class RenderSession {
	
	
	public var context:CanvasRenderingContext2D;
	//public var maskManager:MaskManager;
	//public var scaleMode:ScaleMode;
	public var roundPixels:Bool;
	//public var smoothProperty:Null<Bool> = null;
	
	
	public function new () {
		
		
		
	}
	
	
}