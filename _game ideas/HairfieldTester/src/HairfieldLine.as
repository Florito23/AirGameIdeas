package  
{
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class HairfieldLine extends Quad 
	{
		
		public function HairfieldLine(length:Number, width:Number, color:uint) 
		{
			super(length, width, color);
			pivotX = width / 2;
			pivotY = width / 2;
		}
		
		//TODO: instead of rotating this object, maybe actually create the corret points?
	}

}