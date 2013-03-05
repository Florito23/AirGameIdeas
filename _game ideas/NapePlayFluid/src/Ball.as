package  
{
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author 0L4F
	*/
	
	public class Ball extends Sprite 
	{
		//[Embed(source="media/textures/planet.png")]
		[Embed(source="media/textures/ball128.png")]
		private var basketball:Class;
		
		
		public function Ball(size:uint = 50) 
		{			
			var img:Image = Image.fromBitmap(new basketball());
			img.scaleX = img.scaleY = size * (1 / img.width);
			img.alpha = 0.75;
			addChild(img);
			
			pivotX = width >> 1;
			pivotY = height >> 1;
			
			TweenMax.from(this, 0.5, {scaleX:0, scaleY:0});
		}
		
	}

}