package  
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Filter 
	{
		
		protected var a0:Number;
		protected var b0:Number;
		protected var a1:Number;
		protected var b1:Number;
		
		private var x0:Number = 0, x1:Number = 0;
		private var y0:Number = 0, y1:Number = 0;
		
		public function Filter(a0:Number, b0:Number, a1:Number, b1:Number) 
		{
			this.a0 = a0;
			this.b0 = b0;
			this.a1 = a1;
			this.b1 = b1;
		}
		
		public function calc(x:Number):Number {
			
			x1 = x0;
			x0 = x;
			
			y1 = y0;
			//y0 = ...(output);
			
			
			y0 = a0 * x0 + a1 * x1 + b0 * y0 + b1 * y1;
			
			//y[n] = a0*x[n] + a1*x[n-1] + b0*y[n-1] + b1*y[n-1];
			return y0;
		}
		
	}

}