package  
{
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 0L4F
	*/
	
	public class Ball extends Image 
	{
		//[Embed(source="media/textures/planet.png")]
		[Embed(source="media/textures/ball128.png")]
		private var basketball:Class;
		
		
		public function Ball(size:uint = 50) 
		{			
			//var img:Image = Image.fromBitmap(new basketball());
			super(Texture.fromBitmap(new basketball()));
			scaleX = scaleY = size * (1 / width);
			alpha = 0.75;
			//addChild(img);
			
			pivotX = 128 >> 1;
			pivotY = 128 >> 1;
			
			TweenMax.from(this, 0.5, {scaleX:0, scaleY:0});
		}
		
	}

}