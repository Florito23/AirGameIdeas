package soundlearning 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.events.TouchEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Marcus Graf
	 * @see http://philippseifried.com/blog/2011/10/07/dynamic-audio-in-as3-part-1/
	 */
	public class SoundLearningMain extends Sprite 
	{
		
		[Embed(source="RnBoppeShort.mp3")]
		private var SoundClass:Class;
		
		private var sound:Sound;
		private var soundData:ByteArray = new ByteArray();
		private var soundDataLength:uint;
		
		private var noise:Sound;
		private var sine:Sound;
		
		
		public function SoundLearningMain() 
		{
			
			sound = new SoundClass();
			
			// extract sound data
			sound.extract(soundData, sound.length * 44100);
			
			// read it
			var leftSample:Number, rightSample:Number;
			soundData.position = 0;
			var count:int = 0;
			while (soundData.bytesAvailable) {
				leftSample = soundData.readFloat();
				rightSample = soundData.readFloat();
				//if (count>10000 && count < 10200) trace(count, (count/44100.0).toFixed(3), "ms", "left", leftSample, "right", rightSample);
				//else if (count == 10200) trace("etc...");
				count++;
			}
			soundDataLength = soundData.position;
			trace("count =", count, soundDataLength);
			
			// make a random noise sound
			noise = new Sound();
			noise.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleNoiseData);
			
			// make a random sine sound
			sine = new Sound();
			sine.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleSineData);
			//sine.play()
			
			// play sound
			var soundPlayer:Sound = new Sound();
			soundPlayer.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleSoundPlayerData);
			//soundPlayer.play();
			//stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchSoundPitchMove);
			
			
			
			/*
			 * Pitch a sound
			 */
			// copy sound into vectors
			soundLeft = new Vector.<Number>();
			soundRight = new Vector.<Number>();
			soundData.position = 0;
			while (soundData.bytesAvailable) {
				soundLeft.push(soundData.readFloat());
				soundRight.push(soundData.readFloat());
			}
			soundSampleAmount = soundLeft.length;
			// now play it
			var pitchedSound:Sound = new Sound();
			pitchedSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onPitchedSoundData);
			pitchedSound.play();
			// attach interactivity
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchChangePitch);
			
			initMouseToStageEvents();
			
		}
		
		
		
		
		
		private var soundLeft:Vector.<Number>;
		private var soundRight:Vector.<Number>;
		private var soundSampleAmount:int;
		private var soundPitchFactor:Number = 1.5;
		private var soundPitchSourceIndex:Number = 0;
		private var sourceIndex:int;
		private var soundLeftValue:Number, soundRightValue:Number;
		private function onPitchedSoundData(e:SampleDataEvent):void 
		
		{
			
			// NOT INTERPOLATED:
			for (var i:int = 0; i < 2048; i++) 
			{ 
				soundPitchSourceIndex += soundPitchFactor;
				soundPitchSourceIndex %= soundSampleAmount;
				sourceIndex = int(soundPitchSourceIndex);
				soundLeftValue = soundLeft[sourceIndex];
				soundRightValue = soundRight[sourceIndex];
				e.data.writeFloat(soundLeftValue);
				e.data.writeFloat(soundRightValue);
			} 
		}
		
		private function onTouchChangePitch(e:TouchEvent):void 
		{
			var octave:Number = map(e.stageX, 0, stage.stageWidth, -1, 1);
			soundPitchFactor = Math.pow(2, octave);
		}
		
		
		
		private function initMouseToStageEvents():void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseToTouchEvent);
		}
		
		private function mouseToTouchEvent(e:MouseEvent):void 
		{
			var out:TouchEvent = new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, 0, false, e.localX, e.localY, 10, 10, 1, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.commandKey, e.controlKey);
			stage.dispatchEvent(out);
		}
		
		
		
		
		
		
		
		private function onSampleNoiseData(e:SampleDataEvent):void 
		{
			// We can add an arbitrary amount of new sample data to event.data, anywhere between 2048 and 8192. 
			// Anything less than 2048, though, and the sound will play until the end and then stop! 
			for (var i:int = 0; i < 2048; i++) 
			{ 
				e.data.writeFloat(Math.random() * 2 - 1); // random float -1...+1 for left channel 
				e.data.writeFloat(Math.random() * 2 - 1); // random float -1...+1 for right channe
			} 
		}
		
		
		
		
		
		private var currentPhaseL:Number = 0; 
		private var deltaPhaseL:Number = 440 / 44100; 
		private var currentPhaseR:Number = 0; 
		private var deltaPhaseR:Number = 440/44100; 
		private function onSampleSineData(e:SampleDataEvent):void 
		{
			for (var i:int = 0; i < 2048; i++) 
			{
				currentPhaseL += deltaPhaseL;
				currentPhaseR += deltaPhaseR;
				
				// note: this is unoptimized – normally you'd multiply deltaPhase by Math.PI*2 and remove that part here! 
				//var currentValue:Number = Math.sin(currentPhase*Math.PI*2);  
			 
				e.data.writeFloat(Math.sin(currentPhaseL*Math.PI*2)); 
				e.data.writeFloat(Math.sin(currentPhaseR*Math.PI*2)); 
			}
			deltaPhaseL /= 1.0001;
			deltaPhaseR *= 1.0001;
		}
		
		
		private var skipCount:int = 0;
		private var skipEach:int = 24;
		private function onSampleSoundPlayerData(e:SampleDataEvent):void 
		{
			for (var i:int = 0; i < 4096; i++) 
			{
				if (soundData.position >= soundDataLength) {
					soundData.position = 0;
				}
				e.data.writeFloat(soundData.readFloat());
				e.data.writeFloat(soundData.readFloat());
				skipCount++;
				if (skipCount >= skipEach) {
					skipCount = 0;
					if (soundData.position >= soundDataLength) {
						soundData.position = 0;
					}
					soundData.readFloat();
					soundData.readFloat();
				}
			}
		}
		private function onTouchSoundPitchMove(e:TouchEvent):void 
		{
			skipEach = int(map(e.stageX, 0, stage.stageWidth, 24, 1));
			trace(skipEach);
		}
		
		
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
	}

}