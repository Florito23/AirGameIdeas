package tests.recursivetest 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.events.TouchEvent;
	import flash.media.Sound;
	import soundengine.RecursiveFilter;
	import soundengine.SamplePlayer;
	import soundengine.SoundChain;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class RecursiveFilterTest extends Sprite
	{
		
		private var bufferSize:int = 3192;
		private var outL:Vector.<Number> = new Vector.<Number>(bufferSize);
		private var outR:Vector.<Number> = new Vector.<Number>(bufferSize);
		
		private var soundChain:SoundChain = new SoundChain();
		
		private var lpf:RecursiveFilter;
		private var hpf:RecursiveFilter;
		private var lpfFourPass:RecursiveFilter;
		
		private var lines:Sprite;
		private var lpfSprite:Sprite;
		private var hpfSprite:Sprite;
		private var lpfFourPassSprite:Sprite;
		
		public function RecursiveFilterTest() 
		{
			
			
			soundChain = new SoundChain();
			
			var rectLeft:Vector.<Number> = new Vector.<Number>(441); // 100 hz
			var rectRight:Vector.<Number> = new Vector.<Number>(441); // 100 hz
			for (var i:int = 0; i < rectLeft.length; i++) {
				if (i < rectLeft.length/2) {
					rectLeft[i] = rectRight[i] = -0.5;
				} else {
					rectLeft[i] = rectRight[i] = 0.5;
				}
			}
			
			var sp:SamplePlayer = new SamplePlayer(rectLeft, rectRight);
			soundChain.soundSource = new SamplePlayer(rectLeft, rectRight);
			
			//var r:RecursiveFilter = new RecursiveFilter("a0,b1, b2, a1=1.2");
			
			trace("LPF");
			var xLpf:Number = 0.001; // lpf
			lpf = new RecursiveFilter("a0=" + (1 - xLpf) + ",b1=" + xLpf);

			trace("HPF");
			var xHPF:Number = 0.999; // hpf
			hpf = new RecursiveFilter(
				"a0=" + (1 + xHPF) / 2 + 
				",a1=" + (1 + xHPF) / -2 +
				",b1=" + xHPF);
				
				
			trace("LPF four pass");
			xLpf = 0.0001;
			lpfFourPass = new RecursiveFilter(
				"a0=" + Math.pow(1 - xLpf, 4) +
				",b1=" + 4*xLpf+
				",b2=" + (-6*xLpf*xLpf) +
				",b3=" + (4*Math.pow(xLpf,3)) +
				",b4=" + ( -(Math.pow(xLpf, 4)))
			);
			
			/*
			 * The value for x can be directly specified, or found from the desired time constant of the filter. 
			 * Just as R×C is the number of seconds it takes an RC circuit to decay to 36.8% of its final value, 
			 * d is the number of samples it takes for a recursive filter to decay to this same level:
			 * x = e ^ (-1/d)
			 * For instance, a sample-to-sample decay of corresponds to a time constant of samples (as shown in Fig 19-3). 
			 * There is also a fixed relationship between x and the -3dB cutoff frequency, fC, of the digital filter:
			 * x = e ^ (-2 * PI * fc)
			 * where fc is a value between 0 and 0.5
			*/
				
			/*trace("random");
			rf = new RecursiveFilter("a0=1,a4=0.12,b4=-0.8,b1=0.94");*/
			
			soundChain.addSoundModifier(lpf);
			soundChain.addSoundModifier(hpf);
			soundChain.addSoundModifier(lpfFourPass);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			
			lpfSprite = new Sprite();
			lpfSprite.graphics.beginFill(0xff8822);
			lpfSprite.graphics.drawRect(0, 0, stage.stageWidth / 3, stage.stageHeight);
			lpfSprite.graphics.endFill();
			addChild(lpfSprite);
			
			hpfSprite = new Sprite();
			hpfSprite.graphics.beginFill(0xff8822);
			hpfSprite.graphics.drawRect(0, 0, stage.stageWidth / 3, stage.stageHeight);
			hpfSprite.graphics.endFill();
			hpfSprite.x = stage.stageWidth / 3;
			addChild(hpfSprite);
			
			lpfFourPassSprite = new Sprite();
			lpfFourPassSprite.graphics.beginFill(0xff8822);
			lpfFourPassSprite.graphics.drawRect(0, 0, stage.stageWidth / 3, stage.stageHeight);
			lpfFourPassSprite.graphics.endFill();
			lpfFourPassSprite.x = stage.stageWidth / 3 * 2;
			addChild(lpfFourPassSprite);
			
			lines = new Sprite();
			lines.graphics.lineStyle(1, 0xff0000);
			lines.graphics.moveTo(stage.stageWidth / 3, 0);
			lines.graphics.lineTo(stage.stageWidth / 3, stage.stageHeight);
			lines.graphics.moveTo(stage.stageWidth / 3 * 2, 0);
			lines.graphics.lineTo(stage.stageWidth / 3 * 2, stage.stageHeight);
			addChild(lines);
			
			var sound:Sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
			
			// set filters:
			lpfHpf(10, 50);
			lpfHpf(stage.stageWidth / 3 + 10, stage.stageHeight - 100);
			lpfHpf(stage.stageWidth - 1, 5);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				lpfHpf(e.stageX, e.stageY);
			});stage.addEventListener(TouchEvent.TOUCH_MOVE, function(e:TouchEvent):void {
				lpfHpf(e.stageX, e.stageY);
			});
		}
		
		private function lpfHpf(stageX:Number, stageY:Number):void
		{
			var octave:Number = map(stageY, stage.stageHeight, 0, 0, 10);
			var octaveToFac:Number = Math.pow(2, octave); // 1..1024
			var fc:Number = map(octaveToFac, 1, 1024, 0, 0.5);
			//x = e ^ (-2 * PI * fc)
			var facX:Number = Math.pow(Math.E, -2 * Math.PI * fc);
			
			var a0:Number, a1:Number, b1:Number, b2:Number, b3:Number, b4:Number
			if (stageX < stage.stageWidth / 3) {
				lpfSprite.alpha = map(stageY, stage.stageHeight, 0, 1, 0);
				//LPF:
				a0 = 1 - facX;
				b1 = facX;
				lpf.setA(0, a0);
				lpf.setB(1, b1);
			} else if (stageX < stage.stageWidth / 3 * 2) {
				hpfSprite.alpha = map(stageY, stage.stageHeight, 0, 0, 1);
				//HPF:
				a0 = (1 + facX) * 0.5;
				a1 = -(1 + facX) * 0.5;
				b1 = facX;
				hpf.setA(0, a0);
				hpf.setA(1, a1);
				hpf.setB(1, b1);
			} else {
				lpfFourPassSprite.alpha = map(stageY, stage.stageHeight, 0, 0, 1);
				//lpf four pass:
				//x = e ^ (-2 * PI * fc) with 2PI replaces by 14.445
				//fc = map(stageY, stage.stageHeight, 0, 0, 0.5);
				facX = Math.pow(Math.E, -(14.445) * fc);
				a0 = Math.pow(1 - facX, 4);
				b1 = 4 * facX;
				b2 = - 6 * facX * facX;
				b3 = 4 * facX * facX * facX;
				b4 = - ( facX * facX * facX * facX );
				lpfFourPass.setA(0, a0);
				lpfFourPass.setB(1, b1);
				lpfFourPass.setB(2, b2);
				lpfFourPass.setB(3, b3);
				lpfFourPass.setB(4, b4);
				//trace(lpfFourPass);
			}
		}
		
		private function onSampleData(e:SampleDataEvent):void 
		{
			soundChain.generate(bufferSize, outL, outR);
			for (var i:int = 0; i < bufferSize; i++) {
				e.data.writeFloat(outL[i]);
				e.data.writeFloat(outR[i]);
			}
		}
		
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
	}

}