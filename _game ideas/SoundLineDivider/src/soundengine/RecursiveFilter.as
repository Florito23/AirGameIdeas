package soundengine 
{
	/**
	 * ...
	 * 
	 * Output: 
	 * y[n] =	a0*x[n]	+	a1*x[n-1]	+	a2*x[n-2]	+	a3*x[n-3]	+ ... +
	 * 						b1*y[n-1]	+	b2*y[n-2}	+	b3*y[n-3]	+ ...
	 * 	
	 * @see http://www.dspguide.com/ch19/2.htm
	 * 
	 * @author Marcus Graf
	 */
	public class RecursiveFilter implements SoundModifier
	{
		
		private var aValues:Vector.<Number>;	// 0..
		private var bValues:Vector.<Number>;	// 1..
		private var aIndices:Vector.<int>;
		private var bIndices:Vector.<int>;
		private var aAmount:int = 0;
		private var bAmount:int = 0;
			
		private var inBufferXPointer:int = 0;
		private var outBufferYPointer:int = 0;
		private var inBufferXLength:int;
		private var outBufferYLength:int;
		private var inBufferXLeft:Vector.<Number>;
		private var inBufferXRight:Vector.<Number>;
		private var outBufferYLeft:Vector.<Number>;
		private var outBufferYRight:Vector.<Number>;
		
		
		private var _active:Boolean = true;
		
		/**
		 * 
		 * @param	coEfficientList: i.e. "a0,a1,b2" or "a0=0.95,b1=0.05"
		 */
		public function RecursiveFilter(coEfficientList:String) 
		{
			//trace("RecursiveFilter", coEfficientList);
			
			
			
			aValues = new Vector.<Number>();
			bValues = new Vector.<Number>();
			aIndices = new Vector.<int>();
			bIndices = new Vector.<int>();
			
			inBufferXLength = 0;
			outBufferYLength = 0;
			
			var coEfficients:Array = coEfficientList.split(",");
			var i:int;
			for (i = 0; i < coEfficients.length; i++) {
				//strip spaces
				var eff:String = (coEfficients[i] as String);
				while (eff.indexOf(" ") >= 0) {
					eff = eff.replace(" ", "");
				}
				// split into name and value
				var arr:Array = eff.split("=");
				var coEfficientName:String = arr[0] as String;
				var coEfficientValue:Number = (arr.length > 0 && arr[1] != null) ? Number(arr[1]) : 0;
				if (isNaN(coEfficientValue)) coEfficientValue = 0;
				
				var isA:Boolean = coEfficientName.indexOf("a") == 0;
				var isB:Boolean = coEfficientName.indexOf("b") == 0;
				if ((isA || isB) && coEfficientName.length > 1) {
					var coEfficientIndex:int = int(coEfficientName.substr(1));
					if (isA && coEfficientIndex >= 0) {
						aValues.push(coEfficientValue);
						aIndices.push(coEfficientIndex);
						inBufferXLength = Math.max(inBufferXLength, coEfficientIndex + 1);
						//trace("registering", coEfficientName, "to", coEfficientValue);
						//maxA = Math.max(maxA, coEfficientIndex);
						//aValues[coEfficientIndex] = coEfficientValue;
					}
					else if (isB && coEfficientIndex >= 1) {
						bValues.push(coEfficientValue);
						bIndices.push(coEfficientIndex);
						outBufferYLength = Math.max(outBufferYLength, coEfficientIndex + 1);
						//trace("registering", coEfficientName, "to", coEfficientValue);
						//maxB = Math.max(maxB, coEfficientIndex);
						//bValues[coEfficientIndex] = coEfficientValue;
					}
					else {
						trace("Skipping illegal coefficient", coEfficientName);
					}
					
				} else {
					trace("Skipping illegal coefficient", coEfficientName);
				}
			}
			
			aAmount = aIndices.length;
			bAmount = bIndices.length;
			
			// create buffers:
			inBufferXLeft = new Vector.<Number>(inBufferXLength);
			inBufferXRight = new Vector.<Number>(inBufferXLength);
			outBufferYLeft = new Vector.<Number>(outBufferYLength);
			outBufferYRight = new Vector.<Number>(outBufferYLength);
			
			
			trace(toString());
		}
		
		
		public function toString():String {
			var maxAB:int = -1;
			var index:uint;
			for each (index in aIndices) maxAB = Math.max(maxAB, index);
			for each (index in bIndices) maxAB = Math.max(maxAB, index);
			
			var var0:String = "";
			for (index = 0; index < aIndices.length; index++) {
				var0 += "a" + aIndices[index] + "=" + aValues[index];
				var0 += ", ";
			}
			
			for (index = 0; index < bIndices.length; index++) {
				var0 += "b" + bIndices[index] + "=" + bValues[index];
				if (index < bIndices.length - 1) var0 += ", ";
			}
			
			var i:uint;
			var out0:String = "y[n] = \t";
			var out1:String = "       \t";
			for (i = 0; i <= maxAB; i++) {
				if (aIndices.indexOf(i) >= 0) {
					out0 += "a"+i+"*x["+(i==0?"n":("n-"+i))+"]\t+\t"
				} else {
					out0 += "       " + "\t\t";
				}
				if (bIndices.indexOf(i) >= 0) {
					out1 += "b"+i+"*x["+(i==0?"n":("n-"+i))+"]\t+\t"
				} else {
					out1 += "       " + "\t\t";
				}
			}
			
			return "Recursive Filter with "+var0+"\n"+out0+"\n"+out1;
		}
		
		
		public function setA(coefficientIndex:int, value:Number):void {
			var i:int = aIndices.indexOf(coefficientIndex);
			if (i >= 0) {
				aValues[i] = value;
			} else {
				trace("not registered coefficient a" + coefficientIndex);
			}
		}
		
		public function setB(coefficientIndex:int, value:Number):void {
			var i:int = bIndices.indexOf(coefficientIndex);
			if (i >= 0) {
				bValues[i] = value;
			} else {
				trace("not registered coefficient b" + coefficientIndex);
			}
		}
		
		/* INTERFACE soundengine.SoundModifier */
		
		public function get active():Boolean 
		{
			return _active;
		}
		
		public function set active(value:Boolean):void 
		{
			_active = value;
		}
		
		
		public function process(amount:int, inputLeft:Vector.<Number>, inputRight:Vector.<Number>, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void 
		{
			var yResultLeft:Number = 0;
			var yResultRight:Number = 0;
			var i:int, j:int;
			var coEfficientIndex:int;
			var coEfficientValue:Number;
			var bufPointer:int;
			var bufL:Number, bufR:Number;
			
			for (i = 0; i < amount; i++) {
				
				/*
				 * UPDATE INPUT BUFFER X
				 */
				
				// move input pointer
				inBufferXPointer--;
				if (inBufferXPointer < 0) {
					inBufferXPointer += inBufferXLength
				}
				
				// store x into input buffer
				inBufferXLeft[inBufferXPointer] = inputLeft[i];
				inBufferXRight[inBufferXPointer] = inputRight[i];
				
				
				/*
				 * RECURSIVE FILTER CALCULATION
				 */
				
				// calc yResult
				//y[n] = 	a0*x[n]	+	a1*x[n-1]	+	
       	       	//			b1*x[n-1]	+
				
				yResultLeft = yResultRight = 0;
				
				// add a coefficients A:
				for (j = 0; j < aAmount; j++) {
					// i.e. a3 = 1.2;
					coEfficientIndex = aIndices[j];
					coEfficientValue = aValues[j];
					// x[n-3]
					bufPointer = (inBufferXPointer + coEfficientIndex) % inBufferXLength;
					bufL = inBufferXLeft[bufPointer];
					bufR = inBufferXRight[bufPointer];
					// yResult += a3 * x[n-3]
					yResultLeft += coEfficientValue * bufL;
					yResultRight += coEfficientValue * bufR;
				}
				
				// add a coefficients B:
				for (j = 0; j < bAmount; j++) {
					// i.e. b2 = 1.2;
					coEfficientIndex = bIndices[j];
					coEfficientValue = bValues[j];
					// y[n-2]
					bufPointer = (outBufferYPointer + coEfficientIndex) % outBufferYLength;
					bufL = outBufferYLeft[bufPointer];
					bufR = outBufferYRight[bufPointer];
					// yResult += b2 * y[n-2]
					yResultLeft += coEfficientValue * bufL;
					yResultRight += coEfficientValue * bufR;
				}
				
				
				// set output vector
				outputLeft[i] = yResultLeft;
				outputRight[i] = yResultRight;
				
				
				/*
				 * UPDATE OUTPUT BUFFER Y
				 */
				
				// move output pointer
				outBufferYPointer--;
				if (outBufferYPointer < 0) {
					outBufferYPointer += outBufferYLength;
				}
				
				// store y into output buffer
				outBufferYLeft[outBufferYPointer] = yResultLeft;
				outBufferYRight[outBufferYPointer] = yResultRight;
			}
		}
	}

}