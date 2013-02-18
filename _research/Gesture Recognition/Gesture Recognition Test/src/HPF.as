package  
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class HPF extends Filter 
	{
		
		public function HPF(cutoff:Number) 
		{
			super((1 + cutoff) / 2, 0, -(1 + cutoff) / 2, cutoff);
		}
		
		public function cutoff(cutoff:Number):void {
			a0 = (1 + cutoff) / 2;
			a1 = -(1 + cutoff) / 2;
			b1 = cutoff;
		}
		
	}

}