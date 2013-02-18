package  
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class LPF extends Filter 
	{
		
		public function LPF(cutoff:Number) 
		{
			super(1 - cutoff, 0, 0, cutoff);
		}
		
		public function cutoff(cutoff:Number):void {
			a0 = 1-cutoff;
			b1 = cutoff;
		}
		
	}

}