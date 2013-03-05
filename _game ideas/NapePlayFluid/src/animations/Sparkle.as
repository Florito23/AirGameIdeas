package animations 
{
	import com.greensock.easing.Expo;
	import com.greensock.TweenMax;
	import starling.display.BlendMode;
	import starling.display.Sprite;
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
	public class Sparkle extends Sprite
	{
		[Embed(source="../media/textures/sparkle.xml",mimeType="application/octet-stream")]
		private var AnimData:Class;
		[Embed(source="../media/textures/sparkle.png")]
		private var AnimTexture:Class;	
		private var _mc:MovieClip;

		public function Sparkle() 
		{
			super();	
			
			var sparkleTexture:Texture = Texture.fromBitmap(new AnimTexture());
			var sparkleXmlData:XML = XML(new AnimData());
			var sparkleTextureAtlas:TextureAtlas = new TextureAtlas(sparkleTexture, sparkleXmlData);
			
			//Fetch the sprite sequence form the texture using their name
			_mc = new MovieClip(sparkleTextureAtlas.getTextures("mGameFireFliesGIF00"), 90);
			_mc.loop = false;
			_mc.fps = 30;
			
			pivotX = 60;
			pivotY = 45;
				
			blendMode = BlendMode.ADD;
		}
		
		
		public function start():void
		{
			_mc.currentFrame = 0;
			addChild(_mc);
			Starling.juggler.add(_mc);
			
			_mc.alpha = 0;
			TweenMax.from ( _mc, 3, { alpha:1, ease:Expo.easeIn } );
		}
	}
}