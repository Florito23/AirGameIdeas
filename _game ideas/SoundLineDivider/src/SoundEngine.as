package  
{
	import flash.media.Sound;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import soundengine.MultiTrack;
	import soundengine.SamplePlayer;
	import soundengine.SoundSource;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SoundEngine 
	{
		
		[Embed(source="Pad1Loop.mp3")]
		private var PadClass:Class;
		private var padLeft:Vector.<Number>;
		private var padRight:Vector.<Number>;
		
		private var _multiTrack:MultiTrack;
		private var samplePlayers:Vector.<SamplePlayer> = new Vector.<SamplePlayer>();
		
		public function SoundEngine(numberOfTracks:int) 
		{
			
			padLeft = new Vector.<Number>();
			padRight = new Vector.<Number>();
			
			var so:SharedObject = SharedObject.getLocal("soundEngine");
			var loadSample:Boolean = true;
			if (so.data.loadSample) {
				loadSample = !(so.data.loadSample as Boolean);
			}
			so.data.loadSample = loadSample;
			so.flush();
			
			
			if (loadSample) {
				// init pad sound -> Vector
				var padSound:Sound = new PadClass();
				var data:ByteArray = new ByteArray();
				padSound.extract(data, padSound.length * 44100);
				data.position = 0;
				while (data.bytesAvailable) {
					padLeft.push(data.readFloat());
					padRight.push(data.readFloat());
				}
			}
			
			else {
				// init sound by sawtooth
				var freq:Number = 55; // hz;
				var cycleLengthInSamples:Number = 44100 / freq;
				var sampleAmountForTenCycles:int = int(cycleLengthInSamples * 10);
				var i:int;
				for (i = 0; i < sampleAmountForTenCycles; i++) {
					var phase:Number = i / cycleLengthInSamples * Math.PI * 2;
					var value:Number = Math.sin(phase) + 1/3.0*Math.sin(3*phase) + 1/5.0*Math.sin(5*phase);
					padLeft.push(value);
					padRight.push(value);
				}
			}
			
			_multiTrack = new MultiTrack();
			for (i = 0; i < numberOfTracks;i++) {
				var sp:SamplePlayer = new SamplePlayer(padLeft, padRight);
				sp.active = true;
				//sp.setSoundPitchFactor(2); // octave 1
				sp.setOffset(baseOctaveFac);
				_multiTrack.addSource(sp);
			}
		}
		
		private var baseOctaveFac:Number = Math.pow(2, int(1+ Math.random() * 5));
		
		public function setPitchFactor(s:int, stretchFac:Number):void 
		{
			var sp:SamplePlayer = _multiTrack.getSource(s) as SamplePlayer;
			sp.setSoundPitchFactor(baseOctaveFac * stretchFac); //octave 1
		}
		
		public function get multiTrack():MultiTrack
		{
			return _multiTrack;
		}
		
	}

}