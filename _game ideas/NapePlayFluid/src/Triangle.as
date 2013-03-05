package  
{
	import com.greensock.TweenMax;
	import flash.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 0L4F
	*/
	
	public class Triangle extends Image 
	{
		//[Embed(source="media/textures/planet.png")]
		[Embed(source="media/textures/Poly_128x111_pivot_64x67.png")]
		private var Tri:Class;
		
		
		public function Triangle(size:uint = 50) 
		{			
			//var img:Image = Image.fromBitmap(new basketball());
			super(Texture.fromBitmap(new Tri()));
			scaleX = scaleY = size / 128;// 0.25;// size * (1 / width);
			alpha = 0.5;
			//addChild(img);
			
			pivotX = 64;
			pivotY = 69;
			
			TweenMax.from(this, 0.5, { scaleX:0, scaleY:0 } );
			
			blendMode = BlendMode.ADD;
		}
		
	}

}