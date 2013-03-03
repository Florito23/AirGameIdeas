package simplemixer 
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SimpleMixerTest extends Sprite 
	{
		
		[Embed(source="Pad1Loop.mp3")]
		private var PadClass:Class;
		private var padLeft:Vector.<Number>;
		private var padRight:Vector.<Number>;
		
		private var multiTrack:MultiTrack;
		private var samplePlayers:Vector.<SamplePlayer> = new Vector.<SamplePlayer>();
		
		private var indexToActivate:int = 1;
		
		public function SimpleMixerTest() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// init pad sound -> Vector
			var padSound:Sound = new PadClass();
			var data:ByteArray = new ByteArray();
			padSound.extract(data, padSound.length * 44100);
			padLeft = new Vector.<Number>();
			padRight = new Vector.<Number>();
			data.position = 0;
			while (data.bytesAvailable) {
				padLeft.push(data.readFloat());
				padRight.push(data.readFloat());
			}
			
			multiTrack = new MultiTrack();
			for (var i:int = 0; i < 16;i++) {
				var sp:SamplePlayer = new SamplePlayer(padLeft, padRight);
				if (i == 0) {
					sp.active = true;
				} else {
					sp.setOctave( Math.random() * 4);
				}
				multiTrack.addSource(sp);
			}
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			if (indexToActivate < 16) {
				multiTrack.getSource(indexToActivate).active = true;
			} else if (indexToActivate == 16) {
				stage.color = 0xff0000;
			} else if (indexToActivate > 16) {
				NativeApplication.nativeApplication.exit();
			}
			indexToActivate++;
		}
		
		
		
		
	}

}