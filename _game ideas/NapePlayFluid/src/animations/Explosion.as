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
	public class Explosion extends Sprite
	{
		[Embed(source="../media/textures/explosion.xml",mimeType="application/octet-stream")]
		private var AnimData:Class;
		[Embed(source="../media/textures/explosion.png")]
		private var AnimTexture:Class;	
		private var _mc:MovieClip;

		public function Explosion() 
		{
			super();	
			
			var sparkleTexture:Texture = Texture.fromBitmap(new AnimTexture());
			var sparkleXmlData:XML = XML(new AnimData());
			var sparkleTextureAtlas:TextureAtlas = new TextureAtlas(sparkleTexture, sparkleXmlData);
			
			//Fetch the sprite sequence form the texture using their name
			_mc = new MovieClip(sparkleTextureAtlas.getTextures("explosion00"), 16);
			_mc.loop = false;
			_mc.fps = 30;
			
			pivotX = 35;
			pivotY = 50;
				
			blendMode = BlendMode.ADD;
		}
		
		
		public function start():void
		{
			//BootjeTest.soundPlayer.playExplosion();
			
			_mc.currentFrame = 0;
			addChild(_mc);
			Starling.juggler.add(_mc);
			
			_mc.alpha = 0;
			TweenMax.from ( _mc, 3, { alpha:1, ease:Expo.easeIn } );
			
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