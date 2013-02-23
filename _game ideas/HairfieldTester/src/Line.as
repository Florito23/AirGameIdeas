package  
{
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Line extends Quad 
	{
		
		public function Line(length:Number, width:Number, color:uint) 
		{
			super(length, width, color);
			pivotX = width / 2;
			pivotY = width / 2;
		}
		
		
	}

}