package soundengine
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class MultiTrack 
	{
		
		private var _sound:Sound;
		private var _bufferSize:int = 4096;
		
		private var _sources:Vector.<SoundSource> = new Vector.<SoundSource>();
		private var _sourceAmount:int = 0;
		
		private var tempDataL:Vector.<Number> = new Vector.<Number>(_bufferSize);
		private var tempDataR:Vector.<Number> = new Vector.<Number>(_bufferSize);
		private var mixLeftData:Vector.<Number> = new Vector.<Number>(_bufferSize);
		private var mixRightData:Vector.<Number> = new Vector.<Number>(_bufferSize);
		private var mixLeft:Number = 0;
		private var mixRight:Number = 0;
		
		private var _gain:Number = 1;
		
		public function MultiTrack()
		{
			_sound = new Sound();
			_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			_sound.play();
		}
		
		public function addSource(source:SoundSource):void {
			_sources.push(source);
			_sourceAmount = _sources.length;
		}
		
		public function getSource(index:int):SoundSource {
			return _sources[index];
		}
		
		private function onSampleData(e:SampleDataEvent):void 
		{
			
			var i:int, j:int;
			for (i = 0; i < _bufferSize; i++) {
				mixLeftData[i] = 0;
				mixRightData[i] = 0;
			}
			
			for (var s:int = 0; s < _sourceAmount; s++) {
				if (_sources[s].active) {
					_sources[s].generate(_bufferSize, tempDataL, tempDataR);
					for (i = 0; i < _bufferSize; i++) {
						mixLeftData[i] += tempDataL[i];
						mixRightData[i] += tempDataR[i];
					}
				}
			}
			
			for (i = 0; i < _bufferSize; i++) {
				e.data.writeFloat(mixLeftData[i] * _gain);
				e.data.writeFloat(mixRightData[i] * _gain);
			}
		}
		
		public function get gain():Number 
		{
			return _gain;
		}
		
		public function set gain(value:Number):void 
		{
			_gain = value;
		}
		
	}

}