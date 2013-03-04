package  
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.SubTexture;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class HairfieldLineImage extends Image 
	{
		
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const TWO_PI:Number = Math.PI * 2;
		
		private static const ANIMATION_IMAGES:int = 16;
		
		
		[Embed(source="HairAnimAtlas-16x(16x128)-in-(256x128).png")]
		private static var HairAnimation:Class;
		
		private static var animationTexture:Texture = null;
		private static var subTextures:Vector.<SubTexture>;
		
		private var _textureAmount:int;
		private var _imageIndex:Number;
		private var _animSpeed:Number = 1+Math.random();
		private var _currentTexture:SubTexture;
		
		
		//public var debug:Boolean = false;
		
		public function HairfieldLineImage() 
		{
			
			if (animationTexture == null) {
				animationTexture = Texture.fromBitmap((new HairAnimation() as Bitmap));
				subTextures = new Vector.<SubTexture>(ANIMATION_IMAGES);
				for (var i:int = 0; i < ANIMATION_IMAGES; i++) {
					var region:Rectangle = new Rectangle(i * 16, 0, 16, 128);
					subTextures[i] = new SubTexture(animationTexture, region);
				}
			}
			
			
			this._textureAmount = subTextures.length;
			this._imageIndex = _textureAmount * Math.random();
			this._currentTexture = subTextures[int(_imageIndex)];
			
			super(_currentTexture);
			
			pivotX = 8;
			pivotY = 128 - 8;
			
			blendMode = BlendMode.ADD;
			//width = 128;
			//height = 16;
			
			/*trace("-");
			var pos:Point = new Point();
			for (var i:int = 0; i < 4; i++) {
				mVertexData.getPosition(i, pos);
				trace(pos);
				mVertexData.getTexCoords(i, pos);
				trace(pos);
			}*/
			// standard:
			/*setTexCoords(0, new Point(0, 0));
			setTexCoords(1, new Point(1, 0));
			setTexCoords(2, new Point(0, 1));
			setTexCoords(3, new Point(1, 1));*/
			
			/*setTexCoords(1, new Point(0, 0));
			setTexCoords(0, new Point(1, 0));
			setTexCoords(3, new Point(0, 1));
			setTexCoords(2, new Point(1, 1));*/
			//onVertexDataChanged()
			//wid
			//_image.pivotX = width / 2;
			//_image.pivotY = height - width / 2;
			
			
			
		}
		
		private var _touched:Boolean = false;
		public function touch():void {
			_touched = true;
		}
		
		private var minSpeed:Number = 25.0 / 60.0;
		
		public function animate():void 
		{
			var targetAnimSpeed:Number = 0;
			if (_touched) {
				targetAnimSpeed = Math.min(_animSpeed + 1.0,4);
				_touched = false;
			}
			
			if (targetAnimSpeed > _animSpeed) {
				_animSpeed = 0.80 * _animSpeed + 0.20 * targetAnimSpeed;
			} else {
				_animSpeed = 0.995 * _animSpeed + 0.005 * targetAnimSpeed;
				if (_animSpeed < minSpeed) _animSpeed = minSpeed;
			}
			
			
			
			
			var lastImageIndex:int = _imageIndex;
			
			_imageIndex += _animSpeed;
			_imageIndex %= ANIMATION_IMAGES;
			
			if (lastImageIndex != _imageIndex) {
				texture = _currentTexture = subTextures[int(_imageIndex)];
			}
		}
		
		
		
		override public function set rotation(value:Number):void {
			super.rotation = value + HALF_PI;
			var lastRotation:Number = rotation;
			var dRot:Number = Math.abs(lastRotation - rotation);
			if (dRot > Math.PI) {
				dRot = TWO_PI - dRot;
			}
			/*var targetAnimSpeed:Number = 4 * dRot / Math.PI;
			
			if (targetAnimSpeed > _animSpeed) {
				_animSpeed = 0.05 * _animSpeed + 0.95 * targetAnimSpeed;
			} else {
				_animSpeed = 0.995 * _animSpeed + 0.005 * targetAnimSpeed;
			}*/
			
			//_animSpeed = 0.5 + 1.5 * dRot / Math.PI;
		}
		
		override public function get rotation():Number {
			return super.rotation - HALF_PI;
		}
		
		
		
		//TODO: instead of rotating this object, maybe actually create the corret points?
	}

}