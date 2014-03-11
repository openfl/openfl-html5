package flash.display;


import flash.display.Stage;
import flash.errors.IOError;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Image;
import js.html.ImageData;
import js.html.Uint8ClampedArray;
import js.Browser;


@:autoBuild(openfl.Assets.embedBitmap())
class BitmapData implements IBitmapDrawable {
	
	
	private static var __base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	private static var __base64Encoder:BaseCode;
	
	public var height (default, null):Int;
	public var rect (default, null):Rectangle;
	public var transparent (default, null):Bool;
	public var width (default, null):Int;
	
	public var __worldTransform:Matrix;
	
	private var __loading:Bool;
	private var __sourceCanvas:CanvasElement;
	private var __sourceContext:CanvasRenderingContext2D;
	private var __sourceImage:Image;
	private var __sourceImageData:ImageData;
	private var __sourceImageDataChanged:Bool;
	
	
	public function new (width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF) {
		
		this.transparent = transparent;
		
		if (width > 0 && height > 0) {
			
			this.width = width;
			this.height = height;
			rect = new Rectangle (0, 0, width, height);
			
			__sourceCanvas = cast Browser.window.document.createElement ("canvas");
			__sourceCanvas.width = width;
			__sourceCanvas.height = height;
			
			__sourceContext = __sourceCanvas.getContext ("2d");
			
			if (!transparent) {
				
				fillColor = (0xFF << 24) | (fillColor & 0xFFFFFF);
				
			}
			
			__fillRect (new Rectangle (0, 0, width, height), fillColor);
			
		}
		
	}
	
	
	public function applyFilter (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void {
		
		/*if (sourceBitmapData == this && sourceRect.x == destPoint.x && sourceRect.y == destPoint.y) {
			
			filter.__applyFilter (handle (), sourceRect);
			
		} else {
			
			var bitmapData = new BitmapData (Std.int (sourceRect.width), Std.int (sourceRect.height));
			bitmapData.copyPixels (sourceBitmapData, sourceRect, new Point());
			filter.__applyFilter (bitmapData.handle ());
			
			copyPixels (bitmapData, bitmapData.rect, destPoint);
			
		}*/
		
	}
	
	
	public function clone ():BitmapData {
		
		if (__sourceImage != null) {
			
			return BitmapData.fromImage (__sourceImage, transparent);
			
		} else {
			
			return BitmapData.fromCanvas (__sourceCanvas, transparent);
			
		}
		
	}
	
	
	public function colorTransform (rect:Rectangle, colorTransform:ColorTransform) {
		
		// TODO, could we handle this with 'destination-atop' or 'source-atop' composition modes instead?
		
		if (rect == null || __loading) return;
		rect = __clipRect (rect);
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		var data = __sourceImageData.data;
		var stride = width * 4;
		var offset:Int;
		
		for (row in Std.int (rect.y)...Std.int (rect.height)) {
			
			for (column in Std.int (rect.x)...Std.int (rect.width)) {
				
				offset = (row * stride) + (column * 4);
				
				data[offset] = Std.int ((data[offset] * colorTransform.redMultiplier) + colorTransform.redOffset);
				data[offset + 1] = Std.int ((data[offset + 1] * colorTransform.greenMultiplier) + colorTransform.greenOffset);
				data[offset + 2] = Std.int ((data[offset + 2] * colorTransform.blueMultiplier) + colorTransform.blueOffset);
				data[offset + 3] = Std.int ((data[offset + 3] * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
				
			}
			
		}
		
		__sourceImageDataChanged = true;
		
	}
	
	
	public function copyChannel (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:Int, destChannel:Int):Void {
		
		if (__loading || sourceRect == null) return;
		sourceRect = __clipRect (sourceRect);
		
		if (destChannel == BitmapDataChannel.ALPHA && !transparent) return;
		if (sourceRect.width <= 0 || sourceRect.height <= 0) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.width) sourceRect.width = sourceBitmapData.width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.height) sourceRect.height = sourceBitmapData.height - sourceRect.y;
		
		var destIdx = -1;
		
		if (destChannel == BitmapDataChannel.ALPHA) { 
			
			destIdx = 3;
			
		} else if (destChannel == BitmapDataChannel.BLUE) {
			
			destIdx = 2;
			
		} else if (destChannel == BitmapDataChannel.GREEN) {
			
			destIdx = 1;
			
		} else if (destChannel == BitmapDataChannel.RED) {
			
			destIdx = 0;
			
		} else {
			
			throw "Invalid destination BitmapDataChannel passed to BitmapData::copyChannel.";
			
		}
		
		var srcIdx = -1;
		
		if (sourceChannel == BitmapDataChannel.ALPHA) {
			
			srcIdx = 3;
			
		} else if (sourceChannel == BitmapDataChannel.BLUE) {
			
			srcIdx = 2;
			
		} else if (sourceChannel == BitmapDataChannel.GREEN) {
			
			srcIdx = 1;
			
		} else if (sourceChannel == BitmapDataChannel.RED) {
			
			srcIdx = 0;
			
		} else {
			
			throw "Invalid source BitmapDataChannel passed to BitmapData::copyChannel.";
			
		}
		
		__convertToCanvas ();
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		/*sourceBitmapData.__convertToCanvas ();
		
		if (sourceBitmapData.__sourceImageData == null) {
			
			sourceBitmapData.__sourceImageData = sourceBitmapData.__sourceContext.getImageData (0, 0, sourceBitmapData.width, sourceBitmapData.height);
			
		}*/
		
		var data = __sourceImageData.data;
		sourceBitmapData.__convertToCanvas ();
		var sourceData = sourceBitmapData.__sourceContext.getImageData (sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height).data;
		
		var pos = 4 * (Math.round (destPoint.x) + (Math.round (destPoint.y) * width)) + destIdx;
		var boundR = Math.round (4 * (destPoint.x + sourceRect.width));
		
		while (srcIdx < sourceData.length) {
			
			if ((pos % (width * 4)) > boundR - 1) {
				
				pos += width * 4 - boundR;
				
			}
			
			data[pos] = sourceData[srcIdx];
			pos += 4;
			srcIdx += 4;
			
		}
	
		__sourceImageDataChanged = true;
		
	}
	
	
	public function copyPixels (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void {
		
		if (__loading) return;
		
		//if (sourceBitmapData.handle () == null || ___textureBuffer == null || sourceBitmapData.handle ().width == 0 || sourceBitmapData.handle ().height == 0 || sourceRect.width <= 0 || sourceRect.height <= 0 ) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.width) sourceRect.width = sourceBitmapData.width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.height) sourceRect.height = sourceBitmapData.height - sourceRect.y;
		
		if (alphaBitmapData != null && alphaBitmapData.transparent) {
			
			if (alphaPoint == null) alphaPoint = new Point ();
			
			var tempData = clone ();
			tempData.copyChannel (alphaBitmapData, new Rectangle (alphaPoint.x, alphaPoint.y, sourceRect.width, sourceRect.height), new Point (sourceRect.x, sourceRect.y), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			sourceBitmapData = tempData;
			
		}
		
		// TODO: Would it be faster to stick with image data, if we're already using it?
		
		//__convertToCanvas ();
		
		if (__sourceImageDataChanged) {
			
			__sourceContext.putImageData (__sourceImageData, 0, 0);
			__sourceImageData = null;
			__sourceImageDataChanged = false;
			
		}
		
		/*if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}*/
		
		//if (__sourceImageData == null) {
		
		/*if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			*/
			if (!mergeAlpha) {
				
				if (transparent && sourceBitmapData.transparent) {
					
					// TODO: Handle alpha merge. Better way to do this?
					
					//var trpCtx:CanvasRenderingContext2D = sourceBitmapData.__transparentFiller.getContext ('2d');
					//var trpData = trpCtx.getImageData (sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
					//ctx.putImageData (trpData, destPoint.x, destPoint.y);
					
				}
				
			}
			
			if (sourceBitmapData.__sourceImage != null) {
				
				__sourceContext.drawImage (sourceBitmapData.__sourceImage, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
				
			} else if (sourceBitmapData.__sourceCanvas != null) {
				
				__sourceContext.drawImage (sourceBitmapData.__sourceCanvas, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
				
			}
			
			//__sourceImageData = null;
			
			
		/*} else {
			
			var offsetX = Std.int (destPoint.x - sourceRect.x);
			var offsetY = Std.int (destPoint.y - sourceRect.y);
			var sourceRectX = Std.int (sourceRect.x);
			var sourceRectY = Std.int (sourceRect.y);
			var sourceRectWidth = Std.int (sourceRect.width);
			var sourceRectHeight = Std.int (sourceRect.height);
			var targetData = __sourceImageData.data;
			
			if (sourceBitmapData.__sourceImageData == null) {
				
				sourceBitmapData.__convertToCanvas ();
				
				if (sourceBitmapData.__sourceImageData == null) {
					
					sourceBitmapData.__sourceImageData = sourceBitmapData.__sourceContext.getImageData (0, 0, sourceBitmapData.width, sourceBitmapData.height);
					
				}
				
			}
			
			var sourceData = sourceBitmapData.__sourceImageData.data;
			var targetWidth = width;
			var sourceWidth = sourceBitmapData.width;
			
			if (alphaBitmapData != null && alphaBitmapData.transparent) {
				
				if (alphaPoint == null) alphaPoint = new Point ();
				
				alphaBitmapData.__convertToCanvas ();
				
				if (alphaBitmapData.__sourceImageData == null) {
					
					alphaBitmapData.__sourceImageData = alphaBitmapData.__sourceContext.getImageData (0, 0, alphaBitmapData.width, alphaBitmapData.height);
					
				}
				//trace ("hey");
				var alphaOffsetX = Std.int (destPoint.x - alphaPoint.x);
				var alphaOffsetY = Std.int (destPoint.y - alphaPoint.y);
				var alphaData = alphaBitmapData.__sourceImageData.data;
				
				for (sourceX in sourceRectX...sourceRectWidth + 1) {
					
					for (sourceY in sourceRectY...sourceRectHeight + 1) {
						
						var sourceOffset = ((sourceX * sourceWidth) * 4 + sourceX * 4);
						var targetOffset = (((sourceX + offsetX) * targetWidth) * 4 + (sourceX + offsetX) * 4);
						var alphaOffset = ((sourceX * sourceWidth) * 4 + sourceX * 4);
						
						targetData[targetOffset] = sourceData[sourceOffset];
						targetData[targetOffset+1] = sourceData[sourceOffset+1];
						targetData[targetOffset+2] = sourceData[sourceOffset+2];
						targetData[targetOffset+3] = sourceData[alphaOffset+3];
						
					}
					
				}
				
				
			} else {
				
				for (sourceX in sourceRectX...sourceRectWidth + 1) {
					
					for (sourceY in sourceRectY...sourceRectHeight + 1) {
						
						var sourceOffset = ((sourceX * sourceWidth) * 4 + sourceX * 4);
						var targetOffset = (((sourceX + offsetX) * targetWidth) * 4 + (sourceX + offsetX) * 4);
						
						targetData[targetOffset] = sourceData[sourceOffset];
						targetData[targetOffset+1] = sourceData[sourceOffset+1];
						targetData[targetOffset+2] = sourceData[sourceOffset+2];
						targetData[targetOffset+3] = sourceData[sourceOffset+3];
						
					}
					
				}
				
			}
			
			__sourceImageDataChanged = true;
		}*/
		
	}
	
	
	public function dispose ():Void {
		
		__sourceImage = null;
		__sourceCanvas = null;
		__sourceContext = null;
		width = 0;
		height = 0;
		
	}
	
	
	public function draw (source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false):Void {
		
		if (__loading) return;
		
		__convertToCanvas ();
		
		if (__sourceImageData != null) {
			
			__sourceContext.putImageData (__sourceImageData, 0, 0);
			__sourceImageData = null;
			
		}
		
		var renderSession = new RenderSession ();
		renderSession.context = __sourceContext;
		renderSession.roundPixels = true;
		
		var matrixCache = source.__worldTransform;
		source.__worldTransform = matrix != null ? matrix : new Matrix ();
		source.__update ();
		source.__worldTransform = matrixCache;
		
		__convertToCanvas ();
		source.__renderCanvas (renderSession);
		
		// TODO: Need to handle matrix properly, etc.
		
		//source.__renderCanvas (__sourceCanvas);
		
		/*
		__buildLease ();
		source.drawToSurface (handle (), matrix, colorTransform, blendMode, clipRect, smoothing);
		
		if (colorTransform != null) {
			
			var rect = new Rectangle ();
			var object:DisplayObject = cast source;
			
			rect.x = matrix != null ? matrix.tx : 0;
			rect.y = matrix != null ? matrix.ty : 0;
			
			try {
				
				rect.width = Reflect.getProperty (source, "width");
				rect.height = Reflect.getProperty (source, "height");
				
			} catch(e:Dynamic) {
				
				rect.width = handle ().width;
				rect.height = handle ().height;
				
			}
			
			this.colorTransform (rect, colorTransform);
			
		}*/
		
	}
	
	
	public function fillRect (rect:Rectangle, color:Int):Void {
		
		if (__loading) return;
		
		// TODO: Re-use __sourceImageData if in use?
		
		if (__sourceImageData != null) {
			
			__sourceContext.putImageData (__sourceImageData, 0, 0);
			__sourceImageData = null;
			
		}
		
		if (rect == null || rect.width <= 0 || rect.height <= 0) return;
		
		if (rect.x == 0 && rect.y == 0 && rect.width == width && rect.height == height) {
			
			if (__sourceImage != null) {
				
				if (__sourceCanvas == null) {
					
					__sourceCanvas = cast Browser.document.createElement ("canvas");
					__sourceCanvas.width = width;
					__sourceCanvas.height = height;
					__sourceContext = __sourceCanvas.getContext ("2d");
					
				}
				
				__sourceImage = null;
				
			}
			
			if (transparent && ((color & 0xFF000000) == 0)) {
				
				__sourceCanvas.width = width;
				return;
				
			}
			
		}
		
		__convertToCanvas ();
		__fillRect (rect, color);
		
	}
	
	
	public function floodFill (x:Int, y:Int, color:Int):Void {
		
		if (__loading) return;
		
		__convertToCanvas ();
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		var data = __sourceImageData.data;
		
		var offset = ((y * (width * 4)) + (x * 4));
        var hitColor = data[offset + 0] << 24;
        hitColor |= data[offset + 1] << 16;
        hitColor |= data[offset + 2] << 8;
        if (transparent) hitColor |= data[offset + 3];
        
		var dx = [ 0, -1, 1, 0 ];
		var dy = [ -1, 0, 0, 1 ];
		
		var queue = new Array<Int> ();
		queue.push (x);
		queue.push (y);
		
		var r = (color & 0xFF0000) >>> 16;
		var g = (color & 0x00FF00) >>> 8;
		var b = (color & 0x0000FF);
		var a = transparent ? (color & 0xFF000000) >>> 24 : 0xFF;
		
		while (queue.length > 0) {
			
			var curPointY = queue.pop ();
			var curPointX = queue.pop ();
			
			for (i in 0...4) {
				
				var nextPointX = curPointX + dx[i];
				var nextPointY = curPointY + dy[i];
				
				if (nextPointX < 0 || nextPointY < 0 || nextPointX >= width || nextPointY >= height) {
					
					continue;
					
				}
				
				var nextPointOffset = (nextPointY * width + nextPointX) * 4;
				
				if (data[nextPointOffset + 0] == ((hitColor >> 24) & 0xFF) && data[nextPointOffset + 1] == ((hitColor >> 16) & 0xFF) && data[nextPointOffset + 2] == ((hitColor >> 8) & 0xFF) && data[nextPointOffset + 3] == ((hitColor) & 0xFF)) {
					
					data[nextPointOffset + 0] = r;
					data[nextPointOffset + 1] = g;
					data[nextPointOffset + 2] = b;
					data[nextPointOffset + 3] = a;
				    
					queue.push(nextPointX);
					queue.push(nextPointY);
					
				}
				
			}
			
		}
		
		__sourceImageDataChanged = true;
		
	}
	
	
	public static function fromBase64 (base64:String, type:String, onload:BitmapData -> Void):BitmapData {
		
		var bitmapData = new BitmapData (0, 0);
		bitmapData.__loadFromBase64 (base64, type, onload);
		return bitmapData;
		
	}
	
	
	public static function fromBytes (bytes:ByteArray, rawAlpha:ByteArray = null, onload:BitmapData -> Void):BitmapData {
		
		var bitmapData = new BitmapData (0, 0);
		bitmapData.__loadFromBytes (bytes, rawAlpha, onload);
		return bitmapData;
		
	}
	
	
	public static function fromImage (image:Image, transparent:Bool = true):BitmapData {
		
		var bitmapData = new BitmapData (0, 0, transparent);
		bitmapData.__sourceImage = image;
		bitmapData.width = image.width;
		bitmapData.height = image.height;
		
		return bitmapData;
		
	}
	
	
	public static function fromCanvas (canvas:CanvasElement, transparent:Bool = true):BitmapData {
		
		var bitmapData = new BitmapData (0, 0, transparent);
		bitmapData.__sourceCanvas = cast Browser.document.createElement ("canvas");
		bitmapData.__sourceCanvas.width = bitmapData.width = canvas.width;
		bitmapData.__sourceCanvas.height = bitmapData.height = canvas.height;
		bitmapData.__sourceContext = bitmapData.__sourceCanvas.getContext ("2d");
		bitmapData.__sourceContext.drawImage (canvas, 0, 0);
		
		return bitmapData;
		
	}
	
	
	public function getPixel (x:Int, y:Int):Int {
		
		if (x < 0 || y < 0 || x >= width || y >= height || __loading) return 0;
		
		__convertToCanvas ();
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		/*if (__sourceImageData == null) {
			
			var pixel = __sourceContext.getImageData (x, y, 1, 1);
			return (pixel.data[0] << 16) | (pixel.data[1] << 8) | (pixel.data[2]);
			
		} else {*/
			
			var offset = (4 * y * width + x * 4);
			return (__sourceImageData.data[offset] << 16) | (__sourceImageData.data[offset + 1] << 8) | (__sourceImageData.data[offset + 2]);
			
		//}
		
	}
	
	
	public function getPixel32 (x:Int, y:Int) {
		
		if (x < 0 || y < 0 || x >= width || y >= height || __loading) return 0;
		
		__convertToCanvas ();
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		/*if (__sourceImageData == null) {
			
			return __getInt32 (0, __sourceContext.getImageData (x, y, 1, 1).data);
			
		} else {*/
			
			return __getInt32 ((4 * y * width + x * 4), __sourceImageData.data);
			
		//}
		
	}
	
	
	public function getPixels (rect:Rectangle):ByteArray {
		
		if (__loading) return null;
		
		__convertToCanvas ();
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		var byteArray = new ByteArray ();
		byteArray.length = __sourceImageData.data.length;
		byteArray.byteView.set (__sourceImageData.data);
		byteArray.position = 0;
		
		return byteArray;
		
		/*var len = Math.round (4 * rect.width * rect.height);
		var byteArray = new ByteArray ();
		byteArray.length = len;
		//var byteArray = new ByteArray(len);
		
		rect = __clipRect (rect);
		if (rect == null) return byteArray;
		
		if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imagedata = ctx.getImageData (rect.x, rect.y, rect.width, rect.height);
			
			for (i in 0...len) {
				
				byteArray.writeByte (imagedata.data[i]);
				
			}
			
		} else {
			
			var offset = Math.round (4 * __imageData.width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round (4 * (rect.x + rect.width));
			
			for (i in 0...len) {
				
				if (((pos) % (__imageData.width * 4)) > boundR - 1) {
					
					pos += __imageData.width * 4 - boundR;
					
				}
				
				byteArray.writeByte (__imageData.data[pos]);
				pos++;
				
			}
			
		}
		
		byteArray.position = 0;
		return byteArray;*/
		
		//return null;
		
	}
	
	
	public function hitTest(firstPoint:Point, firstAlphaThreshold:Int, secondObject:Dynamic, secondBitmapDataPoint:Point = null, secondAlphaThreshold:Int = 1):Bool {
		
		/*var type = Type.getClassName (Type.getClass (secondObject));
		firstAlphaThreshold = firstAlphaThreshold & 0xFFFFFFFF;
		
		var me = this;
		var doHitTest = function (imageData:ImageData) {
			
			// TODO: Use standard Haxe Type and Reflect classes?
			if (secondObject.__proto__ == null || secondObject.__proto__.__class__ == null || secondObject.__proto__.__class__.__name__ == null) return false;
			
			switch (secondObject.__proto__.__class__.__name__[2]) {
				
				case "Rectangle":
					
					var rect:Rectangle = cast secondObject;
					rect.x -= firstPoint.x;
					rect.y -= firstPoint.y;
					
					rect = me.__clipRect (me.rect);
					if (me.rect == null) return false;
					
					var boundingBox = new Rectangle (0, 0, me.width, me.height);
					if (!rect.intersects(boundingBox)) return false;
					
					var diff = rect.intersection(boundingBox);
					var offset = 4 * (Math.round (diff.x) + (Math.round (diff.y) * imageData.width)) + 3;
					var pos = offset;
					var boundR = Math.round (4 * (diff.x + diff.width));
					
					while (pos < offset + Math.round (4 * (diff.width + imageData.width * diff.height))) {
						
						if ((pos % (imageData.width * 4)) > boundR - 1) {
							
							pos += imageData.width * 4 - boundR;
							
						}
						
						if (imageData.data[pos] - firstAlphaThreshold >= 0) return true;
						pos += 4;
						
					}
					
					return false;
				
				case "Point":
					
					var point : Point = cast secondObject;
					var x = point.x - firstPoint.x;
					var y = point.y - firstPoint.y;
					
					if (x < 0 || y < 0 || x >= me.width || y >= me.height) return false;
					if (imageData.data[Math.round (4 * (y * me.width + x)) + 3] - firstAlphaThreshold > 0) return true;
					
					return false;
				
				case "Bitmap":
					
					throw "bitmapData.hitTest with a second object of type Bitmap is currently not supported for HTML5";
					return false;
				
				case "BitmapData":
					
					throw "bitmapData.hitTest with a second object of type BitmapData is currently not supported for HTML5";
					return false;
				
				default:
					
					throw "BitmapData::hitTest secondObject argument must be either a Rectangle, a Point, a Bitmap or a BitmapData object.";
					return false;
				
			}
			
		}
		
		if (!__locked) {
			
			__buildLease ();
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			
			return doHitTest (imageData);
			
		} else {
			
			return doHitTest (__imageData);
			
		}*/
		
		return false;
		
	}
	
	
	public function lock ():Void {
		
		/*__locked = true;
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		__imageData = ctx.getImageData (0, 0, width, height);
		__imageDataChanged = false;
		__copyPixelList = [];*/
		
	}
	
	
	public function noise (randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void {
		
		/*var generator = new MinstdGenerator (randomSeed);
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		
		var imageData = null;
		
		if (__locked) {
			
			imageData = __imageData;
			
		} else {
			
			imageData = ctx.createImageData (___textureBuffer.width, ___textureBuffer.height);
			
		}
		
		for (i in 0...(___textureBuffer.width * ___textureBuffer.height)) {
			
			if (grayScale) {
				
				imageData.data[i * 4] = imageData.data[i * 4 + 1] = imageData.data[i * 4 + 2] = low + generator.nextValue () % (high - low + 1);
				
			} else {
				
				imageData.data[i * 4] = if (channelOptions & BitmapDataChannel.RED == 0) 0 else low + generator.nextValue () % (high - low + 1);
				imageData.data[i * 4 + 1] = if (channelOptions & BitmapDataChannel.GREEN == 0) 0 else low + generator.nextValue () % (high - low + 1);
				imageData.data[i * 4 + 2] = if (channelOptions & BitmapDataChannel.BLUE == 0) 0 else low + generator.nextValue () % (high - low + 1);
				
			}
			
			imageData.data[i * 4 + 3] = if (channelOptions & BitmapDataChannel.ALPHA == 0) 255 else low + generator.nextValue () % (high - low + 1);
			
		}
		
		if (__locked) {
			
			__imageDataChanged = true;
			
		} else {
			
			ctx.putImageData (imageData, 0, 0);
			
		}*/
		
	}
	
	
	public function setPixel (x:Int, y:Int, color:Int):Void {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height || __loading) return;
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		/*if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			
			var imageData = ctx.createImageData (1, 1);
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF);
			if (__transparent) imageData.data[3] = (0xFF);
			
			ctx.putImageData (imageData, x, y);
			
		} else {*/
			
			var offset = (4 * y * width + x * 4);
			
			__sourceImageData.data[offset] = (color & 0xFF0000) >>> 16;
			__sourceImageData.data[offset + 1] = (color & 0x00FF00) >>> 8;
			__sourceImageData.data[offset + 2] = (color & 0x0000FF);
			if (transparent) __sourceImageData.data[offset + 3] = (0xFF);
			
			/*__imageDataChanged = true;
			
		}*/
		
		__sourceImageDataChanged = true;
		
	}
	
	
	public function setPixel32 (x:Int, y:Int, color:Int):Void {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height || __loading) return;
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		/*if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.createImageData (1, 1);
			
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF);
			
			if (__transparent) {
				
				imageData.data[3] = (color & 0xFF000000) >>> 24;
				
			} else {
				
				imageData.data[3] = (0xFF);
				
			}
			
			ctx.putImageData (imageData, x, y);
			
		} else {*/
			
			var offset = (4 * y * width + x * 4);
			
			__sourceImageData.data[offset] = (color & 0x00FF0000) >>> 16;
			__sourceImageData.data[offset + 1] = (color & 0x0000FF00) >>> 8;
			__sourceImageData.data[offset + 2] = (color & 0x000000FF);
			
			if (transparent) {
				
				__sourceImageData.data[offset + 3] = (color & 0xFF000000) >>> 24;
				
			} else {
				
				__sourceImageData.data[offset + 3] = (0xFF);
				
			}
			
			/*__imageDataChanged = true;
			
		}*/
		
		__sourceImageDataChanged = true;
		
	}
	
	
	public function setPixels (rect:Rectangle, byteArray:ByteArray):Void {
		
		rect = __clipRect (rect);
		if (rect == null || __loading) return;
		
		var len = Math.round (4 * rect.width * rect.height);
		
		if (__sourceImageData == null) {
			
			__sourceImageData = __sourceContext.getImageData (0, 0, width, height);
			
		}
		
		if (rect.x == 0 && rect.y == 0 && rect.width == width && rect.height == height) {
			
			__sourceImageData.data.set (byteArray.byteView);
			
		} else {
		
		/*if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.createImageData (rect.width, rect.height);
			
			for (i in 0...len) {
				
				imageData.data[i] = byteArray.readByte ();
				
			}
			
			ctx.putImageData (imageData, rect.x, rect.y);
			
		} else {*/
			
			var offset = Math.round (4 * width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round (4 * (rect.x + rect.width));
			var data = __sourceImageData.data;
			
			for (i in 0...len) {
				
				if (((pos) % (width * 4)) > boundR - 1) {
					
					pos += width * 4 - boundR;
					
				}
				
				data[pos] = byteArray.readByte ();
				pos++;
				
			}
			
			//__imageDataChanged = true;
			
		}
		
		__sourceImageDataChanged = true;
		
	}
	
	
	public function threshold (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, operation:String, threshold:Int, color:Int = 0, mask:Int = 0xFFFFFFFF, copySource:Bool = false):Int {
		
		trace ("BitmapData.threshold not implemented");
		return 0;
		
	}
	
	
	public function unlock (changeRect:Rectangle = null):Void {
		
		/*__locked = false;
		
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		
		if (__imageDataChanged) {
			
			if (changeRect != null) {
				
				ctx.putImageData (__imageData, 0, 0, changeRect.x, changeRect.y, changeRect.width, changeRect.height);
				
			} else {
				
				ctx.putImageData (__imageData, 0, 0);
				
			}
			
		}
		
		for (copyCache in __copyPixelList) {
			
			if (__transparent && copyCache.transparentFiller != null) {
				
				var trpCtx:CanvasRenderingContext2D = copyCache.transparentFiller.getContext ('2d');
				var trpData = trpCtx.getImageData (copyCache.sourceX, copyCache.sourceY, copyCache.sourceWidth, copyCache.sourceHeight);
				ctx.putImageData (trpData, copyCache.destX, copyCache.destY);
				
			}
			
			ctx.drawImage (copyCache.handle, copyCache.sourceX, copyCache.sourceY, copyCache.sourceWidth, copyCache.sourceHeight, copyCache.destX, copyCache.destY, copyCache.sourceWidth, copyCache.sourceHeight);
			
		}
		
		__buildLease ();*/
		
	}
	
	
	private static function __base64Encode (bytes:ByteArray):String {
		
		var extension = switch (bytes.length % 3) {
			
			case 1: "==";
			case 2: "=";
			default: "";
			
		}
		
		if (__base64Encoder == null) {
			
			__base64Encoder = new BaseCode (Bytes.ofString (__base64Chars));
			
		}
		
		return __base64Encoder.encodeBytes (Bytes.ofData (cast bytes.byteView)).toString () + extension;
		
	}
	
	
	private function __clipRect (r:Rectangle):Rectangle {
		
		if (r.x < 0) {
			
			r.width -= -r.x;
			r.x = 0;
			
			if (r.x + r.width <= 0) return null;
			
		}
		
		if (r.y < 0) {
			
			r.height -= -r.y;
			r.y = 0;
			
			if (r.y + r.height <= 0) return null;
			
		}
		
		if (r.x + r.width >= this.width) {
			
			r.width -= r.x + r.width - this.width;
			
			if (r.width <= 0) return null;
			
		}
		
		if (r.y + r.height >= this.height) {
			
			r.height -= r.y + r.height - this.height;
			
			if (r.height <= 0) return null;
			
		}
		
		return r;
		
	}
	
	
	private function __convertToCanvas ():Void {
		
		if (__loading) return;
		
		if (__sourceImage != null) {
			
			if (__sourceCanvas == null) {
				
				__sourceCanvas = cast Browser.document.createElement ("canvas");
				__sourceCanvas.width = __sourceImage.width;
				__sourceCanvas.height = __sourceImage.height;
				__sourceContext = __sourceCanvas.getContext ("2d");
				__sourceContext.drawImage (__sourceImage, 0, 0);
				
			}
			
			__sourceImage = null;
			
		}
		
	}
	
	
	private function __fillRect (rect:Rectangle, color:Int) {
		
		/*__buildLease ();
		
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		*/
		
		var r = (color & 0xFF0000) >>> 16;
		var g = (color & 0x00FF00) >>> 8;
		var b = (color & 0x0000FF);
		var a = (transparent) ? (color >>> 24) : 0xFF;
		
		//if (!__locked) {
			
			//if (__transparent) {
				//
				//var trpCtx:CanvasRenderingContext2D = __transparentFiller.getContext ('2d');
				//var trpData = trpCtx.getImageData (rect.x, rect.y, rect.width, rect.height);
				//
				//ctx.putImageData (trpData, rect.x, rect.y);
				//
			//}
			
			__sourceContext.fillStyle = 'rgba(' + r + ', ' + g + ', ' + b + ', ' + (a / 255) + ')';
			__sourceContext.fillRect (rect.x, rect.y, rect.width, rect.height);
			
		/*} else {
			
			var s = 4 * (Math.round (rect.x) + (Math.round (rect.y) * __imageData.width));
			var offsetY:Int;
			var offsetX:Int;
			
			for (i in 0...Math.round (rect.height)) {
				
				offsetY = (i * __imageData.width);
				
				for (j in 0...Math.round (rect.width)) {
					
					offsetX = 4 * (j + offsetY);
					__imageData.data[s + offsetX] = r;
					__imageData.data[s + offsetX + 1] = g;
					__imageData.data[s + offsetX + 2] = b;
					__imageData.data[s + offsetX + 3] = a;
					
				}
				
			}
			
			__imageDataChanged = true;
			//ctx.putImageData (__imageData, 0, 0, rect.x, rect.y, rect.width, rect.height);
			
		}*/
		
	}
	
	
	private function __getInt32 (offset:Int, data:Uint8ClampedArray) {
		
		return (transparent ? data[offset + 3] : 0xFF) << 24 | data[offset] << 16 | data[offset + 1] << 8 | data[offset + 2]; 
		
		// code to deal with 31-bit ints.
		
		//var b5, b6, b7, b8, pow = Math.pow;
		//
		//b5 = if (!__transparent) 0xFF; else data[offset + 3] & 0xFF;
		//b6 = data[offset] & 0xFF;
		//b7 = data[offset + 1] & 0xFF;
		//b8 = data[offset + 2] & 0xFF;
		//
		//return untyped {
			//
			//parseInt(((b5 >> 7) * pow(2, 31)).toString(2), 2) + parseInt((((b5 & 0x7F) << 24) |(b6 << 16) |(b7 << 8) | b8).toString(2), 2);
			//
		//}
		
	}
	
	
	private static function __isJPG (bytes:ByteArray) {
		
		bytes.position = 0;
		return bytes.readByte () == 0xFF && bytes.readByte () == 0xD8;
		
	}
	
	
	private static function __isPNG (bytes:ByteArray) {
		
		bytes.position = 0;
		return (bytes.readByte () == 0x89 && bytes.readByte () == 0x50 && bytes.readByte () == 0x4E && bytes.readByte () == 0x47 && bytes.readByte () == 0x0D && bytes.readByte () == 0x0A && bytes.readByte () == 0x1A && bytes.readByte () == 0x0A);
		
	}
	
	private static function __isGIF (bytes:ByteArray) {
		
		bytes.position = 0;
		
		//GIF8
		if (bytes.readByte () == 0x47 && bytes.readByte () == 0x49 && bytes.readByte () == 0x46 && bytes.readByte () == 38) {
			
			var b = bytes.readByte ();
			return ((b == 7 || b == 9) && bytes.readByte () == 0x61); //(7|8)a
			
		}
		
		return false;
		
	}
	
	
	private inline function __loadFromBase64 (base64:String, type:String, ?onload:BitmapData -> Void):Void {
		
		__loading = true;
		__sourceImage = cast Browser.document.createElement ("img");
		
		var image_onLoaded = function (event) {
			
			if (__sourceImage == null) {
				
				__sourceImage = event.target;
				
			}
			
			width = __sourceImage.width;
			height = __sourceImage.height;
			
			__loading = false;
			
			if (onload != null) {
				
				onload (this);
				
			}
			
		}
		
		__sourceImage.addEventListener ("load", image_onLoaded, false);
		__sourceImage.src = "data:" + type + ";base64," + base64;
		
	}
	
	
	private inline function __loadFromBytes (bytes:ByteArray, rawAlpha:ByteArray = null, ?onload:BitmapData -> Void):Void {
		
		var type = "";
		
		if (__isPNG (bytes)) {
			
			type = "image/png";
			
		} else if (__isJPG (bytes)) {
			
			type = "image/jpeg";
			
		} else if (__isGIF (bytes)) {
			
			type = "image/gif";
			
		} else {
			
			throw new IOError ("BitmapData tried to read a PNG/JPG ByteArray, but found an invalid header.");
			
		}
		
		if (rawAlpha != null) {
			
			__loadFromBase64 (__base64Encode (bytes), type, function (_) {
				
				__convertToCanvas ();
				
				var pixels = __sourceContext.getImageData (0, 0, width, height);
				
				for (i in 0...rawAlpha.length) {
					
					pixels.data[i * 4 + 3] = rawAlpha.readUnsignedByte ();
					
				}
				
				__sourceContext.putImageData (pixels, 0, 0);
				
				if (onload != null) {
					
					onload (this);
					
				}
				
			});
			
		} else {
			
			__loadFromBase64 (__base64Encode (bytes), type, onload);
			
		}
		
	}
	
	
	public function __renderCanvas (renderSession:RenderSession):Void {
		
		if (__sourceImageDataChanged) {
			
			__sourceContext.putImageData (__sourceImageData, 0, 0);
			__sourceImageData = null;
			__sourceImageDataChanged = false;
			
		}
		
		var context = renderSession.context;
		
		/*if (this.blendMode !== renderSession.currentBlendMode) {
			
			renderSession.currentBlendMode = this.blendMode;
			context.globalCompositeOperation = PIXI.blendModesCanvas[renderSession.currentBlendMode];
			
		}

		if (this._mask) {
			
			renderSession.maskManager.pushMask(this._mask, renderSession.context);
			
		}*/
		
		if (__worldTransform == null) __worldTransform = new Matrix ();
		
		context.globalAlpha = 1;
		var transform = __worldTransform;
		
		if (renderSession.roundPixels) {
			
			context.setTransform (transform.a, transform.c, transform.b, transform.d, untyped (transform.tx || 0), untyped (transform.ty || 0));
			
		} else {
			
			context.setTransform (transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
			
		}
		
		/*if (renderSession.smoothProperty && renderSession.scaleMode !== this.texture.baseTexture.scaleMode) {
			
			renderSession.scaleMode = this.texture.baseTexture.scaleMode;
			context[renderSession.smoothProperty] = (renderSession.scaleMode === PIXI.scaleModes.LINEAR);
			
		}*/
		
		/*if (this.tint !== 0xFFFFFF) {

			if (this.cachedTint !== this.tint) {
				
				// no point tinting an image that has not loaded yet!
				if (!texture.baseTexture.hasLoaded) return;
				
				this.cachedTint = this.tint;
				
				//TODO clean up caching - how to clean up the caches?
				this.tintedTexture = PIXI.CanvasTinter.getTintedTexture(this, this.tint);
				
			}
			
			context.drawImage (this.tintedTexture, 0, 0, frame.width, frame.height,(this.anchor.x) * -frame.width, (this.anchor.y) * -frame.height, frame.width, frame.height);
			
		} else {*/
			
			/*if (texture.trim) {
				
				var trim = texture.trim;
				
				context.drawImage (this.texture.baseTexture.source, frame.x, frame.y, frame.width, frame.height, trim.x - this.anchor.x * trim.width, trim.y - this.anchor.y * trim.height, frame.width, frame.height);
				
			} else {*/
				
				if (__sourceImage != null) {
					
					context.drawImage (__sourceImage, 0, 0);
					
				} else {
					
					context.drawImage (__sourceCanvas, 0, 0);
					
				}
				
				
				//context.drawImage (bitmapData.__source, 0, 0, bitmapData.width, bitmapData.height, -bitmapData.width, -bitmapData.height, bitmapData.width, bitmapData.height);
				
			//}
			
		//}

		/*// OVERWRITE
		for(var i=0,j=this.children.length; i<j; i++)
		{
		var child = this.children[i];
		child._renderCanvas(renderSession);
		}

		if(this._mask)
		{
		renderSession.maskManager.popMask(renderSession.context);
		}*/
		
	}
	
	
	public function __update ():Void {
		
		
		
	}
	
	
	/*
	
	
	public function __loadFromFile (inFilename:String, inLoader:LoaderInfo = null) {
		
		var image:ImageElement = cast Browser.document.createElement ("img");
		
		if (inLoader != null) {
			
			var data:LoadData = { image: image, texture: ___textureBuffer, inLoader: inLoader, bitmapData: this };
			
			image.addEventListener ("load", __onLoad.bind (data), false);
			// IE9 bug, force a load, if error called and complete is false.
			image.addEventListener ("error", function(e) { if (!image.complete) __onLoad (data, e); }, false);
			
		}
		
		image.src = inFilename;
		
		// Another IE9 bug: loading 20+ images fails unless this line is added.
		// (issue #1019768)
		if (image.complete) { }
		
	}*/
	
	
	
	
	// Event Handlers
	
	
	
	
	/*private function __onLoad (data:LoadData, e) {
		
		var canvas:CanvasElement = cast data.texture;
		var width = data.image.width;
		var height = data.image.height;
		canvas.width = width;
		canvas.height = height;
		
		// TODO: Should copy later, only if the bitmapData is going to be modified
		
		var ctx:CanvasRenderingContext2D = canvas.getContext ("2d");
		ctx.drawImage (data.image, 0, 0, width, height);
		
		data.bitmapData.width = width;
		data.bitmapData.height = height;
		data.bitmapData.rect = new Rectangle (0, 0, width, height);
		data.bitmapData.__buildLease ();
		
		if (data.inLoader != null) {
			
			var e = new Event (Event.COMPLETE);
			e.target = data.inLoader;
			data.inLoader.dispatchEvent (e);
			
		}
		
	}*/
	
	
}


/*typedef LoadData = {
	
	var image:ImageElement;
	var texture:CanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
	
}*/


//private class MinstdGenerator {
	
	/** A MINSTD pseudo-random number generator.
	 *
	 * This generates a pseudo-random number sequence equivalent to std::minstd_rand0 from the C++ standard library, which
	 * is the generator that Flash uses to generate noise for BitmapData.noise().
	 *
	 * MINSTD was originally suggested in "A pseudo-random number generator for the System/360", P.A. Lewis, A.S. Goodman,
	 * J.M. Miller, IBM Systems Journal, Vol. 8, No. 2, 1969, pp. 136-146 */
	
	/*private static inline var a = 16807;
	private static inline var m = (1 << 31) - 1;

	private var value:Int;
	

	public function new (seed:Int) {
		
		if (seed == 0) {
			
			this.value = 1;
			
		} else {
			
			this.value = seed;
			
		}
		
	}
	
	
	public function nextValue():Int {
		
		var lo = a * (value & 0xffff);
		var hi = a * (value >>> 16);
		lo += (hi & 0x7fff) << 16;
		
		if (lo < 0 || lo > m) {
			
			lo &= m;
			++lo;
			
		}
		
		lo += hi >>> 15;
		
		if (lo < 0 || lo > m) {
			
			lo &= m;
			++lo;
			
		}
		
		return value = lo;
		
	}
	
	
}*/
