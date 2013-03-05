package animations 
{
	import com.greensock.easing.Expo;
	import com.greensock.TweenMax;
	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.core.Starling;
	import starling.textures.TextureAtlas;
	import starling.textures.Texture;
	import starling.display.MovieClip;
	import flash.display.Bitmap;

	/**
	* ...
	* @author 0L4F
	*/
	public class Hexagon extends Sprite
	{
		[Embed(source="../media/textures/HexAtlas.xml",mimeType="application/octet-stream")]
		private var AnimData:Class;
		[Embed(source="../media/textures/HexAtlas.png")]
		private var AnimTexture:Class;	
		private var _mc:MovieClip;

		public function Hexagon() 
		{
			super();	
			
			var sparkleTexture:Texture = Texture.fromBitmap(new AnimTexture());
			var sparkleXmlData:XML = XML(new AnimData());
			var sparkleTextureAtlas:TextureAtlas = new TextureAtlas(sparkleTexture, sparkleXmlData);
			
			//Fetch the sprite sequence form the texture using their name
			_mc = new MovieClip(sparkleTextureAtlas.getTextures("hexmovie0"), 150);
			_mc.loop = true;
			_mc.fps = 30;
			
			pivotX = 64;
			pivotY = 64;
				
			blendMode = BlendMode.ADD;
			
			_mc.currentFrame = 0;
			addChild(_mc);
			Starling.juggler.add(_mc);
		}
		
		
		public function start():void
		{
			//BootjeTest.soundPlayer.playExplosion();
			
			_mc.currentFrame = 0;
			addChild(_mc);
			Starling.juggler.add(_mc);
			
			//_mc.alpha = 0;
			//TweenMax.from ( _mc, 3, { alpha:1, ease:Expo.easeIn } );
			
			//addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		private function frame(e:EnterFrameEvent):void 
		{
			if (_mc.currentFrame >= _mc.numFrames) {
				parent.removeChild(this);
				trace("wee");
			}
		}
	}
}