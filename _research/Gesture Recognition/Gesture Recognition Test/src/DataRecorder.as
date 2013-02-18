package  
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class DataRecorder 
	{
		
		private var _var0:Number, _var1:Number;
		private var _out0:Number, _out1:Number;
		private var _dataAmount:int;
		private var _data:Vector.<Number>;
		private var _mappedData:Vector.<Number>;
		private var _newestIndex:int = 0;
		
		public function DataRecorder(displayCount:int, var0:Number, var1:Number, out0:Number, out1:Number) 
		{
			_var0 = var0;
			_var1 = var1;
			_out0 = out0;
			_out1 = out1;
			_data = new Vector.<Number>(displayCount);
			_mappedData = new Vector.<Number>(displayCount);
			_dataAmount = displayCount;
		}
		
		public function clear():void {
			for (var i:int = 0; i < _dataAmount; i++) {
				_data[i] = _var0;
				_mappedData[i] = _out0;
			}
		}
		
		public function addValue(value:Number):void {
			_newestIndex ++;
			_newestIndex %= _dataAmount;
			_data[_newestIndex] = value;
			_mappedData[_newestIndex] = map(value, _var0, _var1, _out0, _out1);
		}
		
		public function getMappedValues(targetVec:Vector.<Number>=null):Vector.<Number> {
			if (!targetVec) {
				targetVec = new Vector.<Number>(_dataAmount);
			} else if (targetVec.length != _dataAmount) {
				throw new Error("TargetVec doesn't have right size dataAmount");
			}
			
			var sourceIndex:int;
			var sourceData:Number;
			var targetIndex:int;
			for (var offset:int = 0; offset < _dataAmount; offset++) {
				sourceIndex = _newestIndex - offset;
				if (sourceIndex < 0) sourceIndex += _dataAmount;
				sourceData = _mappedData[sourceIndex];
				targetIndex = 0;
				targetVec[offset] = sourceData;
			}
			return targetVec;
		}
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
		
		public function get dataAmount():int 
		{
			return _dataAmount;
		}
		
	}

}