package tests.soundchaintest 
{
	import soundengine.SoundModifier;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Smoother implements SoundModifier 
	{
		
		private var _active:Boolean = true;
		private var _smoothing:Number;
		private var _lastSmoothing:Number, _deltaSmoothing:Number;
		private var _invSmoothing:Number;
		private var interpolateSmoothing:Boolean = false;
		private var randomInvert:Boolean = false;
		
		public function Smoother(sm:Number, randomInvert:Boolean) 
		{
			smoothing = sm;
			smoothing = sm;
			this.randomInvert = randomInvert;
		}
		
		public function get smoothing():Number {
			return _smoothing;
		}
		
		public function set smoothing(value:Number):void 
		{
			_lastSmoothing = _smoothing;
			_smoothing = value;
			_invSmoothing = 1.0 - value;
			_deltaSmoothing = _smoothing - _lastSmoothing;
			interpolateSmoothing = true;// _deltaSmoothing != 0;
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
		
		
		
		private var lastLeft:Number = 0;
		private var lastRight:Number = 0;
		public function process(amount:int, inputLeft:Vector.<Number>, inputRight:Vector.<Number>, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void 
		{
			var i:int
			var p:Number, sm:Number, ism:Number;
			if (!randomInvert) {
				if (!interpolateSmoothing) {
					for (i = 0; i < amount; i++) {
						lastLeft = lastLeft * _smoothing + inputLeft[i] * _invSmoothing;
						lastRight = lastRight * _smoothing + inputRight[i] * _invSmoothing;
						outputLeft[i] = lastLeft;
						outputRight[i] = lastRight;
					}
				} else {
					for (i = 0; i < amount; i++) {
						p = i / amount;
						sm = _lastSmoothing + p * _deltaSmoothing;
						ism = 1.0 - sm;
						lastLeft = lastLeft * sm + inputLeft[i] * ism;
						lastRight = lastRight * sm + inputRight[i] * ism;
						outputLeft[i] = lastLeft;
						outputRight[i] = lastRight;
					}
				}
			} else {
				if (!interpolateSmoothing) {
					for (i = 0; i < amount; i++) {
						lastLeft = lastLeft * _smoothing + inputLeft[i] * _invSmoothing;
						lastRight = lastRight * _smoothing + inputRight[i] * _invSmoothing;
						if (Math.random() < 0.001) {
							lastLeft *= -1;
							lastRight *= -1;
						}
						outputLeft[i] = lastLeft;
						outputRight[i] = lastRight;
					}
				} else {
					for (i = 0; i < amount; i++) {
						p = i / amount;
						sm = _lastSmoothing + p * _deltaSmoothing;
						ism = 1.0 - sm;
						lastLeft = lastLeft * sm + inputLeft[i] * ism;
						lastRight = lastRight * sm + inputRight[i] * ism;
						if (Math.random() < 0.001) {
							lastLeft *= -1;
							lastRight *= -1;
						}
						outputLeft[i] = lastLeft;
						outputRight[i] = lastRight;
					}
				}
			}
		}
		
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
		
	}

}