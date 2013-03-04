package tests.soundchaintest
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.utils.getTimer;
	import soundengine.SamplePlayer;
	import soundengine.SoundChain;
	import soundengine.SoundModifier;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SoundChainTest extends Sprite 
	{
		
		private var bufferSize:int = 2048;
		private var outL:Vector.<Number> = new Vector.<Number>(bufferSize);
		private var outR:Vector.<Number> = new Vector.<Number>(bufferSize);
		
		private var soundChain:SoundChain;
		private var sm0:Smoother;
		private var sm1:Smoother;
		private var sound:Sound;
		
		private var sm0Sprite:Sprite, sm1Sprite:Sprite;
		
		public function SoundChainTest() 
		{
			trace(this, "click left or right of center to enable/disable modifiers");
			trace(this, "move up/down to change respective modifiers");
			
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
			
			sm0 = new Smoother(0.9, true);
			sm0.active = false;
			soundChain.addSoundModifier(sm0);
			
			sm1 = new Smoother(0.99, false);
			sm1.active = false;
			soundChain.addSoundModifier(sm1);
			
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
		
		
		private function init(e:Event):void 
		{
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			
			for (var i:int = 0; i < numChildren; i++) {
				removeChildAt(i);
				i--;
			}
			
			sm0Sprite = new Sprite();
			sm0Sprite.visible = false;
			sm0Sprite.graphics.beginFill(0xff884422);
			sm0Sprite.graphics.drawRect(0, 0, stage.stageWidth / 2, stage.stageHeight);
			addChild(sm0Sprite);
			
			sm1Sprite = new Sprite();
			sm1Sprite.visible = false;
			sm1Sprite.graphics.beginFill(0xff884422);
			sm1Sprite.graphics.drawRect(0, 0, stage.stageWidth / 2, stage.stageHeight);
			sm1Sprite.x = stage.stageWidth / 2;
			addChild(sm1Sprite);
			
			var line:Sprite = new Sprite();
			line.graphics.lineStyle(1, 0xff0000);
			line.graphics.moveTo(stage.stageWidth/2, 0);
			line.graphics.lineTo(stage.stageWidth / 2, stage.stageHeight);
			addChild(line);
			
			updateVisualsFromSmoothers();
			
			sound.play();
		}
		
		private function removed(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.CLICK, onClick);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			SoundMixer.stopAll();
		}
		
		private function onMove(e:MouseEvent):void 
		{
			if (e.stageX < stage.stageWidth / 2) {
				sm0.smoothing = map(e.stageY, 0, stage.stageHeight, 0.0, 0.95);
			} else {
				sm1.smoothing = map(e.stageY, 0, stage.stageHeight, 0.95, 0.9999);
			}
			updateVisualsFromSmoothers();
		}
		
		private function updateVisualsFromSmoothers():void {
			sm0Sprite.alpha = map(sm0.smoothing, 0, 0.95, 0.5, 1);
			sm1Sprite.alpha = map(sm1.smoothing, 0.95, 0.9999, 0.5, 1);
			sm0Sprite.visible = sm0.active;
			sm1Sprite.visible = sm1.active;
		}
		
		private var lastClickTime:int = 0;
		private function onClick(e:MouseEvent):void 
		{
			if (e.stageX < stage.stageWidth/2) {
				sm0.active = !sm0.active;
			} else {
				sm1.active = !sm1.active;
			}
			updateVisualsFromSmoothers();
			trace(this, "smoothing0/1", sm0.active, sm1.active);
			
			var ti:int = getTimer();
			var dt:int = ti - lastClickTime;
			lastClickTime = ti;
			if (dt < 250) {
				parent.removeChild(this);
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