package soundengine 
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SoundChain implements SoundSource
	{
		
		private var _active:Boolean = true;
		private var _soundSource:SoundSource = null;
		
		private var _modifiers:Vector.<SoundModifier> = new Vector.<SoundModifier>();
		private var _modifierAmount:int = 0;
		
		private var sample:int;
		private var bufferSize:int = 0;
		
		private var buffer0Left:Vector.<Number> = new Vector.<Number>();
		private var buffer0Right:Vector.<Number> = new Vector.<Number>();
		private var buffer1Left:Vector.<Number> = new Vector.<Number>();
		private var buffer1Right:Vector.<Number> = new Vector.<Number>();
		
		private var bufferSourceReferenceL:Vector.<Number>;
		private var bufferSourceReferenceR:Vector.<Number>;
		private var bufferTargetReferenceL:Vector.<Number>;
		private var bufferTargetReferenceR:Vector.<Number>;
		private var bufferTempReferenceL:Vector.<Number>;
		private var bufferTempReferenceR:Vector.<Number>;
		
		
		public function SoundChain() 
		{			
		}
		
		
		
		
		
		
		/*
		 * SoundSource implementation
		 */
		public function set active(value:Boolean):void
		{
			_active = value;
		}
		public function get active():Boolean
		{
			return _active;
		}
		
		public function generate(amount:int, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void
		{
			if (!_active || !_soundSource) {
				for (sample = 0; sample < amount; sample++) {
					outputLeft[sample] = 0;
					outputRight[sample] = 0;
				}
			}
			else {
				
				if (amount != bufferSize) {
					buffer0Left = new Vector.<Number>(amount);
					buffer0Right = new Vector.<Number>(amount);
					buffer1Left = new Vector.<Number>(amount);
					buffer1Right = new Vector.<Number>(amount);
					bufferSize = amount;
				}
				
				// find last active modifier
				// (do it here, in case no modifier is active)
				var i:int;
				var lastActiveModifier:int = -1;
				for (i = 0; i < _modifierAmount; i++) {
					if (_modifiers[i].active) lastActiveModifier = i;
				}
				
				// no modifier:
				// soundSource -> to OUTPUT
				if (_modifierAmount == 0 || lastActiveModifier==-1) {
					
					if (_soundSource.active) {
						_soundSource.generate(amount, outputLeft, outputRight);
					} else {
						for (sample = 0; sample < amount; sample++) {
							outputLeft[sample] = 0;
							outputRight[sample] = 0;
						}
					}
					
				// modifiers:
				} else {
					
					// SOURCE = buffer0
					bufferSourceReferenceL = buffer0Left;
					bufferSourceReferenceR = buffer0Right;
					// TARGET = buffer1
					bufferTargetReferenceL = buffer1Left;
					bufferTargetReferenceR = buffer1Right;
					
					// soundSource -> to SOURCE (buf0)
					if (_soundSource.active) {
						_soundSource.generate(amount, buffer0Left, buffer0Right);
					} else {
						for (sample = 0; sample < amount; sample++) {
							bufferSourceReferenceL[sample] = 0;
							bufferSourceReferenceR[sample] = 0;
						}
					}
					
					
					
					var modifier:SoundModifier;
					for (i = 0; i <= lastActiveModifier; i++) {
						
						modifier = _modifiers[i];
						
						// all modifiers (except last active)
						// soundModifier: SOURCE -> TARGET, swap buffers, ready for next modifier
						if (i < lastActiveModifier) {
							
							if (modifier.active) {
								modifier.process(amount, bufferSourceReferenceL, bufferSourceReferenceR, bufferTargetReferenceL, bufferTargetReferenceR);
								// swap buffer references:
								// temp = target
								bufferTempReferenceL = bufferTargetReferenceL
								bufferTempReferenceR = bufferTargetReferenceR
								// target = source;
								bufferTargetReferenceL = bufferSourceReferenceL;
								bufferTargetReferenceR = bufferSourceReferenceR;
								// source = temp;
								bufferSourceReferenceL = bufferTempReferenceL;
								bufferSourceReferenceR = bufferTempReferenceR;
							}
						
						// last modifier:
						// soundModifier: SOURCE -> OUTPUT
						} else {
							
							if (!modifier.active) {
								throw new Error("This shouldn't happen, last active modfier should be active..?? index="+i+", lastActiveModifier="+lastActiveModifier+", amount="+_modifierAmount);
							}
							
							modifier.process(amount, bufferSourceReferenceL, bufferSourceReferenceR, outputLeft, outputRight);
							
						}
						
					}
				}
				
			}
		}
		
		
		
		
		
		/*
		 * Get / Set Sound Source
		 */
		
		public function get soundSource():SoundSource 
		{
			return _soundSource;
		}
		
		public function set soundSource(value:SoundSource):void 
		{
			_soundSource = value;
		}
		
		
		
		/*
		 * Get / Set Sound Modifiers
		 */
		
		public function addSoundModifier(soundModifier:SoundModifier):void
		{
			_modifiers.push(soundModifier);
			_modifierAmount = _modifiers.length;
		}
		//TODO: SoundChain: addSoundModifierAt(soundModifier:SoundModifier, index:int):void
		//TODO: SoundChain: removeSoundModifier(soundModifier:SoundModifier):void
		//TODO: SoundChain: removeSoundModifierAt(index:int):void
		
	}

}