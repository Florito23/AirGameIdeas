package  
{
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author 0L4F
	*/
	
	public class Player extends Sprite 
	{
		[Embed(source="media/textures/player.png")]
		private var player:Class;
		
		
		public function Player() 
		{
			//addChild(Image.fromBitmap(new player()));
			
			var img:Image = Image.fromBitmap(new player());
			//img.scaleX = img.scaleY = 0.5;
			img.alpha = 0.75;
			addChild(img);
			
			pivotX = width >> 1;
			pivotY = height >> 1;
		}
		
	}

}