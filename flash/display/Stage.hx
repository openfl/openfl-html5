package flash.display;


import flash.events.Event;
import flash.events.EventPhase;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.ui.KeyLocation;
import js.html.webgl.GL;
import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.webgl.UniformLocation;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.HtmlElement;
import js.Browser;


@:access(flash.events.Event)
class Stage extends Sprite {
	
	
	public var align:StageAlign;
	public var color (get, set):Int;
	public var displayState:StageDisplayState;
	public var focus:InteractiveObject;
	public var frameRate:Float;
	public var scaleMode:StageScaleMode;
	public var stageHeight (default, null):Int;
	public var stageWidth (default, null):Int;
	
	private var __canvas:CanvasElement;
	private var __color:Int;
	private var __colorSplit:Array<Float>;
	private var __colorString:String;
	private var __cursor:String;
	private var __element:HtmlElement;
	private var __eventQueue:Array<js.html.Event>;
	private var __fullscreen:Bool;
	private var __mouseX:Float = 0;
	private var __mouseY:Float = 0;
	private var __originalWidth:Int;
	private var __originalHeight:Int;
	private var __renderSession:RenderSession;
	private var __stack:Array<DisplayObject>;
	#if stats private var __stats:Dynamic; #end
	private var __transparent:Bool;
	
	// WebGL variables
	
	private var __defaultShader:WebGLShader;
	private var __gl:GL;
	private var __glContextID:Int;
	private var __glContextLost:Bool;
	private var __glOptions:Dynamic;
	private var __projection:Point;
	
	// Canvas variables
	
	private var __clearBeforeRender:Bool;
	private var __context:CanvasRenderingContext2D;
	
	
	
	public function new (width:Int, height:Int, element:HtmlElement = null, color:Int = 0xFFFFFF, allowWebGL:Bool = true) {
		
		super ();
		
		__canvas = cast Browser.document.createElement ("canvas");
		__canvas.style.position = "absolute";
		
		__originalWidth = width;
		__originalHeight = height;
		
		if (width == 0 && height == 0) {
			
			if (element != null) {
				
				width = element.clientWidth;
				height = element.clientHeight;
				
			} else {
				
				width = Browser.window.innerWidth;
				height = Browser.window.innerHeight;
				
			}
			
			__fullscreen = true;
			
		}
		
		stageWidth = width;
		stageHeight = height;
		__canvas.width = width;
		__canvas.height = height;
		
		this.__element = element;
		this.color = color;
		
		if (element != null) {
			
			element.appendChild (__canvas);
			
		}
		
		if (!allowWebGL || !__initializeWebGL ()) {
			
			__initializeCanvas ();
			
		}
		
		__resize ();
		
		Browser.window.addEventListener ("resize", window_onResize);
		
		this.stage = this;
		this.parent = this;
		
		__clearBeforeRender = true;
		__eventQueue = [];
		__stack = [];
		
		#if stats
		__stats = untyped __js__("new Stats ()");
		__stats.domElement.style.position = "absolute";
		__stats.domElement.style.top = "0px";
		Browser.document.body.appendChild (__stats.domElement);
		#end
		
		var windowEvents = [ "keydown", "keyup" ];
		var canvasEvents = [ "touchstart", "touchmove", "touchend", "mousedown", "mousemove", "mouseup", "click", "dblclick" ];
		
		for (event in windowEvents) {
			
			Browser.window.addEventListener (event, __queueEvent, false);
			
		}
		
		for (event in canvasEvents) {
			
			__canvas.addEventListener (event, __queueEvent, true);
			
		}
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	public override function globalToLocal (pos:Point):Point {
		
		return pos;
		
	}
	
	
	public override function localToGlobal (pos:Point):Point {
		
		return pos;
		
	}
	
	
	private function __fireEvent (event:Event, stack:Array<DisplayObject>):Void {
		
		var l = stack.length;
		
		if (l > 0) {
			
			event.eventPhase = EventPhase.CAPTURING_PHASE;
			stack.reverse ();
			event.target = stack[0];
			
			for (obj in stack) {
				
				event.currentTarget = obj;
				obj.dispatchEvent (event);
				
				if (event.__isCancelled) {
					
					return;
					
				}
				
			}
			
		}
		
		event.eventPhase = EventPhase.AT_TARGET;
		event.currentTarget = this;
		dispatchEvent (event);
		
		if (event.__isCancelled) {
			
			return;
			
		}
		
		if (event.bubbles) {
			
			event.eventPhase = EventPhase.BUBBLING_PHASE;
			stack.reverse ();
			
			for (obj in stack) {
				
				event.currentTarget = obj;
				obj.dispatchEvent (event);
				
				if (event.__isCancelled) {
					
					return;
					
				}
				
			}
			
		}
		
	}
	
	
	private function __initializeCanvas ():Bool {
		
		__context = untyped __js__ ('this.__canvas.getContext ("2d", { alpha: false })');
		untyped (__context).mozImageSmoothingEnabled = false;
		untyped (__context).webkitImageSmoothingEnabled = false;
		__context.imageSmoothingEnabled = false;
		
		__canvas.style.transform = "translatez(0)";
		
		__renderSession = new RenderSession ();
		__renderSession.context = __context;
		__renderSession.roundPixels = true;
		
		return true;
		
	}
	
	
	private function __initializeWebGL ():Bool {
		
		__canvas.addEventListener ("webglcontextlost", canvas_onContextLost, false);
		__canvas.addEventListener ("webglcontextrestored", canvas_onContextRestored, false);
		
		__glOptions = {
			
			alpha: __transparent,
			antialias: false,
			premultipliedAlpha: __transparent,
			stencil: true
			
		}
		
		try {
			
			__gl = untyped __js__ ('this.__canvas.getContext ("experimental-webgl", this.__glOptions)');
			
		} catch (e:Dynamic) {
			
			try {
				
				__gl = untyped __js__ ('this.__canvas.getContext ("webgl", this.__glOptions)');
				
			} catch (e:Dynamic) {
				
				return false;
				
			}
			
		}
		
		__glContextID = 0;
		__projection = new Point (stageWidth / 2, - stageHeight / 2);
		
		__renderSession = new RenderSession ();
		__renderSession.gl = __gl;
		__renderSession.drawCount = 0;
		
		__defaultShader = new WebGLShader (__gl);
		
		__gl.useProgram (__defaultShader.program);
		
		__gl.disable (GL.DEPTH_TEST);
		__gl.disable (GL.CULL_FACE);
		
		__gl.enable (GL.BLEND);
		__gl.colorMask (true, true, true, __transparent);
		
		return true;
		
	}
	
	
	private function __queueEvent (event:js.html.Event):Void {
		
		__eventQueue.push (event);
		
	}
	
	
	private function __render ():Void {
		
		#if stats
		__stats.begin ();
		#end
		
		__renderable = true;
		__update ();
		
		var event = new Event (Event.ENTER_FRAME);
		__broadcast (event);
		
		if (__gl != null) {
			
			if (!__glContextLost) {
				
				//PIXI.WebGLRenderer.updateTextures();
				
				__gl.viewport (0, 0, stageWidth, stageHeight);
				__gl.bindFramebuffer (GL.FRAMEBUFFER, null);
				
				if (__transparent) {
					
					__gl.clearColor (0, 0, 0 ,0);
					
				} else {
					
					__gl.clearColor (__colorSplit[0], __colorSplit[1], __colorSplit[2], 1);
					
				}
				
				__gl.clear (GL.COLOR_BUFFER_BIT);
				
				__renderSession.drawCount = 0;
				//this.renderSession.currentBlendMode = 9999;
				__renderSession.projection = __projection;
				//this.renderSession.offset = this.offset;
				
				// start the sprite batch
				//this.spriteBatch.begin(this.renderSession);
				
				// start the filter manager
				//this.filterManager.begin(this.renderSession, buffer);
				
				// render the scene!
				//displayObject._renderWebGL(this.renderSession);
				
				__renderWebGL (__renderSession);
				
				// finish the sprite batch
				//this.spriteBatch.end();
				
			}
			
		} else {
			
			__context.setTransform (1, 0, 0, 1, 0, 0);
			__context.globalAlpha = 1;
			
			if (!__transparent && __clearBeforeRender) {
				
				__context.fillStyle = __colorString;
				__context.fillRect (0, 0, stageWidth, stageHeight);
				
			} else if (__transparent && __clearBeforeRender) {
				
				__context.clearRect (0, 0, stageWidth, stageHeight);
				
			}
			
			__renderCanvas (__renderSession);
			
		}
		
		#if stats
		__stats.end ();
		#end
		
		Browser.window.requestAnimationFrame (cast __render);
		
	}
	
	
	private function __resize ():Void {
		
		if (__element != null) {
			
			if (__fullscreen) {
				
				stageWidth = __element.clientWidth;
				stageHeight = __element.clientHeight;
				__canvas.width = stageWidth;
				__canvas.height = stageHeight;
				
				if (__gl != null) {
					
					__gl.viewport (0, 0, stageWidth, stageHeight);
					__projection.x = stageWidth / 2;
					__projection.y = - stageHeight / 2;
					
				}
				
			} else {
				
				var scaleX = __element.clientWidth / __originalWidth;
				var scaleY = __element.clientHeight / __originalHeight;
				
				var currentRatio = scaleX / scaleY;
				var targetRatio = Math.min (scaleX, scaleY);
				
				__canvas.style.width = __originalWidth * targetRatio + "px";
				__canvas.style.height = __originalHeight * targetRatio + "px";
				__canvas.style.marginLeft = ((__element.clientWidth - (__originalWidth * targetRatio)) / 2) + "px";
				__canvas.style.marginTop = ((__element.clientHeight - (__originalHeight * targetRatio)) / 2) + "px";
				
			}
			
		}
		
	}
	
	
	private function __setCursor (cursor:String):Void {
		
		if (__cursor != cursor) {
			
			__canvas.style.cursor = __cursor = cursor;
			
		}
		
	}
	
	
	public override function __update ():Void {
		
		super.__update ();
		
		for (event in __eventQueue) {
			
			switch (event.type) {
				
				case "keydown", "keyup": window_onKey (cast event);
				case "touchstart", "touchend", "touchmove": canvas_onTouch (cast event);
				case "mousedown", "mouseup", "mousemove", "click", "dblclick": canvas_onMouse (cast event);
				default:
				
			}
			
		}
		
		untyped __eventQueue.length = 0;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_mouseX ():Float {
		
		return __mouseX;
		
	}
	
	
	private override function get_mouseY ():Float {
		
		return __mouseY;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function canvas_onContextLost (event:js.html.webgl.ContextEvent):Void {
		
		__glContextLost = true;
		
	}
	
	
	private function canvas_onContextRestored (event:js.html.webgl.ContextEvent):Void {
		
		__glContextLost = false;
		
	}
	
	
	private function canvas_onTouch (event:js.html.TouchEvent):Void {
		
		event.preventDefault ();
		
		var rect = __canvas.getBoundingClientRect ();
		var touch = event.changedTouches[0];
		var point = new Point (touch.pageX - rect.left, touch.pageY - rect.top);
		
		__mouseX = point.x;
		__mouseY = point.y;
		
		__stack = [];
		
		var type = null;
		var mouseType = null;
		
		switch (event.type) {
			
			case "touchstart":
				
				type = TouchEvent.TOUCH_BEGIN;
				mouseType = MouseEvent.MOUSE_DOWN;
			
			case "touchmove":
				
				type = TouchEvent.TOUCH_MOVE;
				mouseType = MouseEvent.MOUSE_MOVE;
			
			case "touchend":
				
				type = TouchEvent.TOUCH_END;
				mouseType = MouseEvent.MOUSE_UP;
			
			default:
			
		}
		
		if (__hitTest (mouseX, mouseY, false, __stack, true)) {
			
			var target = __stack[__stack.length - 1];
			var localPoint = target.globalToLocal (point);
			
			var touchEvent = TouchEvent.__create (type, event, touch, localPoint, cast target);
			touchEvent.touchPointID = touch.identifier;
			touchEvent.isPrimaryTouchPoint = true;
			
			__fireEvent (touchEvent, __stack);
			__fireEvent (MouseEvent.__create (mouseType, cast event, localPoint, cast target), __stack);
			
		} else {
			
			var touchEvent = TouchEvent.__create (type, event, touch, point, this);
			touchEvent.touchPointID = touch.identifier;
			touchEvent.isPrimaryTouchPoint = true;
			
			__fireEvent (touchEvent, [ this ]);
			__fireEvent (MouseEvent.__create (mouseType, cast event, point, this), [ this ]);
			
		}
		
	}
	
	
	private function canvas_onMouse (event:js.html.MouseEvent):Void {
		
		var rect = __canvas.getBoundingClientRect ();
		
		__mouseX = (event.clientX - rect.left) * (__canvas.width / rect.width);
		__mouseY = (event.clientY - rect.top) * (__canvas.height / rect.height);
		
		__stack = [];
		
		var type = switch (event.type) {
			
			case "mousedown": MouseEvent.MOUSE_DOWN;
			case "mouseup": MouseEvent.MOUSE_UP;
			case "mousemove": MouseEvent.MOUSE_MOVE;
			case "click": MouseEvent.CLICK;
			case "dblclick": MouseEvent.DOUBLE_CLICK;
			default: null;
			
		}
		
		if (__hitTest (mouseX, mouseY, false, __stack, true)) {
			
			var target = __stack[__stack.length - 1];
			__setCursor (untyped (target).buttonMode ? "pointer" : "default");
			__fireEvent (MouseEvent.__create (type, event, target.globalToLocal (new Point (mouseX, mouseY)), cast target), __stack);
			
		} else {
			
			__setCursor (buttonMode ? "pointer" : "default");
			__fireEvent (MouseEvent.__create (type, event, new Point (mouseX, mouseY), this), [ this ]);
			
		}
		
	}
	
	
	private function window_onKey (event:js.html.KeyboardEvent):Void {
		
		var keyCode = (event.keyCode != null ? event.keyCode : event.which);
		keyCode = Keyboard.__convertMozillaCode (keyCode);
		
		dispatchEvent (new KeyboardEvent (event.type == "keydown" ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP, true, false, event.charCode, keyCode, event.keyLocation != null ? cast (event.keyLocation, KeyLocation) : KeyLocation.STANDARD, event.ctrlKey, event.altKey, event.shiftKey));
		
	}
	
	
	private function window_onResize (event:js.html.Event):Void {
		
		__resize ();
		
		var event = new Event (Event.RESIZE);
		__broadcast (event);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_color ():Int {
		
		return __color;
		
	}
	
	
	private function set_color (value:Int):Int {
		
		var r = (value & 0xFF0000) >>> 16;
		var g = (value & 0x00FF00) >>> 8;
		var b = (value & 0x0000FF);
		
		__colorSplit = [ r / 0xFF, g / 0xFF, b / 0xFF ];
		__colorString = "#" + StringTools.hex (value, 6);
		return __color = value;
		
	}
	
	
}


class RenderSession {
	
	
	public var context:CanvasRenderingContext2D;
	public var drawCount:Int;
	public var gl:GL;
	public var projection:Point;
	public var roundPixels:Bool;
	
	
	public function new () {
		
		
		
	}
	
	
}


class WebGLShaderUniform {
	
	
	public var glFunc:Dynamic;
	public var glMatrix:Bool;
	public var glValueLength:Int;
	public var textureData:Dynamic;
	public var transpose:Dynamic;
	public var type:String;
	public var uniformLocation:UniformLocation;
	public var _init:Bool;
	public var value:Dynamic;
	
	
	public function new () {
		
		
		
	}
	
	
}


class WebGLShader {
	
	
	public var attributes = new Array<Dynamic> ();
	public var aTextureCoord:Int;
	public var aVertexPosition:Int;
	public var colorAttribute:Int;
	public var dimensions:UniformLocation;
	public var fragmentSource:Array<String>;
	public var vertexSource:Array<String>;
	public var gl:GL;
	public var offsetVector:UniformLocation;
	public var program:Program;
	public var projectionVector:UniformLocation;
	public var textureCount = 0;
	public var uniforms = new Map<String, WebGLShaderUniform> ();
	public var uSampler:UniformLocation;
	
	
	public function new (gl:GL) {
		
		this.gl = gl;
		
		vertexSource = [
			
			'attribute vec2 aVertexPosition;',
			'attribute vec2 aTextureCoord;',
			'attribute vec2 aColor;',
			
			'uniform vec2 projectionVector;',
			'uniform vec2 offsetVector;',
			
			'varying vec2 vTextureCoord;',
			'varying vec4 vColor;',
			
			'const vec2 center = vec2(-1.0, 1.0);',
			
			'void main(void) {',
			' gl_Position = vec4( ((aVertexPosition + offsetVector) / projectionVector) + center , 0.0, 1.0);',
			' vTextureCoord = aTextureCoord;',
			' vec3 color = mod(vec3(aColor.y/65536.0, aColor.y/256.0, aColor.y), 256.0) / 256.0;',
			' vColor = vec4(color * aColor.x, aColor.x);',
			'}'
			
		];
		
		fragmentSource = [
			
			'precision lowp float;',
			'varying vec2 vTextureCoord;',
			'varying vec4 vColor;',
			'uniform sampler2D uSampler;',
			'void main(void) {',
			'   gl_FragColor = texture2D(uSampler, vTextureCoord) * vColor ;',
			'}'
			
		];
		
		init ();
		
	}
	
	
	private static function compileProgram (gl:GL, vertexSource:Array<String>, fragmentSource:Array<String>):Program {
		
		var fragmentShader = compileShader (gl, fragmentSource, GL.FRAGMENT_SHADER);
		var vertexShader = compileShader (gl, vertexSource, GL.VERTEX_SHADER);
		
		var shaderProgram = gl.createProgram ();
		
		gl.attachShader (shaderProgram, vertexShader);
		gl.attachShader (shaderProgram, fragmentShader);
		gl.linkProgram (shaderProgram);
		
		if (!gl.getProgramParameter (shaderProgram, GL.LINK_STATUS)) {
			
			trace ("Could not initialize shaders");
			
		}
		
		return shaderProgram;
		
	}
	
	
	private static function compileShader (gl:GL, source:Array<String>, type:Int):Shader {
		
		var shader = gl.createShader (type);
		
		gl.shaderSource (shader, source.join ("\n"));
		gl.compileShader (shader);
		
		if (!gl.getShaderParameter (shader, GL.COMPILE_STATUS)) {
			
			trace (gl.getShaderInfoLog (shader));
			return null;
			
		}
		
		return shader;
		
	}
	
	
	public function destroy ():Void {
		
		gl.deleteProgram (program);
		uniforms = null;
		gl = null;
		
		attributes = null;
		
	}
	
	
	private function init ():Void {
		
		var program = compileProgram (gl, vertexSource, fragmentSource);
		
		gl.useProgram(program);
		
		uSampler = gl.getUniformLocation (program, 'uSampler');
		projectionVector = gl.getUniformLocation (program, 'projectionVector');
		offsetVector = gl.getUniformLocation (program, 'offsetVector');
		dimensions = gl.getUniformLocation (program, 'dimensions');
		
		aVertexPosition = gl.getAttribLocation (program, 'aVertexPosition');
		aTextureCoord = gl.getAttribLocation (program, 'aTextureCoord');
		colorAttribute = gl.getAttribLocation (program, 'aColor');
		
		for (key in uniforms.keys ()) {
			
			uniforms.get (key).uniformLocation = untyped __js__ ("this.gl.getUniform (this.program, key)");
			
		}
		
		initUniforms();
		
		this.program = program;
		
	}
	
	
	private function initSampler2D (uniform:WebGLShaderUniform):Void {
		
		if (uniform.value == null || uniform.value.baseTexture == null || !uniform.value.baseTexture.hasLoaded) {
			
			return;
			
		}
		
		gl.activeTexture (Reflect.field (GL, 'TEXTURE' + this.textureCount));
		gl.bindTexture (GL.TEXTURE_2D, uniform.value.baseTexture._glTexture);
		
		//  Extended texture data
		if (uniform.textureData != null) {
			
			var data = uniform.textureData;

			// GLTexture = mag linear, min linear_mipmap_linear, wrap repeat + gl.generateMipmap(gl.TEXTURE_2D);
			// GLTextureLinear = mag/min linear, wrap clamp
			// GLTextureNearestRepeat = mag/min NEAREST, wrap repeat
			// GLTextureNearest = mag/min nearest, wrap clamp
			// AudioTexture = whatever + luminance + width 512, height 2, border 0
			// KeyTexture = whatever + luminance + width 256, height 2, border 0

			//  magFilter can be: gl.LINEAR, gl.LINEAR_MIPMAP_LINEAR or gl.NEAREST
			//  wrapS/T can be: gl.CLAMP_TO_EDGE or gl.REPEAT
			
			var magFilter = (data.magFilter != null) ? data.magFilter : GL.LINEAR;
			var minFilter = (data.minFilter != null) ? data.minFilter : GL.LINEAR;
			var wrapS = (data.wrapS != null) ? data.wrapS : GL.CLAMP_TO_EDGE;
			var wrapT = (data.wrapT != null) ? data.wrapT : GL.CLAMP_TO_EDGE;
			var format = (data.luminance) ? GL.LUMINANCE : GL.RGBA;
			
			if (data.repeat) {
				
				wrapS = GL.REPEAT;
				wrapT = GL.REPEAT;
				
			}
			
			gl.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, data.flipY);
						
			if (data.width != null) {
				
				var width = (data.width != null) ? data.width : 512;
				var height = (data.height != null) ? data.height : 2;
				var border = (data.border != null) ? data.border : 0;
				
				// void texImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, ArrayBufferView? pixels);
				gl.texImage2D (GL.TEXTURE_2D, 0, format, width, height, border, format, GL.UNSIGNED_BYTE, null);
				
			} else {
				
				//  void texImage2D(GLenum target, GLint level, GLenum internalformat, GLenum format, GLenum type, ImageData? pixels);
				gl.texImage2D (GL.TEXTURE_2D, 0, format, GL.RGBA, GL.UNSIGNED_BYTE, uniform.value.baseTexture.source);
				
			}
			
			gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, magFilter);
			gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, minFilter);
			gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, wrapS);
			gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, wrapT);
			
		}

		gl.uniform1i (uniform.uniformLocation, textureCount);
		uniform._init = true;
		textureCount++;

	}
	
	
	private function initUniforms ():Void {
		
		textureCount = 1;
		
		for (uniform in uniforms) {
			
			var type = uniform.type;
			
			if (type == "sampler2D") {
				
				uniform._init = false;
				
				if (uniform.value != null) {
					
					initSampler2D (uniform);
					
				}
				
			} else if (type == "mat2" || type == "mat3" || type == "mat4") {
				
				uniform.glMatrix = true;
				uniform.glValueLength = 1;

				if (type == "mat2") {
					
					uniform.glFunc = gl.uniformMatrix2fv;
					
				} else if (type == "mat3") {
					
					uniform.glFunc = gl.uniformMatrix3fv;
					
				} else if (type == "mat4") {
					
					uniform.glFunc = gl.uniformMatrix4fv;
					
				}
				
			} else {
				
				uniform.glFunc = Reflect.field (gl, "uniform" + type);
				
				if (type == "2f" || type == "2i") {
					
					uniform.glValueLength = 2;
					
				} else if (type == "3f" || type == "3i") {
					
					uniform.glValueLength = 3;
					
				} else if (type == "4f" || type == "4i") {
					
					uniform.glValueLength = 4;
					
				} else {
					
					uniform.glValueLength = 1;
					
				}
				
			}
			
		}
		
	}
	
	
	private function syncUniforms ():Void {
		
		textureCount = 1;
		var uniform;
		
		for (uniform in uniforms) {
			
			if (uniform.glValueLength == 1) {
				
				if (uniform.glMatrix) {
					
					uniform.glFunc (gl, uniform.uniformLocation, uniform.transpose, uniform.value);
					
				} else {
					
					uniform.glFunc (gl, uniform.uniformLocation, uniform.value);
					
				}
				
			} else if (uniform.glValueLength == 2) {
				
				uniform.glFunc (gl, uniform.uniformLocation, uniform.value.x, uniform.value.y);
				
			} else if (uniform.glValueLength == 3) {
				
				uniform.glFunc (gl, uniform.uniformLocation, uniform.value.x, uniform.value.y, uniform.value.z);
				
			} else if (uniform.glValueLength == 4) {
				
				uniform.glFunc (gl, uniform.uniformLocation, uniform.value.x, uniform.value.y, uniform.value.z, uniform.value.w);
				
			} else if (uniform.type == "sampler2D") {
				
				if (uniform._init) {
					
					gl.activeTexture (Reflect.field (gl, "TEXTURE" + this.textureCount));
					//gl.bindTexture (GL.TEXTURE_2D, uniform.value.baseTexture._glTextures[gl.id] || PIXI.createWebGLTexture (uniform.value.baseTexture, gl));
					gl.uniform1i (uniform.uniformLocation, textureCount);
					textureCount++;
					
				} else {
					
					initSampler2D (uniform);
					
				}
				
			}
			
		}
		
	}
	
	
}