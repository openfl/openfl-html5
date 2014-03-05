package flash.display;


import flash.display.Stage;


@:access(flash.display.BitmapData)
class Bitmap extends DisplayObjectContainer {
	
	
	public var bitmapData:BitmapData;
	public var smoothing:Bool;
	
	
	public function new (bitmapData:BitmapData = null) {
		
		super ();
		
		this.bitmapData = bitmapData;
		
	}
	
	
	private override function __renderCanvas (renderSession:RenderSession):Void {
		
		if (!__renderable) return;
		
		var context = renderSession.context;
		
		/*if (this.blendMode !== renderSession.currentBlendMode) {
			
			renderSession.currentBlendMode = this.blendMode;
			context.globalCompositeOperation = PIXI.blendModesCanvas[renderSession.currentBlendMode];
			
		}

		if (this._mask) {
			
			renderSession.maskManager.pushMask(this._mask, renderSession.context);
			
		}*/
		
		if (bitmapData != null) {
			
			context.globalAlpha = __worldAlpha;
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
					
					if (bitmapData.__sourceImage != null) {
						
						context.drawImage (bitmapData.__sourceImage, 0, 0);
						
					} else {
						
						context.drawImage (bitmapData.__sourceCanvas, 0, 0);
						
					}
					
					
					//context.drawImage (bitmapData.__source, 0, 0, bitmapData.width, bitmapData.height, -bitmapData.width, -bitmapData.height, bitmapData.width, bitmapData.height);
					
				//}
				
			//}
			
		}

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
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_height ():Float {
		
		return bitmapData.height;
		
	}
	
	
	private override function get_width ():Float {
		
		return bitmapData.width;
		
	}
	
	
}