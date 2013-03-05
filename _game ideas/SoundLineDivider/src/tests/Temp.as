package tests 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Temp extends Sprite
	{
		
		var square:Boolean = false;
		var hit:Boolean = false;
		
		public function Temp() 
		{
			var sound:Sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		private function onDown(e:MouseEvent):void 
		{
			hit = true;
		}
		
		private function onSampleData(e:SampleDataEvent):void 
		{
			var v:Number;
			if (hit) {
				hit = false;
				square = !square;
			}
			for (var i:int = 0; i < 2048; i++) {
				if (square) {
					v = i < 1024 ? -1:1;
					e.data.writeFloat(v);
					e.data.writeFloat(v);
				} else {
					e.data.writeFloat(Math.random() * 2 - 1);
					e.data.writeFloat(Math.random() * 2 - 1);
				}
				
			}
		}
		
	}

}