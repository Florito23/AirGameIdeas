package tests.soundenginetest 
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import soundengine.MultiTrack;
	import soundengine.SamplePlayer;
	import tests.AllTests;
	
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
		private var tf:TextField;
		
		public function SimpleMixerTest() 
		{
			
			trace(this, "will add another sound source on click (max 16)");
			
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
					sp.active = false;
					//sp.setOctave( Math.random() * 4);
				}
				multiTrack.addSource(sp);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
		private function init(e:Event):void 
		{
			removeChildren();
			
			for (var i:int = 0; i < 16; i++) {
				multiTrack.getSource(i).active = i == 0;
			}
			indexToActivate = 1;
			
			tf = new TextField();
			tf.defaultTextFormat = AllTests.textFormatVerdana32;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.text = "Click to add another channel\n1";
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.x = stage.stageWidth / 2 - tf.width / 2;
			tf.y = stage.stageHeight / 2 - tf.height / 2;
			addChild(tf);
			
			multiTrack.play();
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function removed(e:Event):void 
		{
			SoundMixer.stopAll();
			
			stage.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		private var lti:int = 0;
		private function onClick(e:MouseEvent):void 
		{
			var ti:int = getTimer();
			var dt:int = ti - lti;
			lti = ti;
			if (dt < 250) {
				parent.removeChild(this);
			} else {
			
				if (indexToActivate < 16) {
					(multiTrack.getSource(indexToActivate) as SamplePlayer).setOctave( Math.random() * 4);
					multiTrack.getSource(indexToActivate).active = true;
					tf.appendText(" " + (indexToActivate+1));
				} else if (indexToActivate == 16) {
					parent.removeChild(this);
				}
				indexToActivate++;
				
			}
		}
		
		
		
		
	}

}