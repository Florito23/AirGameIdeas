package hud 
{
	import animations.Sparkle;
	import com.greensock.easing.Expo;
	import com.greensock.TweenMax;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class ScoreDisplay extends Sprite 
	{
		[Embed(source="../media/fonts/streedCred64.fnt", mimeType="application/octet-stream")]
		public static const FontXml:Class;
		 
		[Embed(source="../media/fonts/streedCred64_0.png")]
		public static const FontTexture:Class;

		private var scoreTF:TextField;
		private var scoreTFShadow:TextField;
		
		private var sparkle:Sparkle;
		
		
		public function ScoreDisplay() 
		{
			//this.filter = BlurFilter.createGlow(0xffffff, 1, 4);
			
			sparkle = new Sparkle();
			sparkle.scaleX = sparkle.scaleY = 2;
			addChild(sparkle);
			
			var texture:Texture = Texture.fromBitmap(new FontTexture());
			var xml:XML = XML(new FontXml());
			
			TextField.registerBitmapFont(new BitmapFont(texture, xml));
			
			scoreTFShadow = new TextField(256, 64, "hi");
			scoreTFShadow.fontName = "street cred";
			scoreTFShadow.hAlign = HAlign.CENTER;
			scoreTFShadow.vAlign = VAlign.CENTER;
			scoreTFShadow.fontSize = BitmapFont.NATIVE_SIZE;
			scoreTFShadow.color = 0x000000;
			scoreTFShadow.pivotX = scoreTFShadow.width * 0.5;
			scoreTFShadow.pivotY = scoreTFShadow.height * 0.5;
			scoreTFShadow.x = 3;
			scoreTFShadow.y = 3;
			addChild(scoreTFShadow);
			
			scoreTF = new TextField(256, 64, "hi");
			scoreTF.fontName = "street cred";
			scoreTF.hAlign = HAlign.CENTER;
			scoreTF.vAlign = VAlign.CENTER;
			scoreTF.fontSize = BitmapFont.NATIVE_SIZE;
			//scoreTF.color = 0xddff00;
			scoreTF.color = 0xffffff;
			scoreTF.pivotX = scoreTF.width * 0.5;
			scoreTF.pivotY = scoreTF.height * 0.5;
			addChild(scoreTF);
			
			scoreTF.text = scoreTFShadow.text = "0";
		}
		
		public function update(score:int):void 
		{
			//dispatchEventWith("scoreTick", true);
			
			sparkle.start();
			
			scoreTF.text = scoreTFShadow.text = "" + score;
			
			scoreTF.scaleX = scoreTF.scaleY = 1;
			scoreTFShadow.scaleX = scoreTFShadow.scaleY = 1;
			
			scoreTFShadow.x = 3;
			scoreTFShadow.y = 3;
			
			TweenMax.from(scoreTF, 1, { scaleX:2, scaleY:1.5, ease: Expo.easeOut } );
			TweenMax.from(scoreTFShadow, 0.75, { x:25, y:50, scaleX:1.5, scaleY:1.5, ease: Expo.easeOut } );
		}
		
	}

}